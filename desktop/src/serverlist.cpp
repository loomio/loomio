#include "serverlist.h"
#include "hostorigin.h"
#include "server.h"

#include <QNetworkAccessManager>
#include <QSettings>

static const auto serversKey = QStringLiteral("servers");

ServerList::ServerList(QObject *parent)
    : QAbstractListModel(parent)
    , m_network(new QNetworkAccessManager(this))
{
    m_network->setCookieJar(nullptr);
    for (const QString &saved : QSettings().value(serversKey).toStringList()) {
        const QUrl origin = HostOrigin::fromUserInput(saved, Server::allowLocalHttp());
        if (origin.isValid())
            append(origin)->start();
    }
    if (!m_servers.isEmpty())
        m_currentIndex = 0;
}

ServerList *ServerList::instance()
{
    static ServerList *list = new ServerList;
    QJSEngine::setObjectOwnership(list, QJSEngine::CppOwnership);
    return list;
}

int ServerList::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_servers.size();
}

QVariant ServerList::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_servers.size() || role != ServerRole)
        return {};
    return QVariant::fromValue(m_servers.at(index.row()));
}

QHash<int, QByteArray> ServerList::roleNames() const
{
    return {{ServerRole, "server"}};
}

void ServerList::setCurrentIndex(int index)
{
    if (index == m_currentIndex || index < -1 || index >= m_servers.size())
        return;
    m_currentIndex = index;
    emit currentIndexChanged();
}

Server *ServerList::current() const
{
    return m_servers.value(m_currentIndex);
}

QString ServerList::addServer(const QString &input)
{
    const QUrl origin = HostOrigin::fromUserInput(input, Server::allowLocalHttp());
    if (!origin.isValid())
        return tr("Enter the address of a Loomio host that uses HTTPS.");
    for (Server *server : std::as_const(m_servers)) {
        if (HostOrigin::sameOrigin(server->origin(), origin)) {
            selectServer(server);
            return {};
        }
    }

    Server *server = append(origin);
    save();
    setCurrentIndex(m_servers.size() - 1);
    server->start();
    return {};
}

Server *ServerList::append(const QUrl &origin)
{
    beginInsertRows({}, m_servers.size(), m_servers.size());
    auto *server = new Server(origin, m_network, this);
    QJSEngine::setObjectOwnership(server, QJSEngine::CppOwnership);
    m_servers.append(server);
    endInsertRows();
    emit countChanged();
    emit serverAdded(server);
    return server;
}

void ServerList::removeServer(Server *server)
{
    if (!m_servers.contains(server))
        return;
    server->disconnectDevice([this, server] {
        const int row = m_servers.indexOf(server);
        if (row < 0)
            return;
        beginRemoveRows({}, row, row);
        m_servers.removeAt(row);
        endRemoveRows();
        save();
        emit countChanged();
        emit serverRemoved(server);
        if (m_currentIndex >= m_servers.size() || m_currentIndex == row) {
            m_currentIndex = m_servers.isEmpty() ? -1 : std::min(row, int(m_servers.size()) - 1);
            emit currentIndexChanged();
        } else if (m_currentIndex > row) {
            --m_currentIndex;
            emit currentIndexChanged();
        }
        server->deleteLater();
    });
}

void ServerList::selectServer(Server *server)
{
    setCurrentIndex(m_servers.indexOf(server));
}

void ServerList::save() const
{
    QStringList origins;
    for (const Server *server : m_servers)
        origins.append(server->origin().toString());
    QSettings().setValue(serversKey, origins);
}
