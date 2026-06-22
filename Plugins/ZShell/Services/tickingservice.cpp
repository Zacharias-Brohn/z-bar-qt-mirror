#include "tickingservice.hpp"
#include <QFile>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QFileSystemWatcher>
#include <QTimer>

namespace ZShell::services {

TickingService::TickingService(QObject* parent)
	: Service(parent)
	, m_timer(new QTimer(this)) {
	m_timer->setSingleShot(false);
	QObject::connect(m_timer, &QTimer::timeout, this, [this] {
			tick();
		});

	QString configPath = QDir::homePath() + QStringLiteral("/.config/zshell/config.json");

	auto reloadConfig = [this, configPath]() {
				    QFile file(configPath);
				    if (file.open(QIODevice::ReadOnly)) {
					    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
					    if (!doc.isNull()) {
						    QJsonObject dashboard = doc.object().value("dashboard").toObject();
						    if (dashboard.contains("resourceUpdateInterval")) {
							    applyInterval(dashboard.value("resourceUpdateInterval").toInt(1000));
						    }
					    }
				    }
			    };

	reloadConfig();

	static auto* watcher = new QFileSystemWatcher();
	if (!watcher->files().contains(configPath)) {
		QObject::connect(watcher, &QFileSystemWatcher::fileChanged, this, [this, configPath]() {
				QTimer::singleShot(100, this, [this, configPath]() {
					QFile file(configPath);
					if (file.exists()) {
						QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
						if (!doc.isNull()) {
							QJsonObject dashboard = doc.object().value("dashboard").toObject();
							if (dashboard.contains("resourceUpdateInterval")) {
								applyInterval(dashboard.value("resourceUpdateInterval").toInt(1000));
							}
						}
					}
				});
			});
		watcher->addPath(configPath);
	}
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
