#pragma once

#include "server.h"

#include <QObject>
#include <QPointer>

class QSystemTrayIcon;

// Shows a system notification for new activity and keeps the Dock badge in
// step with the unread count across all hosts.
class Notifier : public QObject
{
    Q_OBJECT

public:
    explicit Notifier(QObject *parent = nullptr);

signals:
    void activated();

private:
    void notify(Server *server, const ActivityItem &item);
    void updateBadge();

    QSystemTrayIcon *m_tray;
    QPointer<Server> m_lastServer;
    QString m_lastPath;
};
