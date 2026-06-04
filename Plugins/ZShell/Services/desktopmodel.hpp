#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QString>
#include <QQmlEngine>
#include <cstdint>

namespace ZShell::Services {

struct DesktopItem {
	QString fileName;
	QString filePath;
	bool isDir;
	int gridX;
	int gridY;
};

class DesktopModel : public QAbstractListModel {
Q_OBJECT
QML_ELEMENT

public:
enum DesktopRoles: std::uint16_t {
	FileNameRole = Qt::UserRole + 1,
	FilePathRole,
	IsDirRole,
	GridXRole,
	GridYRole
};

explicit DesktopModel(QObject *parent = nullptr);

[[nodiscard]] int rowCount(const QModelIndex &parent = QModelIndex()) const override;
[[nodiscard]] QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
[[nodiscard]] QHash<int, QByteArray> roleNames() const override;

Q_INVOKABLE void loadDirectory(const QString &path);
Q_INVOKABLE void moveIcon(int index, int newX, int newY);
Q_INVOKABLE void massMove(const QVariantList &selectedPathsList, const QString &leaderPath, int targetX, int targetY, int maxCol, int maxRow);

private:
QList<DesktopItem> m_items;
void saveCurrentLayout();
};

} // namespace ZShell::Services
