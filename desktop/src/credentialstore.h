#pragma once

#include <QObject>
#include <functional>

// Refresh tokens live in the system keychain, one entry per host origin.
// Nothing else about a host is secret, so everything else uses QSettings.
namespace CredentialStore {

using ReadCallback = std::function<void(bool ok, const QByteArray &refreshToken)>;
using WriteCallback = std::function<void(bool ok)>;

void read(const QString &originKey, QObject *context, ReadCallback callback);
void write(const QString &originKey, const QByteArray &refreshToken, QObject *context, WriteCallback callback);
void remove(const QString &originKey);

}
