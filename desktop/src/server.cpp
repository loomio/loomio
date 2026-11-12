#include "server.h"
#include "credentialstore.h"
#include "hostorigin.h"
#include "loopbackauthorizer.h"

#include <QCryptographicHash>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkCookie>
#include <QNetworkReply>
#include <QSysInfo>
#include <QUrlQuery>
#include <QWebEngineCookieStore>
#include <QtWebEngineQuick/QQuickWebEngineDownloadRequest>
#include <QtWebEngineQuick/QQuickWebEngineProfile>

namespace {

constexpr auto userAgentSuffix = " LoomioDesktop/" LOOMIO_DESKTOP_VERSION;
constexpr qint64 responseBodyMax = 1024 * 1024;

QJsonObject jsonObject(const QByteArray &body)
{
    return QJsonDocument::fromJson(body).object();
}

int httpStatus(QNetworkReply *reply)
{
    return reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
}

}

Server::Server(const QUrl &origin, QNetworkAccessManager *network, QObject *parent)
    : QObject(parent)
    , m_origin(origin)
    , m_originKey(HostOrigin::key(origin))
    , m_network(network)
    , m_profile(new QQuickWebEngineProfile(this))
    , m_authorizer(new LoopbackAuthorizer(this))
{
    // Each host gets its own named, persistent profile so cookies and storage
    // never mix between hosts.
    const QByteArray profileId = QCryptographicHash::hash(m_originKey.toUtf8(), QCryptographicHash::Sha256).toHex().left(24);
    m_profile->setStorageName(QStringLiteral("host-") + QString::fromLatin1(profileId));
    m_profile->setOffTheRecord(false);
    m_profile->setHttpUserAgent(m_profile->httpUserAgent() + QLatin1String(userAgentSuffix));
    connect(m_profile, &QQuickWebEngineProfile::downloadRequested, this, [](QQuickWebEngineDownloadRequest *download) {
        download->accept();
    });

    connect(m_authorizer, &LoopbackAuthorizer::authorized, this, [this](const QByteArray &code) {
        emit authorizationCompleted();
        exchangeCode(code);
    });
    connect(m_authorizer, &LoopbackAuthorizer::failed, this, [this](const QString &reason) {
        setStatus(NeedsAuthorization, reason);
    });

    m_activityTimer.setInterval(activityInterval);
    connect(&m_activityTimer, &QTimer::timeout, this, &Server::refreshActivity);
}

bool Server::allowLocalHttp()
{
#ifdef LOOMIO_DESKTOP_ALLOW_LOCAL_HTTP
    return true;
#else
    return false;
#endif
}

QString Server::initials() const
{
    const QStringList labels = host().split(QLatin1Char('.'), Qt::SkipEmptyParts);
    const QString label = labels.size() > 2 ? labels.at(labels.size() - 3) : labels.value(0);
    return label.left(2).toUpper();
}

int Server::unreadCount() const
{
    return std::count_if(m_activity.cbegin(), m_activity.cend(), [](const ActivityItem &item) { return !item.viewed; });
}

bool Server::isSameOrigin(const QUrl &url) const
{
    return HostOrigin::sameOrigin(url, m_origin);
}

void Server::setStatus(Status status, const QString &error)
{
    m_status = status;
    m_errorString = error;
    if (status == Connected)
        m_activityTimer.start();
    else
        m_activityTimer.stop();
    emit statusChanged();
}

// Startup ---------------------------------------------------------------------

void Server::start()
{
    setStatus(Discovering);
    discover([this] { loadCredential(); });
}

void Server::discover(std::function<void()> next)
{
    QNetworkReply *reply = send("GET", jsonRequest(HostConfig::discoveryUrl(m_origin)));
    connect(reply, &QNetworkReply::finished, this, [this, reply, next] {
        reply->deleteLater();
        if (reply->error() == QNetworkReply::OperationCanceledError)
            return;
        if (httpStatus(reply) != 200) {
            setStatus(Failed, reply->error() == QNetworkReply::NoError || httpStatus(reply) != 0
                                  ? tr("This Loomio host does not support the desktop app.")
                                  : reply->errorString());
            return;
        }
        m_config = HostConfig::parse(reply->read(responseBodyMax), m_origin, allowLocalHttp());
        if (!m_config) {
            setStatus(Failed, tr("This Loomio host does not support the desktop app."));
            return;
        }
        next();
    });
}

void Server::loadCredential()
{
    CredentialStore::read(m_originKey, this, [this](bool ok, const QByteArray &refreshToken) {
        if (!ok) {
            setStatus(Failed, tr("Loomio could not read its saved sign-in from the keychain."));
            return;
        }
        m_refreshToken = refreshToken;
        if (m_refreshToken.isEmpty()) {
            setStatus(NeedsAuthorization);
            return;
        }
        bootstrapWebSession();
    });
}

