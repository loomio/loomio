#pragma once

#include "hostconfig.h"

#include <QDateTime>
#include <QObject>
#include <QPointer>
#include <QQmlEngine>
#include <QTimer>
#include <QtWebEngineQuick/QQuickWebEngineProfile>
#include <QUrl>
#include <functional>

class LoopbackAuthorizer;
class QNetworkAccessManager;
class QNetworkReply;
class QNetworkRequest;


struct ActivityItem
{
    qint64 id = 0;
    QString kind;
    QString text;
    QString actorName;
    QString path;
    QDateTime createdAt;
    bool viewed = false;
};

// One connected Loomio host. Owns the host's device credential, its isolated
// web profile (cookies, storage, cache), and its recent activity.
//
// Lifecycle: Discovering -> (no credential) NeedsAuthorization -> Authorizing
// -> Connecting -> Connected. Connecting exchanges a one-time web-session ticket
// for the host's ordinary session cookie, which is placed directly into this
// host's profile so the ticket never appears in web history.
class Server : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Servers are created by ServerList")

    Q_PROPERTY(QUrl origin READ origin CONSTANT)
    Q_PROPERTY(QString host READ host CONSTANT)
    Q_PROPERTY(QString initials READ initials CONSTANT)
    Q_PROPERTY(Status status READ status NOTIFY statusChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY statusChanged)
    Q_PROPERTY(int unreadCount READ unreadCount NOTIFY activityChanged)
    Q_PROPERTY(QQuickWebEngineProfile *profile READ profile CONSTANT)
    Q_PROPERTY(QUrl startUrl READ startUrl NOTIFY startUrlChanged)

public:
    enum Status { Discovering, NeedsAuthorization, Authorizing, Connecting, Connected, Failed };
    Q_ENUM(Status)

    static constexpr std::chrono::seconds activityInterval{60};

    Server(const QUrl &origin, QNetworkAccessManager *network, QObject *parent = nullptr);

    QUrl origin() const { return m_origin; }
    QString host() const { return m_origin.host(); }
    QString initials() const;
    Status status() const { return m_status; }
    QString errorString() const { return m_errorString; }
    int unreadCount() const;
    QQuickWebEngineProfile *profile() const { return m_profile; }
    QUrl startUrl() const { return m_startUrl; }
    const QList<ActivityItem> &activity() const { return m_activity; }

    static bool allowLocalHttp();

    Q_INVOKABLE void start();
    Q_INVOKABLE void authorize();
    Q_INVOKABLE void cancelAuthorization();
    Q_INVOKABLE void reconnectWebSession();
    Q_INVOKABLE void refreshActivity();
    Q_INVOKABLE void markViewed(qint64 activityId);
    // Opens a same-origin path or URL in this host's web view.
    Q_INVOKABLE void open(const QString &pathOrUrl);
    Q_INVOKABLE bool isSameOrigin(const QUrl &url) const;

    // Revokes the device credential and erases this host's local data.
    void disconnectDevice(std::function<void()> done);

signals:
    void statusChanged();
    void activityChanged();
    void startUrlChanged();
    void newActivity(const ActivityItem &item);
    void openRequested(const QUrl &url);
    void authorizationCompleted();

private:
    using TokenCallback = std::function<void(const QByteArray &accessToken)>;

    void setStatus(Status status, const QString &error = {});
    void discover(std::function<void()> next);
    void loadCredential();
    void exchangeCode(const QByteArray &code);
    void withAccessToken(TokenCallback callback);
    void refreshAccessToken();
    void acceptTokenResponse(const QByteArray &body, std::function<void(bool ok)> done);
    void forgetCredential();
    void bootstrapWebSession();
    void installSessionCookies(QNetworkReply *reply);

    QNetworkReply *send(const QByteArray &verb, QNetworkRequest request, const QByteArray &body = {});
    QNetworkRequest jsonRequest(const QUrl &url, const QByteArray &accessToken = {}) const;
    QNetworkRequest formRequest(const QUrl &url) const;
    static QByteArray formEncode(const QList<std::pair<QString, QString>> &fields);
    QString deviceName() const;

    QUrl m_origin;
    QString m_originKey;
    QNetworkAccessManager *m_network;
    QQuickWebEngineProfile *m_profile;
    LoopbackAuthorizer *m_authorizer;
    std::optional<HostConfig> m_config;

    Status m_status = Discovering;
    QString m_errorString;
    QUrl m_startUrl;

    QByteArray m_refreshToken;
    QByteArray m_accessToken;
    QDateTime m_accessTokenExpiresAt;
    bool m_refreshInFlight = false;
    QList<TokenCallback> m_tokenWaiters;

    QTimer m_activityTimer;
    QList<ActivityItem> m_activity;
    qint64 m_activityIdNotified = -1;
};
