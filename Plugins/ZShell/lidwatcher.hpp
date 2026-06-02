#pragma once

#include <QObject>
#include <QStringList>
#include <QVariantMap>
#include <qqmlintegration.h>

namespace ZShell {

class LidWatcher : public QObject {
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON

	Q_PROPERTY(bool available READ available NOTIFY availableChanged)
	Q_PROPERTY(LidState state READ state NOTIFY stateChanged)

public:
	enum LidState {
		Opened,
		Closed
	};
	Q_ENUM(LidState)

	explicit LidWatcher(QObject* parent = nullptr);

	[[nodiscard]] bool available() const;
	[[nodiscard]] LidState state() const;

private:
	void queryInitialState();

	bool m_available;
	LidState m_state = Opened;

private Q_SLOTS:
	void onPropertiesChanged(const QString& interface, const QVariantMap& changed, const QStringList& invalidated);

Q_SIGNALS:
	void availableChanged();
	void stateChanged();
};

} // namespace ZShell
