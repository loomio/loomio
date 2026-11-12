#include "hostorigin.h"

namespace HostOrigin {

static bool isLocalHost(const QString &host)
{
    return host == QLatin1String("localhost") || host == QLatin1String("127.0.0.1");
}

static int effectivePort(const QUrl &url)
{
    return url.port(url.scheme() == QLatin1String("https") ? 443 : 80);
}

bool isAllowed(const QUrl &origin, bool allowLocalHttp)
{
    if (!origin.isValid() || origin.host().isEmpty() || !origin.userInfo().isEmpty())
        return false;
    if (origin.scheme() == QLatin1String("https"))
        return true;
    return allowLocalHttp && origin.scheme() == QLatin1String("http") && isLocalHost(origin.host());
}

QUrl fromUserInput(const QString &input, bool allowLocalHttp)
{
    QString text = input.trimmed();
    if (text.isEmpty() || text.size() > 2048)
        return {};
    if (!text.contains(QLatin1String("://")))
        text.prepend(QLatin1String("https://"));

    const QUrl parsed(text, QUrl::StrictMode);
    if (!parsed.isValid() || !parsed.userInfo().isEmpty())
        return {};

    QUrl origin;
    origin.setScheme(parsed.scheme().toLower());
    origin.setHost(parsed.host().toLower());
    if (parsed.port() != -1 && parsed.port() != effectivePort(origin))
        origin.setPort(parsed.port());
    return isAllowed(origin, allowLocalHttp) ? origin : QUrl();
}

bool sameOrigin(const QUrl &left, const QUrl &right)
{
    return left.isValid() && right.isValid()
        && left.scheme().compare(right.scheme(), Qt::CaseInsensitive) == 0
        && left.host().compare(right.host(), Qt::CaseInsensitive) == 0
        && effectivePort(left) == effectivePort(right);
}

QString key(const QUrl &origin)
{
    return QStringLiteral("%1://%2:%3").arg(origin.scheme().toLower(), origin.host().toLower()).arg(effectivePort(origin));
}

}
