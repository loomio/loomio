#pragma once

#include "server.h"

#include <QAbstractListModel>
#include <QQmlEngine>

// Recent activity from every connected host, newest first.
class ActivityFeed : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int unreadCount READ unreadCount NOTIFY unreadCountChanged)

public:
    enum Role { ServerRole = Qt::UserRole + 1, ActivityIdRole, SummaryRole, ActorNameRole, PathRole, CreatedAtRole, ViewedRole };

    explicit ActivityFeed(QObject *parent = nullptr);
    static ActivityFeed *create(QQmlEngine *, QJSEngine *);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int unreadCount() const;

signals:
    void unreadCountChanged();

private:
    void watch(Server *server);
    void rebuild();

    QList<std::pair<Server *, ActivityItem>> m_items;
};
