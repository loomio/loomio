#include "hostconfig.h"
#include "hostorigin.h"

#include <QJsonDocument>
#include <QJsonObject>

QUrl HostConfig::discoveryUrl(const QUrl &origin)
{
    QUrl url(origin);
    url.setPath(QStringLiteral("/api/v1/mobile/config"));
    return url;
}

static std::optional<QUrl> endpoint(const QJsonObject &object, const char *name, const QUrl &origin, bool allowLocalHttp)
{
    const QJsonValue value = object.value(QLatin1String(name));
    if (!value.isString())
        return std::nullopt;
    const QUrl url(value.toString(), QUrl::StrictMode);
    if (!url.isValid() || url.isRelative() || url.hasQuery() || url.hasFragment() || !url.userInfo().isEmpty())
        return std::nullopt;
    if (!HostOrigin::isAllowed(url.adjusted(QUrl::RemovePath), allowLocalHttp) || !HostOrigin::sameOrigin(url, origin))
        return std::nullopt;
    return url;
}

std::optional<HostConfig> HostConfig::parse(const QByteArray &json, const QUrl &origin, bool allowLocalHttp)
{
    QJsonParseError error;
    const QJsonDocument document = QJsonDocument::fromJson(json, &error);
    if (error.error != QJsonParseError::NoError || !document.isObject())
        return std::nullopt;
    const QJsonObject object = document.object();
    if (object.value(QLatin1String("protocol_version")).toInt(-1) != protocolVersion)
        return std::nullopt;

    HostConfig config;
    const std::pair<const char *, QUrl *> fields[] = {
        {"issuer", &config.issuer},
        {"authorization_endpoint", &config.authorizationEndpoint},
        {"token_endpoint", &config.tokenEndpoint},
        {"web_session_ticket_endpoint", &config.webSessionTicketEndpoint},
        {"web_session_bootstrap_endpoint", &config.webSessionBootstrapEndpoint},
        {"activity_endpoint", &config.activityEndpoint},
        {"device_endpoint", &config.deviceEndpoint},
    };
    for (const auto &[name, field] : fields) {
        const auto url = endpoint(object, name, origin, allowLocalHttp);
        if (!url)
            return std::nullopt;
        *field = *url;
    }
    return config;
}
