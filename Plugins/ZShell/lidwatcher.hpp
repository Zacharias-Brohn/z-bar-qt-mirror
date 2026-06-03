#pragma once

#include <QObject>
#include <QStringList>
#include <QVariantMap>
#include <cstdint>
#include <qqmlintegration.h>

class QDBusServiceWatcher;
class QTimer;

namespace ZShell {

class LidWatcher : public QObject {
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON

	Q_PROPERTY(bool available READ available NOTIFY availableChanged)
	Q_PROPERTY(LidState state READ state NOTIFY stateChanged)

	public:
	enum LidState : std::uint8_t{ Opened, Closed };
	Q_ENUM(LidState)

	explicit LidWatcher(QObject* parent = nullptr);

	[[nodiscard]] bool available() const;
	[[nodiscard]] LidState state() const;

	private:
	void tryConnect();
	void queryLidState();
	void onPropertiesChanged(const QString& interface,
							 const QVariantMap& changed,
							 const QStringList& invalidated);

	QDBusServiceWatcher* m_watcher;
	QTimer* m_pollTimer;
	bool m_available;
	LidState m_state = Opened;

	Q_SIGNALS:
	void availableChanged();
	void stateChanged();
};

} // namespace ZShell
