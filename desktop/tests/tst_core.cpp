#include "hostconfig.h"
#include "hostorigin.h"
#include "loopbackcallback.h"
#include "pkce.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QTest>

class CoreTest : public QObject
{
    Q_OBJECT

private:
    static QJsonObject config(const QString &origin)
    {
        return {
            {"protocol_version", 1},
            {"issuer", origin},
            {"authorization_endpoint", origin + "/mobile/authorize"},
            {"token_endpoint", origin + "/api/v1/mobile/token"},
            {"web_session_ticket_endpoint", origin + "/api/v1/mobile/web-session-tickets"},
            {"web_session_bootstrap_endpoint", origin + "/mobile/web-session"},
            {"activity_endpoint", origin + "/api/v1/mobile/activity"},
            {"device_endpoint", origin + "/api/v1/mobile/device"},
        };
    }

    static QByteArray request(const QByteArray &target)
    {
        return "GET " + target + " HTTP/1.1\r\nHost: 127.0.0.1:53682\r\n\r\n";
    }

private slots:
    void pkceMatchesRfc7636Example()
    {
        QCOMPARE(Pkce::challenge("dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"),
                 QByteArray("E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM"));
    }

    void pkceTokensAreUniqueBase64Url()
    {
        const QByteArray first = Pkce::randomToken();
        QCOMPARE(first.size(), 43);
        QVERIFY(QRegularExpression("\\A[A-Za-z0-9_-]{43}\\z").match(QString::fromLatin1(first)).hasMatch());
        QVERIFY(first != Pkce::randomToken());
    }

    void originFromUserInput_data()
    {
        QTest::addColumn<QString>("input");
        QTest::addColumn<bool>("allowLocalHttp");
        QTest::addColumn<QString>("expected");

        QTest::newRow("bare host") << "Loomio.com" << false << "https://loomio.com";
        QTest::newRow("path dropped") << "https://www.loomio.com/g/abc?x=1#y" << false << "https://www.loomio.com";
        QTest::newRow("default port dropped") << "https://loomio.com:443" << false << "https://loomio.com";
        QTest::newRow("custom port kept") << "https://loomio.example:8443" << false << "https://loomio.example:8443";
        QTest::newRow("plain http rejected") << "http://loomio.com" << true << "";
        QTest::newRow("local http rejected in release") << "http://localhost:8080" << false << "";
        QTest::newRow("local http allowed in debug") << "http://localhost:8080" << true << "http://localhost:8080";
        QTest::newRow("user info rejected") << "https://user@loomio.com" << false << "";
        QTest::newRow("other scheme rejected") << "ftp://loomio.com" << false << "";
        QTest::newRow("empty rejected") << "  " << false << "";
    }

    void originFromUserInput()
    {
        QFETCH(QString, input);
        QFETCH(bool, allowLocalHttp);
        QFETCH(QString, expected);
        QCOMPARE(HostOrigin::fromUserInput(input, allowLocalHttp).toString(), expected);
    }

    void sameOriginComparesEffectivePort()
    {
        QVERIFY(HostOrigin::sameOrigin(QUrl("https://loomio.com"), QUrl("https://LOOMIO.com:443/x")));
        QVERIFY(!HostOrigin::sameOrigin(QUrl("https://loomio.com"), QUrl("https://loomio.com:8443")));
        QVERIFY(!HostOrigin::sameOrigin(QUrl("https://loomio.com"), QUrl("http://loomio.com")));
        QVERIFY(!HostOrigin::sameOrigin(QUrl("https://loomio.com"), QUrl("https://evil.loomio.com")));
    }

    void configAcceptsSameOriginEndpoints()
    {
        const QUrl origin("https://loomio.example");
        const auto parsed = HostConfig::parse(QJsonDocument(config(origin.toString())).toJson(), origin, false);
        QVERIFY(parsed);
        QCOMPARE(parsed->tokenEndpoint, QUrl("https://loomio.example/api/v1/mobile/token"));
    }

