#pragma once

#include <QByteArray>
#include <QString>

// Interprets the HTTP request the browser sends to the loopback listener after
// authorization. Only GET /oauth/callback with the expected state is accepted.
struct LoopbackCallback
{
    enum class Kind {
        Incomplete,   // the request head has not fully arrived
        NotCallback,  // some other path, such as /favicon.ico
        Invalid,      // the callback path with a missing, duplicated, or wrong value
        Code,         // authorization approved
        Error,        // authorization denied or failed, with a matching state
    };

    Kind kind = Kind::Incomplete;
    QByteArray code;
    QString error;

    static constexpr qsizetype requestHeadMax = 8192;
    static constexpr qsizetype codeLengthMax = 512;

    static LoopbackCallback parse(const QByteArray &request, const QByteArray &expectedState);
};
