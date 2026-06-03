#pragma once

#include <qobject.h>
#include <qqmlintegration.h>

namespace ZShell::internal {

class LidWatcher : public QObject {
	Q_OBJECT
	QML_ELEMENT

	public:
	explicit LidWatcher(QObject* parent = nullptr);

	signals:
	void aboutToSleep();
	void resumed();
	void lockRequested();
	void unlockRequested();

	private slots:
	void handlePrepareForSleep(bool sleep);
	void handleLockRequested();
	void handleUnlockRequested();
};

} // namespace ZShell::internal
