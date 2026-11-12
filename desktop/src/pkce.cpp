#include "pkce.h"

#include <QCryptographicHash>
#include <QRandomGenerator>

namespace Pkce {

static constexpr auto base64url = QByteArray::Base64UrlEncoding | QByteArray::OmitTrailingEquals;

QByteArray randomToken()
{
    QByteArray bytes(32, Qt::Uninitialized);
    QRandomGenerator::system()->fillRange(reinterpret_cast<quint32 *>(bytes.data()), bytes.size() / 4);
    return bytes.toBase64(base64url);
}

QByteArray challenge(const QByteArray &verifier)
{
    return QCryptographicHash::hash(verifier, QCryptographicHash::Sha256).toBase64(base64url);
}

bool constantTimeEquals(const QByteArray &left, const QByteArray &right)
{
    if (left.size() != right.size())
        return false;
    unsigned char difference = 0;
    for (qsizetype i = 0; i < left.size(); ++i)
        difference |= static_cast<unsigned char>(left[i] ^ right[i]);
    return difference == 0;
}

}
