#pragma once

#include <QAbstractListModel>
#include <QQmlEngine>

class QNetworkAccessManager;
class Server;

// The hosts this app is connected to, in the order the person added them.
// Only origins are persisted here; credentials live in the keychain.
class ServerList : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(Server *current READ current NOTIFY currentIndexChanged)

public:
    enum Role { ServerRole = Qt::UserRole + 1 };

    explicit ServerList(QObject *parent = nullptr);

    static ServerList *instance();
    static ServerList *create(QQmlEngine *, QJSEngine *) { return instance(); }

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int currentIndex() const { return m_currentIndex; }
    void setCurrentIndex(int index);
    Server *current() const;
    const QList<Server *> &servers() const { return m_servers; }

    // Returns an error message, or an empty string when the host was added.
    Q_INVOKABLE QString addServer(const QString &input);
    Q_INVOKABLE void removeServer(Server *server);
    Q_INVOKABLE void selectServer(Server *server);

signals:
    void countChanged();
    void currentIndexChanged();
    void serverAdded(Server *server);
    void serverRemoved(Server *server);

private:
    Server *append(const QUrl &origin);
    void save() const;

    QNetworkAccessManager *m_network;
    QList<Server *> m_servers;
    int m_currentIndex = -1;
};
