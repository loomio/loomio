#include "notifier.h"
#include "activityfeed.h"
#include "serverlist.h"

#include <QGuiApplication>
#include <QPainter>
#include <QSystemTrayIcon>

static QIcon trayIcon()
{
    QPixmap pixmap(64, 64);
    pixmap.fill(Qt::transparent);
    QPainter painter(&pixmap);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.setBrush(Qt::black);
    painter.setPen(Qt::NoPen);
    painter.drawEllipse(QRectF(8, 8, 48, 48));
    painter.end();
    QIcon icon(pixmap);
    icon.setIsMask(true);
    return icon;
}

Notifier::Notifier(QObject *parent)
    : QObject(parent)
    , m_tray(new QSystemTrayIcon(trayIcon(), this))
{
    m_tray->setToolTip(QStringLiteral("Loomio"));
    m_tray->show();
    connect(m_tray, &QSystemTrayIcon::activated, this, &Notifier::activated);
    connect(m_tray, &QSystemTrayIcon::messageClicked, this, [this] {
        emit activated();
        if (m_lastServer) {
            ServerList::instance()->selectServer(m_lastServer);
            m_lastServer->open(m_lastPath);
        }
    });

    const auto watch = [this](Server *server) {
        connect(server, &Server::newActivity, this, [this, server](const ActivityItem &item) { notify(server, item); });
    };
    for (Server *server : ServerList::instance()->servers())
        watch(server);
    connect(ServerList::instance(), &ServerList::serverAdded, this, watch);
    connect(ActivityFeed::create(nullptr, nullptr), &ActivityFeed::unreadCountChanged, this, &Notifier::updateBadge);
}

void Notifier::notify(Server *server, const ActivityItem &item)
{
    m_lastServer = server;
    m_lastPath = item.path;
    const QString title = item.actorName.isEmpty() ? server->host() : QStringLiteral("%1 · %2").arg(item.actorName, server->host());
    m_tray->showMessage(title, item.text, QSystemTrayIcon::NoIcon);
}

void Notifier::updateBadge()
{
    qGuiApp->setBadgeNumber(ActivityFeed::create(nullptr, nullptr)->unreadCount());
}
