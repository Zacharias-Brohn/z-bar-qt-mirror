#include "desktopstatemanager.hpp"
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>
#include <QJsonArray>

namespace ZShell::services {

DesktopStateManager::DesktopStateManager(QObject *parent) : QObject(parent) {
}

QString DesktopStateManager::getConfigFilePath() const {
	QString configDir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/zshell";
	QDir dir(configDir);
	if (!dir.exists()) {
		dir.mkpath(".");
	}
	return configDir + "/desktop_layout.json";
}

void DesktopStateManager::saveLayout(const QVariantMap& layout) {
	QJsonObject jsonObj = QJsonObject::fromVariantMap(layout);
	QJsonDocument doc(jsonObj);
	QFile file(getConfigFilePath());

	if (file.open(QIODevice::WriteOnly)) {
		file.write(doc.toJson(QJsonDocument::Indented));
		file.close();
	} else {
		qWarning() << "zshell: Cannot save desktop layout to" << getConfigFilePath();
	}
}

QVariantMap DesktopStateManager::getLayout() {
	QFile file(getConfigFilePath());

	if (!file.open(QIODevice::ReadOnly)) {
		return QVariantMap();
	}

	QByteArray data = file.readAll();
	file.close();

	QJsonDocument doc = QJsonDocument::fromJson(data);
	if (doc.isObject()) {
		return doc.object().toVariantMap();
	}

	return QVariantMap();
}

} // namespace ZShell::services
