#pragma once

#include <QByteArray>

// Random values and PKCE helpers for the mobile authentication protocol.
namespace Pkce {

// 32 bytes from the system CSPRNG, base64url-encoded without padding (43 characters).
QByteArray randomToken();

// The S256 code challenge for a verifier.
QByteArray challenge(const QByteArray &verifier);

// Compares two values without exiting early on the first difference.
bool constantTimeEquals(const QByteArray &left, const QByteArray &right);

}
