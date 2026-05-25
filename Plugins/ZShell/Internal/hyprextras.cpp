#include "hyprextras.hpp"
#include "hyprdevices.hpp"

#include <functional>
#include <memory>

#include <qdir.h>
#include <qjsonarray.h>
#include <qjsondocument.h>
#include <qjsonobject.h>
#include <qlocalsocket.h>
#include <qloggingcategory.h>
#include <qmetatype.h>
#include <qregularexpression.h>
#include <qvariant.h>

Q_LOGGING_CATEGORY(lcHypr, "ZShell.internal.hypr", QtInfoMsg)

namespace ZShell::internal::hypr {

namespace {

static QString luaEscapeString(const QString& s) {
	QString out;
	out.reserve(s.size() + 2);
	out += QLatin1Char('"');

	for (const QChar c : s) {
		switch (c.unicode()) {
		case '\\':
			out += QLatin1String(R"(\\)");
			break;
		case '"':
			out += QLatin1String(R"(\")");
			break;
		case '\n':
			out += QLatin1String(R"(\n)");
			break;
		case '\r':
			out += QLatin1String(R"(\r)");
			break;
		case '\t':
			out += QLatin1String(R"(\t)");
			break;
		default:
			out += c;
			break;
		}
	}

	out += QLatin1Char('"');
	return out;
}

static QString luaValue(const QVariant& v);

static QString luaArray(const QVariantList& list) {
	QStringList parts;
	parts.reserve(list.size());

	for (const auto& item : list) {
		parts << luaValue(item);
	}

	return QLatin1String("{ ") + parts.join(QLatin1String(", ")) + QLatin1String(" }");
}

static QString luaArray(const QStringList& list) {
	QStringList parts;
	parts.reserve(list.size());

	for (const auto& item : list) {
		parts << luaEscapeString(item);
	}

	return QLatin1String("{ ") + parts.join(QLatin1String(", ")) + QLatin1String(" }");
}

static QString luaMapFromHash(const QVariantHash& hash) {
	QStringList parts;
	parts.reserve(hash.size());

	for (auto it = hash.cbegin(); it != hash.cend(); ++it) {
		parts << luaEscapeString(it.key()) + QLatin1String(" = ") + luaValue(it.value());
	}

	return QLatin1String("{ ") + parts.join(QLatin1String(", ")) + QLatin1String(" }");
}

static QString luaMap(const QVariantMap& map) {
	QStringList parts;
	parts.reserve(map.size());

	for (auto it = map.cbegin(); it != map.cend(); ++it) {
		parts << luaEscapeString(it.key()) + QLatin1String(" = ") + luaValue(it.value());
	}

	return QLatin1String("{ ") + parts.join(QLatin1String(", ")) + QLatin1String(" }");
}

static QString luaValue(const QVariant& v) {
	if (!v.isValid() || v.isNull()) {
		return QLatin1String("nil");
	}

	switch (v.metaType().id()) {
	case QMetaType::Bool:
		return v.toBool() ? QLatin1String("true") : QLatin1String("false");

	case QMetaType::Int:
	case QMetaType::UInt:
	case QMetaType::LongLong:
	case QMetaType::ULongLong:
	case QMetaType::Double:
		return v.toString();

	case QMetaType::QString:
		return luaEscapeString(v.toString());

	case QMetaType::QStringList:
		return luaArray(v.toStringList());

	case QMetaType::QVariantList:
		return luaArray(v.toList());

	case QMetaType::QVariantMap:
		return luaMap(v.toMap());

	case QMetaType::QVariantHash:
		return luaMapFromHash(v.toHash());

	default:
		return luaEscapeString(v.toString());
	}
}

static QString normalizeOptionPath(QString key) {
	key = key.trimmed();
	key.replace(QLatin1Char(':'), QLatin1Char('.'));
	return key;
}

static QString buildHlConfigCall(const QString& key, const QVariant& value) {
	const auto parts = normalizeOptionPath(key).split(QLatin1Char('.'), Qt::SkipEmptyParts);
	if (parts.isEmpty()) {
		return {};
	}

	QString out;
	out.reserve(32 + key.size() + value.toString().size());
	out += QLatin1String("hl.config({ ");

	for (int i = 0; i < parts.size(); ++i) {
		out += parts.at(i);
		out += QLatin1String(" = ");
		if (i + 1 < parts.size()) {
			out += QLatin1String("{ ");
		}
	}

	out += luaValue(value);

	for (int i = 0; i + 1 < parts.size(); ++i) {
		out += QLatin1String(" }");
	}

	out += QLatin1String(" })");
	return out;
}

static QVariant parseGetOptionValue(const QJsonObject& obj) {
	if (obj.contains(QStringLiteral("bool"))) {
		return obj.value(QStringLiteral("bool")).toBool();
	}

	if (obj.contains(QStringLiteral("int"))) {
		return obj.value(QStringLiteral("int")).toInt();
	}

	if (obj.contains(QStringLiteral("float"))) {
		return obj.value(QStringLiteral("float")).toDouble();
	}

	if (obj.contains(QStringLiteral("str"))) {
		return obj.value(QStringLiteral("str")).toString();
	}

	if (obj.contains(QStringLiteral("current"))) {
		return obj.value(QStringLiteral("current")).toVariant();
	}

	if (obj.contains(QStringLiteral("value"))) {
		return obj.value(QStringLiteral("value")).toVariant();
	}

	if (obj.contains(QStringLiteral("data"))) {
		const auto data = obj.value(QStringLiteral("data"));
		if (data.isObject()) {
			const auto d = data.toObject();
			if (d.contains(QStringLiteral("current"))) {
				return d.value(QStringLiteral("current")).toVariant();
			}
			if (d.contains(QStringLiteral("value"))) {
				return d.value(QStringLiteral("value")).toVariant();
			}
		} else {
			return data.toVariant();
		}
	}

	return {};
}

static void insertNestedValue(QVariantMap& root, const QStringList& path, const QVariant& value) {
	if (path.isEmpty()) {
		return;
	}

	if (path.size() == 1) {
		root.insert(path.first(), value);
		return;
	}

	const QString head = path.first();
	QVariantMap child = root.value(head).toMap();
	insertNestedValue(child, path.mid(1), value);
	root.insert(head, child);
}

} // namespace

HyprExtras::HyprExtras(QObject* parent)
	: QObject(parent)
	, m_requestSocket("")
	, m_eventSocket("")
	, m_socket(nullptr)
	, m_socketValid(false)
	, m_devices(new HyprDevices(this)) {
	const auto his = qEnvironmentVariable("HYPRLAND_INSTANCE_SIGNATURE");
	if (his.isEmpty()) {
		qCWarning(lcHypr) << "$HYPRLAND_INSTANCE_SIGNATURE is unset. Unable to connect to Hyprland socket.";
		return;
	}

	auto hyprDir = QString("%1/hypr/%2").arg(qEnvironmentVariable("XDG_RUNTIME_DIR"), his);
	if (!QDir(hyprDir).exists()) {
		hyprDir = QStringLiteral("/tmp/hypr/") + his;

		if (!QDir(hyprDir).exists()) {
			qCWarning(lcHypr) << "Hyprland socket directory does not exist. Unable to connect to Hyprland socket.";
			return;
		}
	}

	m_requestSocket = hyprDir + QStringLiteral("/.socket.sock");
	m_eventSocket = hyprDir + QStringLiteral("/.socket2.sock");

	refreshOptions();
	refreshDevices();

	m_socket = new QLocalSocket(this);

	QObject::connect(m_socket, &QLocalSocket::errorOccurred, this, &HyprExtras::socketError);
	QObject::connect(m_socket, &QLocalSocket::stateChanged, this, &HyprExtras::socketStateChanged);
	QObject::connect(m_socket, &QLocalSocket::readyRead, this, &HyprExtras::readEvent);

	m_socket->connectToServer(m_eventSocket, QLocalSocket::ReadOnly);
}

QVariantMap HyprExtras::options() const {
	return m_options;
}

HyprDevices* HyprExtras::devices() const {
	return m_devices;
}

void HyprExtras::message(const QString& message) {
	if (message.isEmpty()) {
		return;
	}

	makeRequest(message, [](bool success, const QByteArray& res) {
			if (!success) {
				qCWarning(lcHypr) << "message: request error:" << QString::fromUtf8(res);
			}
		});
}

void HyprExtras::batchMessage(const QStringList& messages) {
	if (messages.isEmpty()) {
		return;
	}

	makeRequest(QStringLiteral("[[BATCH]]") + messages.join(QLatin1Char(';')),
	            [](bool success, const QByteArray& res) {
			if (!success) {
				qCWarning(lcHypr) << "batchMessage: request error:" << QString::fromUtf8(res);
			}
		});
}

void HyprExtras::applyOptions(const QVariantHash& options) {
	if (options.isEmpty()) {
		return;
	}

	QStringList calls;
	calls.reserve(options.size());

	for (auto it = options.constBegin(); it != options.constEnd(); ++it) {
		const auto call = buildHlConfigCall(it.key(), it.value());
		if (!call.isEmpty()) {
			calls << call;
		}
	}

	if (calls.isEmpty()) {
		return;
	}

	makeRequest(QStringLiteral("eval ") + calls.join(QLatin1String("; ")), [this](bool success, const QByteArray& res) {
			if (success) {
				refreshOptions();
			} else {
				qCWarning(lcHypr) << "applyOptions: request error" << QString::fromUtf8(res);
			}
		});
}

void HyprExtras::refreshOptions() {
	if (!m_optionsRefresh.isNull()) {
		m_optionsRefresh->close();
	}

	++m_optionsRefreshGeneration;
	const quint64 generation = m_optionsRefreshGeneration;

	static const QStringList optionKeys = {
		QStringLiteral("general:border_size"),
		QStringLiteral("decoration:rounding"),
		QStringLiteral("animations:enabled"),
	};

	auto nextOptions = std::make_shared<QVariantMap>();

	auto step = std::make_shared<std::function<void(int)> >();
	*step = [this, generation, nextOptions, step](int index) {
			if (generation != m_optionsRefreshGeneration) {
				return;
			}

			if (index >= optionKeys.size()) {
				if (m_options != *nextOptions) {
					m_options = *nextOptions;
					emit optionsChanged();
				}
				return;
			}

			const QString key = optionKeys.at(index);

			m_optionsRefresh = makeRequestJson(
				QStringLiteral("getoption ") + key,
				[this, generation, nextOptions, step, index, key](bool success, const QJsonDocument& response)
			{
				m_optionsRefresh.reset();

				if (generation != m_optionsRefreshGeneration) {
					return;
				}

				if (success && response.isObject()) {
					const QVariant value = parseGetOptionValue(response.object());
					if (value.isValid()) {
						insertNestedValue(*nextOptions, key.split(QLatin1Char(':'), Qt::SkipEmptyParts), value);
					} else {
						qCWarning(lcHypr) << "refreshOptions: getoption returned no usable value for" << key;
					}
				} else if (!success) {
					qCWarning(lcHypr) << "refreshOptions: getoption request error for" << key;
				}

				(*step)(index + 1);
			});
		};

	(*step)(0);
}

void HyprExtras::refreshDevices() {
	if (!m_devicesRefresh.isNull()) {
		m_devicesRefresh->close();
	}

	m_devicesRefresh = makeRequestJson(QStringLiteral("devices"), [this](bool success, const QJsonDocument& response) {
			m_devicesRefresh.reset();
			if (success) {
				m_devices->updateLastIpcObject(response.object());
			}
		});
}

void HyprExtras::socketError(QLocalSocket::LocalSocketError error) const {
	if (!m_socketValid) {
		qCWarning(lcHypr) << "socketError: unable to connect to Hyprland event socket:" << error;
	} else {
		qCWarning(lcHypr) << "socketError: Hyprland event socket error:" << error;
	}
}

void HyprExtras::socketStateChanged(QLocalSocket::LocalSocketState state) {
	if (state == QLocalSocket::UnconnectedState && m_socketValid) {
		qCWarning(lcHypr) << "socketStateChanged: Hyprland event socket disconnected.";
	}

	m_socketValid = state == QLocalSocket::ConnectedState;
}

void HyprExtras::readEvent() {
	while (true) {
		auto rawEvent = m_socket->readLine();
		if (rawEvent.isEmpty()) {
			break;
		}
		rawEvent.truncate(rawEvent.length() - 1);
		const auto event = QByteArrayView(rawEvent.data(), rawEvent.indexOf(">>"));
		handleEvent(QString::fromUtf8(event));
	}
}

void HyprExtras::handleEvent(const QString& event) {
	if (event == QStringLiteral("configreloaded")) {
		refreshOptions();
	} else if (event == QStringLiteral("activelayout")) {
		refreshDevices();
	}
}

HyprExtras::SocketPtr HyprExtras::makeRequestJson(
	const QString& request, const std::function<void(bool, QJsonDocument)>& callback) {
	return makeRequest(QStringLiteral("j/") + request, [callback](bool success, const QByteArray& response) {
			callback(success, QJsonDocument::fromJson(response));
		});
}

HyprExtras::SocketPtr HyprExtras::makeRequest(
	const QString& request, const std::function<void(bool, QByteArray)>& callback) {
	if (m_requestSocket.isEmpty()) {
		return SocketPtr();
	}

	auto socket = SocketPtr::create(this);

	QObject::connect(socket.data(), &QLocalSocket::connected, this, [=, this]() {
			QObject::connect(socket.data(), &QLocalSocket::readyRead, this, [socket, callback]() {
				const auto response = socket->readAll();
				callback(true, std::move(response));
				socket->close();
			});

			socket->write(request.toUtf8());
			socket->flush();
		});

	QObject::connect(socket.data(), &QLocalSocket::errorOccurred, this, [=](QLocalSocket::LocalSocketError err) {
			qCWarning(lcHypr) << "makeRequest: error making request:" << err << "| request:" << request;
			callback(false, {});
			socket->close();
		});

	socket->connectToServer(m_requestSocket);

	return socket;
}

} // namespace ZShell::internal::hypr
