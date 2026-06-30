#pragma once

#include <QObject>
#include <QTime>
#include <QProcess>
#include <QTimer>
#include <qqmlintegration.h>
#include <qtmetamacros.h>

namespace ZShell::services {

class HyprsunsetManager : public QObject {
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged)
	Q_PROPERTY(
		int startTime READ startTime WRITE setStartTime NOTIFY startTimeChanged)
	Q_PROPERTY(int endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)
	Q_PROPERTY(int temp READ temp WRITE setTemp NOTIFY tempChanged)
	Q_PROPERTY(
		bool activeAuto READ activeAuto WRITE setActiveAuto NOTIFY
			activeAutoChanged)
	Q_PROPERTY(
		bool manualToggle READ manualToggle WRITE setManualToggle NOTIFY
			manualToggleChanged)

	public:
	explicit HyprsunsetManager(QObject* parent = nullptr);

	[[nodiscard]] int startTime() const;
	[[nodiscard]] int endTime() const;
	[[nodiscard]] bool enabled() const;
	[[nodiscard]] int temp() const;
	[[nodiscard]] bool activeAuto() const;
	[[nodiscard]] bool manualToggle() const;

	Q_INVOKABLE void toggle();
	Q_INVOKABLE void apply();

	void setStartTime(const int& time);
	void setEndTime(const int& time);
	void setTemp(const int& temp);
	void setActiveAuto(bool activeAuto);
	void setManualToggle(bool toggle);

	signals:
	void enabledChanged();
	void startTimeChanged();
	void activeAutoChanged();
	void endTimeChanged();
	void tempChanged();
	void manualToggleChanged();

	private:
	int m_startTime;
	int m_endTime;
	bool m_enabled = false;
	bool m_manualToggle = false;
	bool m_activeAuto;
	bool m_startAllowed = false;
	bool m_initialized = false;
	QTimer m_startCooldown;
	int m_temp;
	QProcess m_process;
	QTimer m_timer;
	QTimer m_manualTimer;
	void start();
	void end();
};

}; // namespace ZShell::services
