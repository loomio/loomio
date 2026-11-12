#include "activityfeed.h"
#include "serverlist.h"

ActivityFeed::ActivityFeed(QObject *parent)
    : QAbstractListModel(parent)
{
    ServerList *servers = ServerList::instance();
    for (Server *server : servers->servers())
        watch(server);
    connect(servers, &ServerList::serverAdded, this, &ActivityFeed::watch);
    connect(servers, &ServerList::serverRemoved, this, &ActivityFeed::rebuild, Qt::QueuedConnection);
    rebuild();
}

ActivityFeed *ActivityFeed::create(QQmlEngine *, QJSEngine *)
{
    static ActivityFeed *feed = new ActivityFeed;
    QJSEngine::setObjectOwnership(feed, QJSEngine::CppOwnership);
    return feed;
}

void ActivityFeed::watch(Server *server)
{
    connect(server, &Server::activityChanged, this, &ActivityFeed::rebuild);
}

void ActivityFeed::rebuild()
{
    beginResetModel();
    m_items.clear();
    for (Server *server : ServerList::instance()->servers()) {
        for (const ActivityItem &item : server->activity())
            m_items.append({server, item});
    }
    std::stable_sort(m_items.begin(), m_items.end(), [](const auto &left, const auto &right) {
        return left.second.createdAt > right.second.createdAt;
    });
    endResetModel();
    emit unreadCountChanged();
}

int ActivityFeed::unreadCount() const
{
    return std::count_if(m_items.cbegin(), m_items.cend(), [](const auto &entry) { return !entry.second.viewed; });
}

int ActivityFeed::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_items.size();
}

QVariant ActivityFeed::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_items.size())
        return {};
    const auto &[server, item] = m_items.at(index.row());
    switch (role) {
    case ServerRole: return QVariant::fromValue(server);
    case ActivityIdRole: return item.id;
    case SummaryRole: return item.text;
    case ActorNameRole: return item.actorName;
    case PathRole: return item.path;
    case CreatedAtRole: return item.createdAt;
    case ViewedRole: return item.viewed;
    }
    return {};
}

QHash<int, QByteArray> ActivityFeed::roleNames() const
{
    return {
        {ServerRole, "server"},
        {ActivityIdRole, "activityId"},
        {SummaryRole, "summary"},
        {ActorNameRole, "actorName"},
        {PathRole, "path"},
        {CreatedAtRole, "createdAt"},
        {ViewedRole, "viewed"},
    };
}
