#include "lidwatcher.hpp"

#include <QtDBus/qdbusconnection.h>
#include <QtDBus/qdbuserror.h>
#include <QtDBus/qdbusinterface.h>
#include <QtDBus/qdbusreply.h>
#include <qloggingcategory.h>

Q_LOGGING_CATEGORY(lcLidWatcher, "ZShell.internal.logindmanager", QtInfoMsg)

namespace ZShell::internal {

LidWatcher::LidWatcher(QObject* parent) : QObject(parent) {
	auto bus = QDBusConnection::systemBus();
	if (!bus.isConnected()) {
		qCWarning(lcLidWatcher)
		        << "Failed to connect to system bus:" << bus.lastError().message();
		return;
	}

	bool ok = bus.connect("org.freedesktop.login1",
	                      "/org/freedesktop/login1",
	                      "org.freedesktop.login1.Manager",
	                      "PrepareForSleep",
	                      this,
	                      SLOT(handlePrepareForSleep(bool)));

	if (!ok) {
		qCWarning(lcLidWatcher)
		        << "Failed to connect to PrepareForSleep signal:"
		        << bus.lastError().message();
	}

	QDBusInterface login1("org.freedesktop.login1",
	                      "/org/freedesktop/login1",
	                      "org.freedesktop.login1.Manager",
	                      bus);
	const QDBusReply<QDBusObjectPath> reply = login1.call("GetSession", "auto");
	if (!reply.isValid()) {
		qCWarning(lcLidWatcher) << "Failed to get session path";
		return;
	}
	const auto sessionPath = reply.value().path();

	ok = bus.connect("org.freedesktop.login1",
	                 sessionPath,
	                 "org.freedesktop.login1.Session",
	                 "Lock",
	                 this,
	                 SLOT(handleLockRequested()));

	if (!ok) {
		qCWarning(lcLidWatcher)
		        << "Failed to connect to Lock signal:" << bus.lastError().message();
	}

	ok = bus.connect("org.freedesktop.login1",
	                 sessionPath,
	                 "org.freedesktop.login1.Session",
	                 "Unlock",
	                 this,
	                 SLOT(handleUnlockRequested()));

	if (!ok) {
		qCWarning(lcLidWatcher) << "Failed to connect to Unlock signal:"
		                        << bus.lastError().message();
	}
}

void LidWatcher::handlePrepareForSleep(bool sleep) {
	if (sleep) {
		emit aboutToSleep();
	} else {
		emit resumed();
	}
}

void LidWatcher::handleLockRequested() {
	emit lockRequested();
}

void LidWatcher::handleUnlockRequested() {
	emit unlockRequested();
}

} // namespace ZShell::internal
