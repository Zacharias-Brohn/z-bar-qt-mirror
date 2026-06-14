#include "tickingservice.hpp"

namespace ZShell::services {

TickingService::TickingService(QObject* parent)
	: Service(parent)
	, m_timer(new QTimer(this)) {
	m_timer->setSingleShot(false);
	QObject::connect(m_timer, &QTimer::timeout, this, [this] {
			tick();
		});
}

int TickingService::updateInterval() const {
	return m_interval;
}

void TickingService::start() {
	m_running = true;
	if (m_interval > 0) {
		m_timer->start(m_interval);
	}
	tick();
}

void TickingService::stop() {
	m_running = false;
	m_timer->stop();
}

void TickingService::applyInterval(int ms) {
	if (ms <= 0 || ms == m_interval) {
		return;
	}
	m_interval = ms;
	if (m_running) {
		m_timer->start(m_interval);
	}
	Q_EMIT updateIntervalChanged();
}

} // namespace ZShell::services