// Authorization ---------------------------------------------------------------

void Server::authorize()
{
    if (!m_config) {
        start();
        return;
    }
    if (!m_authorizer->start(m_config->authorizationEndpoint)) {
        setStatus(NeedsAuthorization, tr("Loomio could not open your browser to sign in."));
        return;
    }
    setStatus(Authorizing);
}

void Server::cancelAuthorization()
{
    m_authorizer->cancel();
    setStatus(NeedsAuthorization);
}

void Server::exchangeCode(const QByteArray &code)
{
    setStatus(Connecting);
    const QByteArray body = formEncode({
        {QStringLiteral("grant_type"), QStringLiteral("authorization_code")},
        {QStringLiteral("client_id"), QString::fromLatin1(LoopbackAuthorizer::clientId)},
        {QStringLiteral("redirect_uri"), m_authorizer->redirectUri()},
        {QStringLiteral("code"), QString::fromLatin1(code)},
        {QStringLiteral("code_verifier"), QString::fromLatin1(m_authorizer->codeVerifier())},
        {QStringLiteral("device_name"), deviceName()},
    });
    QNetworkReply *reply = send("POST", formRequest(m_config->tokenEndpoint), body);
    connect(reply, &QNetworkReply::finished, this, [this, reply] {
        reply->deleteLater();
        if (httpStatus(reply) != 200) {
            setStatus(NeedsAuthorization, tr("The host could not complete sign-in. Please try again."));
            return;
        }
        acceptTokenResponse(reply->read(responseBodyMax), [this](bool ok) {
            if (ok)
                bootstrapWebSession();
        });
    });
}

QString Server::deviceName() const
{
    const QString machine = QSysInfo::machineHostName().section(QLatin1Char('.'), 0, 0);
    return machine.isEmpty() ? QStringLiteral("Loomio Desktop") : tr("Loomio Desktop on %1").arg(machine);
}

// Tokens ----------------------------------------------------------------------

// Calls back with a current access token, refreshing first if needed. Refreshes
// are serialized: the host treats a reused refresh token as theft and revokes the
// device, so two concurrent refreshes would disconnect us.
void Server::withAccessToken(TokenCallback callback)
{
    if (!m_accessToken.isEmpty() && QDateTime::currentDateTimeUtc().secsTo(m_accessTokenExpiresAt) > 60) {
        callback(m_accessToken);
        return;
    }
    m_tokenWaiters.append(std::move(callback));
    refreshAccessToken();
}

void Server::refreshAccessToken()
{
    if (m_refreshInFlight)
        return;
    if (m_refreshToken.isEmpty() || !m_config) {
        m_tokenWaiters.clear();
        setStatus(NeedsAuthorization);
        return;
    }

    m_refreshInFlight = true;
    const QByteArray body = formEncode({
        {QStringLiteral("grant_type"), QStringLiteral("refresh_token")},
        {QStringLiteral("client_id"), QString::fromLatin1(LoopbackAuthorizer::clientId)},
        {QStringLiteral("refresh_token"), QString::fromLatin1(m_refreshToken)},
    });
    QNetworkReply *reply = send("POST", formRequest(m_config->tokenEndpoint), body);
    connect(reply, &QNetworkReply::finished, this, [this, reply] {
        reply->deleteLater();
        const int status = httpStatus(reply);
        const auto finishWaiters = [this](bool ok) {
            m_refreshInFlight = false;
            const auto waiters = std::exchange(m_tokenWaiters, {});
            if (ok) {
                for (const auto &waiter : waiters)
                    waiter(m_accessToken);
            }
        };

        if (status == 200) {
            acceptTokenResponse(reply->read(responseBodyMax), finishWaiters);
        } else if (status == 400 || status == 401) {
            // The device was revoked or the refresh token expired.
            forgetCredential();
            finishWaiters(false);
            setStatus(NeedsAuthorization, tr("This computer was disconnected from %1. Sign in again to continue.").arg(host()));
        } else {
            finishWaiters(false);
            setStatus(Failed, status == 0 ? reply->errorString() : tr("The host is temporarily unavailable."));
        }
    });
}

