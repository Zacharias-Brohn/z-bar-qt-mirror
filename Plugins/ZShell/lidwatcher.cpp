#include "lidwatcher.hpp"

#include <QtDBus/QDBusConnection>
#include <QLoggingCategory>

Q_LOGGING_CATEGORY(lcLidWatcher, "ZShell.lidwatcher", QtInfoMsg)

namespace ZShell {

static constexpr auto kLogin1Service = "org.freedesktop.login1";
static constexpr auto kLogin1Path = "/org/freedesktop/login1";
static constexpr auto kLogin1Interface = "org.freedesktop.login1.Manager";
static constexpr auto kPrepareForSleep = "PrepareForSleep";

LidWatcher::LidWatcher(QObject* parent)
	: QObject(parent)
	, m_available(false) {
	QDBusConnection bus = QDBusConnection::systemBus();
	m_available = bus.isConnected();

	if (!m_available) {
		qCWarning(lcLidWatcher) << "system bus unavailable";
		emit availableChanged();
		return;
	}

	const auto ok = bus.connect(kLogin1Service, kLogin1Path, kLogin1Interface, kPrepareForSleep, this,
	                            SLOT(onPrepareForSleep(bool)));

	m_available = ok;
	emit availableChanged();
	if (!m_available) {
		qCWarning(lcLidWatcher) << "login1 lid signal unavailable";
	}
}

bool LidWatcher::available() const {
	return m_available;
}

void LidWatcher::onPrepareForSleep(bool goingDown) {
	if (goingDown) {
		emit lidClosing();
	} else {
		emit lidOpened();
	}
}

} // namespace ZShell
