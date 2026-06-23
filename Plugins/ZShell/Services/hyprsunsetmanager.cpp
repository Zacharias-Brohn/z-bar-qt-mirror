#include "hyprsunsetmanager.hpp"
#include <qlogging.h>
#include <qobject.h>
#include <qprocess.h>
#include <qtimer.h>

namespace ZShell::services {

HyprsunsetManager::HyprsunsetManager(QObject* parent) : QObject(parent) {
	connect(&m_timer, &QTimer::timeout, this, &HyprsunsetManager::apply);
	connect(&m_manualTimer, &QTimer::timeout, this, [this] {
			m_manualToggle = false;
			emit manualToggleChanged();
			apply();
		});
	connect(&m_startCooldown, &QTimer::timeout, this, [this] {
			m_startAllowed = true;
			apply();
		});

	m_startCooldown.start(2000);
	m_manualTimer.setSingleShot(true);
	m_timer.start(60000);

	m_process.setStandardInputFile(QProcess::nullDevice());
	m_process.setStandardOutputFile(QProcess::nullDevice());
}

int HyprsunsetManager::startTime() const {
	return m_startTime;
}

int HyprsunsetManager::endTime() const {
	return m_endTime;
}

bool HyprsunsetManager::manualToggle() const {
	return m_manualToggle;
}

bool HyprsunsetManager::enabled() const {
	return m_enabled;
}

bool HyprsunsetManager::activeAuto() const {
	return m_activeAuto;
}

int HyprsunsetManager::temp() const {
	return m_temp;
}

void HyprsunsetManager::setActiveAuto(bool activeAuto) {
	if (activeAuto == m_activeAuto)
		return;

	m_activeAuto = activeAuto;
	emit activeAutoChanged();
}

void HyprsunsetManager::setManualToggle(bool toggle) {
	if (toggle == m_manualToggle)
		return;

	m_manualToggle = toggle;
	emit manualToggleChanged();

	m_manualTimer.start(60 * 60 * 1000);
}

void HyprsunsetManager::setEndTime(const int& time) {
	if (time == m_endTime)
		return;

	m_endTime = time;
	emit endTimeChanged();
	apply();
}

void HyprsunsetManager::setStartTime(const int& time) {
	if (time == m_startTime)
		return;

	m_startTime = time;
	emit startTimeChanged();
	apply();
}

void HyprsunsetManager::setTemp(const int& temp) {
	if (temp == m_temp)
		return;

	m_temp = temp;
	emit tempChanged();
	apply();
}

void HyprsunsetManager::toggle() {
	if (m_enabled) {
		end();
	} else {
		start();
	}
}

void HyprsunsetManager::start() {
	if (m_enabled && m_initialized)
		return;

	m_initialized = true;
	m_enabled = true;

	emit enabledChanged();

	m_process.setProgram("hyprctl");
	m_process.setArguments({"hyprsunset", "temperature", QString::number(m_temp)});
	m_process.startDetached();
}

void HyprsunsetManager::end() {
	if (!m_enabled && m_initialized)
		return;

	m_initialized = true;
	m_enabled = false;

	emit enabledChanged();

	m_process.setProgram("hyprctl");
	m_process.setArguments({"hyprsunset", "identity"});
	m_process.startDetached();
}

void HyprsunsetManager::apply() {
	if (m_manualToggle || !m_activeAuto || !m_startAllowed)
		return;

	const auto current = QTime::currentTime();
	const auto currentMin = current.hour() * 60 + current.minute();
	bool isDarkTime;

	if (m_startTime <= m_endTime) {
		isDarkTime = (currentMin >= m_startTime && currentMin < m_endTime);
	} else {
		isDarkTime = (currentMin >= m_startTime || currentMin < m_endTime);
	}

	if (isDarkTime) {
		start();
	} else {
		end();
	}
}

};
