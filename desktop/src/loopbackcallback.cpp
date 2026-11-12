#include "loopbackcallback.h"
#include "pkce.h"

#include <QRegularExpression>
#include <QUrlQuery>

static LoopbackCallback result(LoopbackCallback::Kind kind)
{
    LoopbackCallback callback;
    callback.kind = kind;
    return callback;
}

LoopbackCallback LoopbackCallback::parse(const QByteArray &request, const QByteArray &expectedState)
{
    const qsizetype headEnd = request.indexOf("\r\n\r\n");
    if (headEnd < 0)
        return result(request.size() >= requestHeadMax ? Kind::Invalid : Kind::Incomplete);

    const QList<QByteArray> requestLine = request.left(request.indexOf("\r\n")).split(' ');
    if (requestLine.size() != 3 || requestLine[0] != "GET" || !requestLine[2].startsWith("HTTP/1."))
        return result(Kind::NotCallback);

    const QByteArray target = requestLine[1];
    const qsizetype queryStart = target.indexOf('?');
    const QByteArray path = queryStart < 0 ? target : target.left(queryStart);
    if (path != "/oauth/callback")
        return result(Kind::NotCallback);
    if (queryStart < 0 || target.contains('#'))
        return result(Kind::Invalid);

    const QUrlQuery query(QString::fromLatin1(target.mid(queryStart + 1)));
    const auto single = [&query](const QString &name) -> std::optional<QString> {
        const QStringList values = query.allQueryItemValues(name, QUrl::FullyDecoded);
        if (values.size() != 1)
            return std::nullopt;
        return values.first();
    };

    const auto state = single(QStringLiteral("state"));
    if (!state || !Pkce::constantTimeEquals(state->toLatin1(), expectedState))
        return result(Kind::Invalid);

    if (query.hasQueryItem(QStringLiteral("error"))) {
        const auto error = single(QStringLiteral("error"));
        if (!error || query.hasQueryItem(QStringLiteral("code")))
            return result(Kind::Invalid);
        LoopbackCallback callback = result(Kind::Error);
        callback.error = error->left(64);
        return callback;
    }

    static const QRegularExpression codePattern(QStringLiteral("\\A[A-Za-z0-9_-]+\\z"));
    const auto code = single(QStringLiteral("code"));
    if (!code || code->size() > codeLengthMax || !codePattern.match(*code).hasMatch())
        return result(Kind::Invalid);

    LoopbackCallback callback = result(Kind::Code);
    callback.code = code->toLatin1();
    return callback;
}
