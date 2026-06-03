#include "lidwatcher.hpp"

#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusMessage>
#include <QtDBus/QDBusReply>
#include <QtDBus/QDBusServiceWatcher>
#include <QLoggingCategory>
#include <QTimer>

Q_LOGGING_CATEGORY(lcLidWatcher, "ZShell.lidwatcher", QtInfoMsg)

namespace ZShell {

static constexpr auto kLogin1Service = "org.freedesktop.login1";
static constexpr auto kLogin1Path = "/org/freedesktop/login1";
static constexpr auto kLogin1Interface = "org.freedesktop.login1.Manager";
static constexpr auto kDBusPropertiesInterface =
	"org.freedesktop.DBus.Properties";

LidWatcher::LidWatcher(QObject* parent)
	: QObject(parent)
	, m_watcher(nullptr)
	, m_pollTimer(nullptr)
	, m_available(false)
{
	QDBusConnection bus = QDBusConnection::systemBus();
	if (!bus.isConnected()) {
		qCWarning(lcLidWatcher) << "system bus unavailable";
		emit availableChanged();
		return;
	}

	m_pollTimer = new QTimer(this);
	m_pollTimer->setInterval(5000);
	connect(m_pollTimer, &QTimer::timeout, this, &LidWatcher::queryLidState);

	m_watcher = new QDBusServiceWatcher(
		kLogin1Service,
		bus,
		QDBusServiceWatcher::WatchForRegistration,
		this);
	connect(m_watcher, &QDBusServiceWatcher::serviceRegistered,
			this, &LidWatcher::tryConnect);

	tryConnect();
}

bool LidWatcher::available() const {
	return m_available;
}

LidWatcher::LidState LidWatcher::state() const {
	return m_state;
}

void LidWatcher::tryConnect() {
	QDBusConnection bus = QDBusConnection::systemBus();

	const auto connected = bus.connect(
		kLogin1Service,
		kLogin1Path,
		kDBusPropertiesInterface,
		"PropertiesChanged",
		this,
		SLOT(onPropertiesChanged(QString, QVariantMap, QStringList)));

	queryLidState();

	if (connected) {
		m_pollTimer->stop();
		qCInfo(lcLidWatcher) << "login1 PropertiesChanged connected";
	} else {
		qCWarning(lcLidWatcher)
			<< "login1 PropertiesChanged unavailable, polling";
		if (!m_pollTimer->isActive()) {
			m_pollTimer->start();
}
	}

	if (!m_available) {
		m_available = true;
		emit availableChanged();
	}
}

void LidWatcher::queryLidState() {
	auto msg = QDBusMessage::createMethodCall(kLogin1Service,
											  kLogin1Path,
											  kDBusPropertiesInterface,
											  "Get");
	msg << kLogin1Interface << "LidClosed";
	const QDBusReply<QVariant> reply = QDBusConnection::systemBus().call(msg);
	if (!reply.isValid()) {
		qCWarning(lcLidWatcher)
			<< "cannot query LidClosed:" << reply.error().message();
		return;
	}
	const auto newState = reply.value().toBool() ? Closed : Opened;
	if (m_state != newState) {
		m_state = newState;
		emit stateChanged();
	}
}

void LidWatcher::onPropertiesChanged(const QString& interface,
									 const QVariantMap& changed,
									 const QStringList& ) {
	if (interface != kLogin1Interface) {
		return;
	}
	if (!changed.contains("LidClosed")) {
		return;
	}
	const auto newState = changed.value("LidClosed").toBool() ? Closed : Opened;
	if (m_state != newState) {
		m_state = newState;
		emit stateChanged();
	}
}

} // namespace ZShell
