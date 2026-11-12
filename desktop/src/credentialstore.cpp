#include "credentialstore.h"

#include <qt6keychain/keychain.h>

namespace CredentialStore {

static const QString service = QStringLiteral("org.loomio.desktop");

void read(const QString &originKey, QObject *context, ReadCallback callback)
{
    auto *job = new QKeychain::ReadPasswordJob(service);
    job->setKey(originKey);
    QObject::connect(job, &QKeychain::Job::finished, context, [job, callback] {
        if (job->error() == QKeychain::EntryNotFound)
            callback(true, {});
        else
            callback(job->error() == QKeychain::NoError, job->binaryData());
    });
    job->start();
}

void write(const QString &originKey, const QByteArray &refreshToken, QObject *context, WriteCallback callback)
{
    auto *job = new QKeychain::WritePasswordJob(service);
    job->setKey(originKey);
    job->setBinaryData(refreshToken);
    QObject::connect(job, &QKeychain::Job::finished, context, [job, callback] {
        callback(job->error() == QKeychain::NoError);
    });
    job->start();
}

void remove(const QString &originKey)
{
    auto *job = new QKeychain::DeletePasswordJob(service);
    job->setKey(originKey);
    job->start();
}

}
