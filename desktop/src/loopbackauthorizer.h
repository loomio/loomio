#pragma once

#include <QObject>
#include <QPointer>
#include <QTimer>
#include <QUrl>

class QTcpServer;
class QTcpSocket;

// Runs one authorization attempt: listens on an ephemeral 127.0.0.1 port, opens
// the host's authorization page in the default browser, and waits for the
// callback. Starting again cancels the previous attempt.
class LoopbackAuthorizer : public QObject
{
    Q_OBJECT

public:
    static constexpr auto clientId = "org.loomio.desktop";
    static constexpr std::chrono::minutes attemptLifetime{10};

    explicit LoopbackAuthorizer(QObject *parent = nullptr);

    bool start(const QUrl &authorizationEndpoint);
    void cancel();

    QString redirectUri() const { return m_redirectUri; }
    QByteArray codeVerifier() const { return m_codeVerifier; }

signals:
    void authorized(const QByteArray &code);
    void failed(const QString &reason);

private:
    void handleConnection();
    void handleRequest(QTcpSocket *socket);
    void respond(QTcpSocket *socket, int status, const QByteArray &reason, const QString &message);
    void finish();

    QPointer<QTcpServer> m_server;
    QTimer m_expiry;
    QString m_redirectUri;
    QByteArray m_state;
    QByteArray m_codeVerifier;
};
