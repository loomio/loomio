#pragma once

#include <QString>
#include <QUrl>

// A Loomio host is identified by its origin: scheme, host, and effective port.
namespace HostOrigin {

// Turns what a person typed ("community.example.org", "https://x.org/g/abc")
// into an origin URL. Returns an invalid QUrl when the input is not an allowed host.
QUrl fromUserInput(const QString &input, bool allowLocalHttp);

// HTTPS with no user information. Plain HTTP only for localhost when allowed.
bool isAllowed(const QUrl &origin, bool allowLocalHttp);

bool sameOrigin(const QUrl &left, const QUrl &right);

// A stable text form of the origin, used as a storage key.
QString key(const QUrl &origin);

}