    void configRejectsUnsafeDocuments_data()
    {
        QTest::addColumn<QString>("field");
        QTest::addColumn<QJsonValue>("value");

        QTest::newRow("other origin") << "token_endpoint" << QJsonValue("https://evil.example/api/v1/mobile/token");
        QTest::newRow("other port") << "token_endpoint" << QJsonValue("https://loomio.example:8443/api/v1/mobile/token");
        QTest::newRow("plain http") << "token_endpoint" << QJsonValue("http://loomio.example/api/v1/mobile/token");
        QTest::newRow("relative") << "token_endpoint" << QJsonValue("/api/v1/mobile/token");
        QTest::newRow("user info") << "token_endpoint" << QJsonValue("https://a@loomio.example/api/v1/mobile/token");
        QTest::newRow("query") << "token_endpoint" << QJsonValue("https://loomio.example/api/v1/mobile/token?x=1");
        QTest::newRow("fragment") << "token_endpoint" << QJsonValue("https://loomio.example/api/v1/mobile/token#x");
        QTest::newRow("missing") << "activity_endpoint" << QJsonValue();
        QTest::newRow("not a string") << "device_endpoint" << QJsonValue(1);
        QTest::newRow("unknown version") << "protocol_version" << QJsonValue(2);
    }

    void configRejectsUnsafeDocuments()
    {
        QFETCH(QString, field);
        QFETCH(QJsonValue, value);
        const QUrl origin("https://loomio.example");
        QJsonObject object = config(origin.toString());
        if (value.isUndefined() || value.isNull())
            object.remove(field);
        else
            object.insert(field, value);
        QVERIFY(!HostConfig::parse(QJsonDocument(object).toJson(), origin, false));
    }

    void configRejectsMalformedJson()
    {
        QVERIFY(!HostConfig::parse("not json", QUrl("https://loomio.example"), false));
        QVERIFY(!HostConfig::parse("[]", QUrl("https://loomio.example"), false));
    }

    void callbackAcceptsMatchingState()
    {
        const auto callback = LoopbackCallback::parse(request("/oauth/callback?state=abc&code=lm_ac_XYZ-1"), "abc");
        QCOMPARE(callback.kind, LoopbackCallback::Kind::Code);
        QCOMPARE(callback.code, QByteArray("lm_ac_XYZ-1"));
    }

    void callbackReportsDenial()
    {
        const auto callback = LoopbackCallback::parse(request("/oauth/callback?state=abc&error=access_denied"), "abc");
        QCOMPARE(callback.kind, LoopbackCallback::Kind::Error);
        QCOMPARE(callback.error, QString("access_denied"));
    }

    void callbackWaitsForTheWholeHead()
    {
        QCOMPARE(LoopbackCallback::parse("GET /oauth/callback?state=abc&code=x HTTP/1.1\r\n", "abc").kind,
                 LoopbackCallback::Kind::Incomplete);
        QCOMPARE(LoopbackCallback::parse(QByteArray(LoopbackCallback::requestHeadMax, 'a'), "abc").kind,
                 LoopbackCallback::Kind::Invalid);
    }

    void callbackRejectsTampering_data()
    {
        QTest::addColumn<QByteArray>("raw");
        QTest::addColumn<int>("kind");

        const int invalid = int(LoopbackCallback::Kind::Invalid);
        const int other = int(LoopbackCallback::Kind::NotCallback);
        QTest::newRow("wrong state") << request("/oauth/callback?state=abd&code=x") << invalid;
        QTest::newRow("missing state") << request("/oauth/callback?code=x") << invalid;
        QTest::newRow("duplicate state") << request("/oauth/callback?state=abc&state=abc&code=x") << invalid;
        QTest::newRow("duplicate code") << request("/oauth/callback?state=abc&code=x&code=y") << invalid;
        QTest::newRow("missing code") << request("/oauth/callback?state=abc") << invalid;
        QTest::newRow("code and error") << request("/oauth/callback?state=abc&code=x&error=e") << invalid;
        QTest::newRow("code charset") << request("/oauth/callback?state=abc&code=a%20b") << invalid;
        QTest::newRow("code too long") << request("/oauth/callback?state=abc&code=" + QByteArray(513, 'a')) << invalid;
        QTest::newRow("no query") << request("/oauth/callback") << invalid;
        QTest::newRow("other path") << request("/favicon.ico") << other;
        QTest::newRow("trailing slash") << request("/oauth/callback/?state=abc&code=x") << other;
        QTest::newRow("post") << QByteArray("POST /oauth/callback?state=abc&code=x HTTP/1.1\r\n\r\n") << other;
    }

    void callbackRejectsTampering()
    {
        QFETCH(QByteArray, raw);
        QFETCH(int, kind);
        QCOMPARE(int(LoopbackCallback::parse(raw, "abc").kind), kind);
    }
};

QTEST_GUILESS_MAIN(CoreTest)
#include "tst_core.moc"
