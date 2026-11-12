#pragma once

#include <QByteArray>
#include <QUrl>
#include <optional>

// The endpoints a host advertises at /api/v1/mobile/config.
struct HostConfig
{
    static constexpr int protocolVersion = 1;

    QUrl issuer;
    QUrl authorizationEndpoint;
    QUrl tokenEndpoint;
    QUrl webSessionTicketEndpoint;
    QUrl webSessionBootstrapEndpoint;
    QUrl activityEndpoint;
    QUrl deviceEndpoint;

    static QUrl discoveryUrl(const QUrl &origin);

    // Accepts the document only if every endpoint is on the selected origin.
    static std::optional<HostConfig> parse(const QByteArray &json, const QUrl &origin, bool allowLocalHttp);
};