// Saves the rotated refresh token before using the new access token, so a
// restart never presents a refresh token the host has already consumed.
void Server::acceptTokenResponse(const QByteArray &body, std::function<void(bool ok)> done)
{
    const QJsonObject token = jsonObject(body);
    const QByteArray accessToken = token.value(QLatin1String("access_token")).toString().toLatin1();
    const QByteArray refreshToken = token.value(QLatin1String("refresh_token")).toString().toLatin1();
    const int expiresIn = token.value(QLatin1String("expires_in")).toInt();
    if (!accessToken.startsWith("lm_at_") || !refreshToken.startsWith("lm_rt_") || expiresIn <= 0) {
        setStatus(Failed, tr("The host sent an unexpected sign-in response."));
        done(false);
        return;
    }

    CredentialStore::write(m_originKey, refreshToken, this, [=, this](bool ok) {
        if (!ok) {
            setStatus(Failed, tr("Loomio could not save its sign-in to the keychain."));
            done(false);
            return;
        }
        m_refreshToken = refreshToken;
        m_accessToken = accessToken;
        m_accessTokenExpiresAt = QDateTime::currentDateTimeUtc().addSecs(expiresIn);
        done(true);
    });
}

void Server::forgetCredential()
{
    CredentialStore::remove(m_originKey);
    m_refreshToken.clear();
    m_accessToken.clear();
}

// Web session -----------------------------------------------------------------

void Server::reconnectWebSession()
{
    if (m_refreshToken.isEmpty())
        setStatus(NeedsAuthorization);
    else
        bootstrapWebSession();
}

void Server::bootstrapWebSession()
{
    setStatus(Connecting);
    withAccessToken([this](const QByteArray &accessToken) {
        QNetworkReply *ticketReply = send("POST", jsonRequest(m_config->webSessionTicketEndpoint, accessToken), "{}");
        connect(ticketReply, &QNetworkReply::finished, this, [this, ticketReply] {
            ticketReply->deleteLater();
            const QByteArray ticket = jsonObject(ticketReply->read(responseBodyMax)).value(QLatin1String("ticket")).toString().toLatin1();
            if (httpStatus(ticketReply) != 201 && httpStatus(ticketReply) != 200) {
                if (httpStatus(ticketReply) == 401)
                    m_accessToken.clear();
                setStatus(Failed, tr("Loomio could not open your session on %1.").arg(host()));
                return;
            }
            if (!ticket.startsWith("lm_ws_")) {
                setStatus(Failed, tr("The host sent an unexpected sign-in response."));
                return;
            }

            const QByteArray body = formEncode({{QStringLiteral("ticket"), QString::fromLatin1(ticket)}});
            QNetworkReply *sessionReply = send("POST", formRequest(m_config->webSessionBootstrapEndpoint), body);
            connect(sessionReply, &QNetworkReply::finished, this, [this, sessionReply] {
                sessionReply->deleteLater();
                if (httpStatus(sessionReply) != 303) {
                    setStatus(Failed, tr("Loomio could not open your session on %1.").arg(host()));
                    return;
                }
                installSessionCookies(sessionReply);
            });
        });
    });
}

void Server::installSessionCookies(QNetworkReply *reply)
{
    const auto cookies = reply->header(QNetworkRequest::SetCookieHeader).value<QList<QNetworkCookie>>();
    if (cookies.isEmpty()) {
        setStatus(Failed, tr("Loomio could not open your session on %1.").arg(host()));
        return;
    }
    for (QNetworkCookie cookie : cookies) {
        cookie.normalize(m_origin);
        m_profile->cookieStore()->setCookie(cookie, m_origin);
    }

    QUrl landing = m_origin.resolved(reply->header(QNetworkRequest::LocationHeader).toUrl());
    if (!isSameOrigin(landing))
        landing = m_origin.resolved(QUrl(QStringLiteral("/dashboard")));
    if (m_startUrl.isEmpty() || m_status != Connected) {
        m_startUrl = landing;
        emit startUrlChanged();
    }
    setStatus(Connected);
    refreshActivity();
}

// Activity --------------------------------------------------------------------

void Server::refreshActivity()
{
    if (m_status != Connected)
        return;
    withAccessToken([this](const QByteArray &accessToken) {
        QUrl url(m_config->activityEndpoint);
        url.setQuery(QStringLiteral("limit=30"));
        QNetworkReply *reply = send("GET", jsonRequest(url, accessToken));
        connect(reply, &QNetworkReply::finished, this, [this, reply] {
            reply->deleteLater();
            if (httpStatus(reply) == 401) {
                m_accessToken.clear();
                return;
            }
            if (httpStatus(reply) != 200)
                return;

            QList<ActivityItem> items;
            const QJsonArray array = jsonObject(reply->read(responseBodyMax)).value(QLatin1String("activity")).toArray();
            for (const QJsonValue &value : array) {
                const QJsonObject object = value.toObject();
                ActivityItem item;
                item.id = object.value(QLatin1String("id")).toInteger();
                item.kind = object.value(QLatin1String("kind")).toString();
                item.actorName = object.value(QLatin1String("actor_name")).toString();
                item.path = object.value(QLatin1String("url")).toString();
                item.createdAt = QDateTime::fromString(object.value(QLatin1String("created_at")).toString(), Qt::ISODateWithMs);
                item.viewed = object.value(QLatin1String("viewed")).toBool();
                item.text = object.value(QLatin1String("title")).toString();
                if (item.text.isEmpty())
                    item.text = object.value(QLatin1String("name")).toString();
                if (item.text.isEmpty()) {
                    item.text = item.kind;
                    item.text.replace(QLatin1Char('_'), QLatin1Char(' '));
                }
                items.append(item);
            }

            // Notify only for items newer than anything seen since launch.
            const qint64 newestId = items.isEmpty() ? 0 : items.first().id;
            if (m_activityIdNotified >= 0) {
                for (const ActivityItem &item : items) {
                    if (item.id > m_activityIdNotified && !item.viewed)
                        emit newActivity(item);
                }
            }
            m_activityIdNotified = std::max(m_activityIdNotified, newestId);
            m_activity = items;
            emit activityChanged();
        });
    });
}

