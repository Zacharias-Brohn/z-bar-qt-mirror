#include "lidwatcher.hpp"

#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusMessage>
#include <QtDBus/QDBusReply>
#include <QLoggingCategory>

Q_LOGGING_CATEGORY(lcLidWatcher, "ZShell.lidwatcher", QtInfoMsg)

namespace ZShell {

static constexpr auto kLogin1Service = "org.freedesktop.login1";
static constexpr auto kLogin1Path = "/org/freedesktop/login1";
static constexpr auto kLogin1Interface = "org.freedesktop.login1.Manager";
static constexpr auto kDBusPropertiesInterface = "org.freedesktop.DBus.Properties";

LidWatcher::LidWatcher(QObject* parent)
	: QObject(parent)
	, m_available(false)
	, m_state(Opened) {
	QDBusConnection bus = QDBusConnection::systemBus();
	m_available = bus.isConnected();

	if (!m_available) {
		qCWarning(lcLidWatcher) << "system bus unavailable";
		emit availableChanged();
		return;
	}

	const auto ok = bus.connect(kLogin1Service, kLogin1Path, kDBusPropertiesInterface, "PropertiesChanged",
	                            this, SLOT(onPropertiesChanged(QString,QVariantMap,QStringList)));

	m_available = ok;
	emit availableChanged();
	if (!m_available) {
		qCWarning(lcLidWatcher) << "login1 properties signal unavailable";
		return;
	}

	queryInitialState();
}

bool LidWatcher::available() const {
	return m_available;
}

LidWatcher::LidState LidWatcher::state() const {
	return m_state;
}

void LidWatcher::queryInitialState() {
	auto msg = QDBusMessage::createMethodCall(
		kLogin1Service, kLogin1Path,
		kDBusPropertiesInterface, "Get");
	msg << kLogin1Interface << "LidClosed";
	const QDBusReply<QVariant> reply = QDBusConnection::systemBus().call(msg);
	if (!reply.isValid()) {
		qCWarning(lcLidWatcher) << "cannot query LidClosed:" << reply.error().message();
		return;
	}
	m_state = reply.value().toBool() ? Closed : Opened;
	emit stateChanged();
}

void LidWatcher::onPropertiesChanged(const QString& interface, const QVariantMap& changed, const QStringList& /*invalidated*/) {
	if (interface != kLogin1Interface)
		return;
	if (!changed.contains("LidClosed"))
		return;
	m_state = changed.value("LidClosed").toBool() ? Closed : Opened;
	emit stateChanged();
}

} // namespace ZShell
