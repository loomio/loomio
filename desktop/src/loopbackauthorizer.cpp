#include "loopbackauthorizer.h"
#include "loopbackcallback.h"
#include "pkce.h"

#include <QDesktopServices>
#include <QHostAddress>
#include <QTcpServer>
#include <QTcpSocket>
#include <QUrlQuery>

LoopbackAuthorizer::LoopbackAuthorizer(QObject *parent)
    : QObject(parent)
{
    m_expiry.setSingleShot(true);
    connect(&m_expiry, &QTimer::timeout, this, [this] {
        finish();
        emit failed(tr("The sign-in attempt expired. Please try again."));
    });
}

bool LoopbackAuthorizer::start(const QUrl &authorizationEndpoint)
{
    finish();

    m_server = new QTcpServer(this);
    if (!m_server->listen(QHostAddress::LocalHost, 0)) {
        finish();
        return false;
    }
    connect(m_server, &QTcpServer::newConnection, this, &LoopbackAuthorizer::handleConnection);

    m_state = Pkce::randomToken();
    m_codeVerifier = Pkce::randomToken();
    m_redirectUri = QStringLiteral("http://127.0.0.1:%1/oauth/callback").arg(m_server->serverPort());

    QUrlQuery query;
    query.addQueryItem(QStringLiteral("response_type"), QStringLiteral("code"));
    query.addQueryItem(QStringLiteral("client_id"), QString::fromLatin1(clientId));
    query.addQueryItem(QStringLiteral("redirect_uri"), m_redirectUri);
    query.addQueryItem(QStringLiteral("code_challenge"), QString::fromLatin1(Pkce::challenge(m_codeVerifier)));
    query.addQueryItem(QStringLiteral("code_challenge_method"), QStringLiteral("S256"));
    query.addQueryItem(QStringLiteral("state"), QString::fromLatin1(m_state));

    QUrl url(authorizationEndpoint);
    url.setQuery(query.toString(QUrl::FullyEncoded), QUrl::StrictMode);
    m_expiry.start(attemptLifetime);
    return QDesktopServices::openUrl(url);
}

void LoopbackAuthorizer::cancel()
{
    finish();
}

void LoopbackAuthorizer::finish()
{
    m_expiry.stop();
    if (m_server) {
        m_server->close();
        m_server->deleteLater();
    }
    m_server = nullptr;
    m_state.clear();
}

void LoopbackAuthorizer::handleConnection()
{
    while (m_server && m_server->hasPendingConnections()) {
        QTcpSocket *socket = m_server->nextPendingConnection();
        socket->setParent(this); // outlives the listener so the final response is flushed
        connect(socket, &QTcpSocket::disconnected, socket, &QObject::deleteLater);
        connect(socket, &QTcpSocket::readyRead, this, [this, socket] {
            QByteArray request = socket->property("request").toByteArray();
            request += socket->read(LoopbackCallback::requestHeadMax - request.size());
            socket->setProperty("request", request);
            handleRequest(socket);
        });
        QTimer::singleShot(std::chrono::seconds(10), socket, &QTcpSocket::abort);
    }
}

void LoopbackAuthorizer::handleRequest(QTcpSocket *socket)
{
    if (m_state.isEmpty()) {
        socket->abort();
        return;
    }

    const auto callback = LoopbackCallback::parse(socket->property("request").toByteArray(), m_state);
    switch (callback.kind) {
    case LoopbackCallback::Kind::Incomplete:
        return;
    case LoopbackCallback::Kind::NotCallback:
        respond(socket, 404, "Not Found", tr("Not found."));
        return;
    case LoopbackCallback::Kind::Invalid:
        // An unsolicited or tampered request. Keep waiting for the real callback.
        respond(socket, 400, "Bad Request", tr("This sign-in link is not valid."));
        return;
    case LoopbackCallback::Kind::Error:
        respond(socket, 200, "OK", tr("Sign-in was cancelled. You can close this tab."));
        finish();
        emit failed(callback.error == QLatin1String("access_denied")
                        ? tr("Sign-in was cancelled.")
                        : tr("The host could not complete sign-in."));
        return;
    case LoopbackCallback::Kind::Code:
        respond(socket, 200, "OK", tr("You're signed in. You can close this tab and return to Loomio."));
        finish();
        emit authorized(callback.code);
        return;
    }
}

void LoopbackAuthorizer::respond(QTcpSocket *socket, int status, const QByteArray &reason, const QString &message)
{
    const QByteArray body = QStringLiteral(
        "<!doctype html><meta charset=utf-8><title>Loomio</title>"
        "<body style=\"font-family:system-ui;margin:4rem auto;max-width:30rem;padding:0 1rem\">"
        "<p>%1</p></body>").arg(message.toHtmlEscaped()).toUtf8();
    QByteArray response = "HTTP/1.1 " + QByteArray::number(status) + ' ' + reason + "\r\n";
    response += "Content-Type: text/html; charset=utf-8\r\n";
    response += "Content-Length: " + QByteArray::number(body.size()) + "\r\n";
    response += "Cache-Control: no-store\r\nReferrer-Policy: no-referrer\r\nConnection: close\r\n\r\n";
    response += body;
    socket->write(response);
    socket->disconnectFromHost();
}