void Server::markViewed(qint64 activityId)
{
    for (ActivityItem &item : m_activity) {
        if (item.id == activityId && !item.viewed) {
            item.viewed = true;
            emit activityChanged();
        }
    }
    withAccessToken([this, activityId](const QByteArray &accessToken) {
        QUrl url(m_config->activityEndpoint);
        url.setPath(url.path() + QLatin1Char('/') + QString::number(activityId));
        QNetworkReply *reply = send("PATCH", jsonRequest(url, accessToken), "{}");
        connect(reply, &QNetworkReply::finished, reply, &QObject::deleteLater);
    });
}

void Server::open(const QString &pathOrUrl)
{
    const QUrl url = m_origin.resolved(QUrl(pathOrUrl));
    if (isSameOrigin(url))
        emit openRequested(url);
}

// Disconnect ------------------------------------------------------------------

void Server::disconnectDevice(std::function<void()> done)
{
    m_authorizer->cancel();
    m_activityTimer.stop();

    // Local data is erased exactly once: after the host confirms revocation, or
    // after a timeout if the host cannot be reached.
    auto erased = std::make_shared<bool>(false);
    const auto erase = [this, done, erased] {
        if (std::exchange(*erased, true))
            return;
        forgetCredential();
        m_profile->cookieStore()->deleteAllCookies();
        m_profile->clearHttpCache();
        done();
    };

    if (m_refreshToken.isEmpty() || !m_config) {
        erase();
        return;
    }
    QTimer::singleShot(std::chrono::seconds(10), this, erase);
    withAccessToken([this, erase](const QByteArray &accessToken) {
        QNetworkReply *reply = send("DELETE", jsonRequest(m_config->deviceEndpoint, accessToken));
        connect(reply, &QNetworkReply::finished, this, [reply, erase] {
            reply->deleteLater();
            erase();
        });
    });
}

// HTTP ------------------------------------------------------------------------

QNetworkReply *Server::send(const QByteArray &verb, QNetworkRequest request, const QByteArray &body)
{
    // Native API calls never share cookies with anything, and never follow
    // redirects: every endpoint must answer directly from the selected origin.
    request.setAttribute(QNetworkRequest::CookieLoadControlAttribute, QNetworkRequest::Manual);
    request.setAttribute(QNetworkRequest::CookieSaveControlAttribute, QNetworkRequest::Manual);
    request.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::ManualRedirectPolicy);
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    request.setAttribute(QNetworkRequest::CacheSaveControlAttribute, false);
    request.setTransferTimeout(std::chrono::seconds(30));
    request.setHeader(QNetworkRequest::UserAgentHeader, QByteArray("LoomioDesktop/" LOOMIO_DESKTOP_VERSION));
    return m_network->sendCustomRequest(request, verb, body);
}

QNetworkRequest Server::jsonRequest(const QUrl &url, const QByteArray &accessToken) const
{
    QNetworkRequest request(url);
    request.setRawHeader("Accept", "application/json");
    request.setHeader(QNetworkRequest::ContentTypeHeader, QByteArray("application/json"));
    if (!accessToken.isEmpty())
        request.setRawHeader("Authorization", "Bearer " + accessToken);
    return request;
}

QNetworkRequest Server::formRequest(const QUrl &url) const
{
    QNetworkRequest request(url);
    request.setRawHeader("Accept", "application/json");
    request.setHeader(QNetworkRequest::ContentTypeHeader, QByteArray("application/x-www-form-urlencoded"));
    return request;
}

QByteArray Server::formEncode(const QList<std::pair<QString, QString>> &fields)
{
    QByteArrayList pairs;
    for (const auto &[name, value] : fields)
        pairs.append(QUrl::toPercentEncoding(name) + '=' + QUrl::toPercentEncoding(value));
    return pairs.join('&');
}
