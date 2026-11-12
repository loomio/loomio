#include "notifier.h"
#include "serverlist.h"

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QtWebEngineQuick/qtwebenginequickglobal.h>

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName(QStringLiteral("Loomio"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("loomio.org"));
    QCoreApplication::setApplicationName(QStringLiteral("Loomio Desktop"));
    QCoreApplication::setApplicationVersion(QStringLiteral(LOOMIO_DESKTOP_VERSION));
    QtWebEngineQuick::initialize();

    QApplication app(argc, argv);
    app.setQuitOnLastWindowClosed(false);
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    ServerList::instance();
    Notifier notifier;

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app, [] { QCoreApplication::exit(1); },
                     Qt::QueuedConnection);
    engine.loadFromModule("Loomio", "Main");

    const auto raise = [&engine] {
        if (auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().value(0))) {
            window->show();
            window->raise();
            window->requestActivate();
        }
    };
    QObject::connect(&notifier, &Notifier::activated, &app, raise);
    for (Server *server : ServerList::instance()->servers())
        QObject::connect(server, &Server::authorizationCompleted, &app, raise);
    QObject::connect(ServerList::instance(), &ServerList::serverAdded, &app, [raise, &app](Server *server) {
        QObject::connect(server, &Server::authorizationCompleted, &app, raise);
    });
    QObject::connect(&app, &QGuiApplication::applicationStateChanged, &app, [raise](Qt::ApplicationState state) {
        if (state == Qt::ApplicationActive)
            raise();
    });

    return app.exec();
}
