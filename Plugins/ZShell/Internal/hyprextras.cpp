#include "hyprextras.hpp"
#include "hyprdevices.hpp"

#include <qdir.h>
#include <qjsonarray.h>
#include <qlocalsocket.h>
#include <qloggingcategory.h>
#include <qvariant.h>
#include <qmetatype.h>

Q_LOGGING_CATEGORY(lcHypr, "ZShell.internal.hypr", QtInfoMsg)

namespace ZShell::internal::hypr {

static QString luaEscapeString(const QString& s) {
	QString out;
	out.reserve(s.size() + 2);

	out += '"';
	for (QChar c : s) {
		switch (c.unicode()) {
		case '\\': out += "\\\\"; break;
		case '"':  out += "\\\""; break;
		case '\n': out += "\\n"; break;
		case '\r': out += "\\r"; break;
		case '\t': out += "\\t"; break;
		default:   out += c; break;
		}
	}
	out += '"';

	return out;
}

static QString luaValue(const QVariant& v);

static QString luaArray(const QVariantList& list) {
	QStringList parts;
	parts.reserve(list.size());

	for (const auto& item : list) {
		parts << luaValue(item);
	}

	return "{ " + parts.join(", ") + " }";
}

static QString luaMap(const QVariantMap& map) {
	QStringList parts;
	parts.reserve(map.size());

	for (auto it = map.cbegin(); it != map.cend(); ++it) {
		parts << it.key() + " = " + luaValue(it.value());
	}

	return "{ " + parts.join(", ") + " }";
}

static QString luaValue(const QVariant& v) {
	if (!v.isValid() || v.isNull())
		return "nil";

	switch (v.metaType().id()) {
	case QMetaType::Bool:
		return v.toBool() ? "true" : "false";

	case QMetaType::Int:
	case QMetaType::UInt:
	case QMetaType::LongLong:
	case QMetaType::ULongLong:
	case QMetaType::Double:
		return v.toString();

	case QMetaType::QString:
		return luaEscapeString(v.toString());

	case QMetaType::QStringList:
		return luaArray(v.toStringList().toList());

	case QMetaType::QVariantList:
		return luaArray(v.toList());

	case QMetaType::QVariantMap:
		return luaMap(v.toMap());

	case QMetaType::QVariantHash: {
		QVariantMap map;
		for (auto it = v.toHash().begin(); it != v.toHash().end(); ++it)
			map.insert(it.key(), it.value());
		return luaMap(map);
	}

	default:
		return luaEscapeString(v.toString());
	}
}

static QString normalizeKey(QString key) {
	key = key.trimmed();
	key.replace(':', '.');
	return key;
}

static QString buildHlConfig(const QString& key, const QVariant& value) {
	const QStringList parts = normalizeKey(key).split('.', Qt::SkipEmptyParts);
	if (parts.isEmpty())
		return {};

	QString out = "hl.config({ ";

	for (int i = 0; i < parts.size(); ++i) {
		out += parts[i] + " = ";
		if (i != parts.size() - 1)
			out += "{ ";
	}

	out += luaValue(value);

	for (int i = 0; i < parts.size() - 1; ++i)
		out += " }";

	out += " })";
	return out;
}

HyprExtras::HyprExtras(QObject* parent)
	: QObject(parent)
	, m_requestSocket("")
	, m_eventSocket("")
	, m_socket(nullptr)
	, m_socketValid(false)
	, m_devices(new HyprDevices(this)) {

	const auto his = qEnvironmentVariable("HYPRLAND_INSTANCE_SIGNATURE");
	if (his.isEmpty()) {
		qCWarning(lcHypr) << "$HYPRLAND_INSTANCE_SIGNATURE is unset.";
		return;
	}

	auto hyprDir = QString("%1/hypr/%2")
	               .arg(qEnvironmentVariable("XDG_RUNTIME_DIR"), his);

	if (!QDir(hyprDir).exists()) {
		hyprDir = "/tmp/hypr/" + his;
		if (!QDir(hyprDir).exists()) {
			qCWarning(lcHypr) << "Hyprland socket directory not found.";
			return;
		}
	}

	m_requestSocket = hyprDir + "/.socket.sock";
	m_eventSocket   = hyprDir + "/.socket2.sock";

	refreshOptions();
	refreshDevices();

	m_socket = new QLocalSocket(this);

	connect(m_socket, &QLocalSocket::errorOccurred,
	        this, &HyprExtras::socketError);

	connect(m_socket, &QLocalSocket::stateChanged,
	        this, &HyprExtras::socketStateChanged);

	connect(m_socket, &QLocalSocket::readyRead,
	        this, &HyprExtras::readEvent);

	m_socket->connectToServer(m_eventSocket, QLocalSocket::ReadOnly);
}


QVariantHash HyprExtras::options() const {
	return m_options;
}

HyprDevices* HyprExtras::devices() const {
	return m_devices;
}

void HyprExtras::message(const QString& message) {
	if (message.isEmpty()) return;

	makeRequest(message, [](bool success, const QByteArray& res) {
			if (!success)
				qCWarning(lcHypr) << "message failed:" << res;
		});
}

void HyprExtras::batchMessage(const QStringList& messages) {
	if (messages.isEmpty()) return;

	makeRequest("[[BATCH]]" + messages.join(";"),
	            [](bool success, const QByteArray& res) {
			if (!success)
				qCWarning(lcHypr) << "batchMessage failed:" << res;
		});
}

void HyprExtras::applyOptions(const QVariantHash& options) {
	if (options.isEmpty())
		return;

	QStringList luaCalls;
	luaCalls.reserve(options.size());

	for (auto it = options.begin(); it != options.end(); ++it) {
		const auto call = buildHlConfig(it.key(), it.value());
		if (!call.isEmpty())
			luaCalls << call;
	}

	if (luaCalls.isEmpty())
		return;

	const QString request =
		"eval " + luaCalls.join("; ");

	makeRequest(request,
	            [this](bool success, const QByteArray& res) {
			if (success)
				refreshOptions();
			else
				qCWarning(lcHypr) << "applyOptions failed:" << res;
		});
}

void HyprExtras::refreshOptions() {
	if (!m_optionsRefresh.isNull())
		m_optionsRefresh->close();

	m_optionsRefresh = makeRequestJson("descriptions",
	                                   [this](bool success, const QJsonDocument& response) {
			m_optionsRefresh.reset();
			if (!success) return;

			const auto arr = response.array();
			bool dirty = false;

			for (const auto& o : arr) {
				const auto obj = o.toObject();
				const auto key = obj.value("value").toString();
				const auto value =
					obj.value("data").toObject()
					.value("current")
					.toVariant();

				if (m_options.value(key) != value) {
					m_options.insert(key, value);
					dirty = true;
				}
			}

			if (dirty)
				emit optionsChanged();
		});
}

void HyprExtras::refreshDevices() {
	if (!m_devicesRefresh.isNull())
		m_devicesRefresh->close();

	m_devicesRefresh = makeRequestJson("devices",
	                                   [this](bool success, const QJsonDocument& response) {
			m_devicesRefresh.reset();
			if (success)
				m_devices->updateLastIpcObject(response.object());
		});
}

void HyprExtras::socketError(QLocalSocket::LocalSocketError error) const {
	qCWarning(lcHypr) << "socket error:" << error;
}

void HyprExtras::socketStateChanged(QLocalSocket::LocalSocketState state) {
	m_socketValid = (state == QLocalSocket::ConnectedState);
}

void HyprExtras::readEvent() {
	while (true) {
		auto line = m_socket->readLine();
		if (line.isEmpty()) break;

		line.chop(1);
		const auto event = line.left(line.indexOf(">>"));

		handleEvent(QString::fromUtf8(event));
	}
}

void HyprExtras::handleEvent(const QString& event) {
	if (event == "configreloaded")
		refreshOptions();
	else if (event == "activelayout")
		refreshDevices();
}

HyprExtras::SocketPtr HyprExtras::makeRequestJson(
	const QString& request,
	const std::function<void(bool, QJsonDocument)>& callback) {

	return makeRequest("j/" + request,
	                   [callback](bool success, const QByteArray& res) {
			callback(success, QJsonDocument::fromJson(res));
		});
}

HyprExtras::SocketPtr HyprExtras::makeRequest(
	const QString& request,
	const std::function<void(bool, QByteArray)>& callback) {

	if (m_requestSocket.isEmpty())
		return SocketPtr();

	auto socket = SocketPtr::create(this);

	connect(socket.data(), &QLocalSocket::connected, this, [=, this]() {
			connect(socket.data(), &QLocalSocket::readyRead,
			        this, [socket, callback]() {
				callback(true, socket->readAll());
				socket->close();
			});

			socket->write(request.toUtf8());
			socket->flush();
		});

	connect(socket.data(), &QLocalSocket::errorOccurred,
	        this, [=](QLocalSocket::LocalSocketError err) {
			qCWarning(lcHypr) << "request error:" << err << request;
			callback(false, {});
			socket->close();
		});

	socket->connectToServer(m_requestSocket);
	return socket;
}

} // namespace ZShell::internal::hypr
