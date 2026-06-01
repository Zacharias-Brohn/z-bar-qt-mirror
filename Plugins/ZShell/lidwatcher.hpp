#pragma once

#include <QObject>
#include <qqmlintegration.h>

namespace ZShell {

class LidWatcher : public QObject {
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON

	Q_PROPERTY(bool available READ available NOTIFY availableChanged)

public:
	explicit LidWatcher(QObject* parent = nullptr);

	[[nodiscard]] bool available() const;

private Q_SLOTS:
	void onPrepareForSleep(bool goingDown);

Q_SIGNALS:
	void availableChanged();
	void lidClosing();
	void lidOpened();

private:
	bool m_available;
};

} // namespace ZShell
