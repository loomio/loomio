import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine
import Loomio

Item {
    id: page

    required property Server server

    readonly property bool connected: server.status === Server.Connected

    WebEngineView {
        id: web
        anchors.fill: parent
        visible: page.connected
        profile: page.server.profile
        url: page.server.startUrl

        // The view only ever shows the selected host. Everything else opens in
        // the default browser.
        onNavigationRequested: request => {
            if (request.isMainFrame && !page.server.isSameOrigin(request.url)) {
                request.reject()
                Qt.openUrlExternally(request.url)
            }
        }
        onNewWindowRequested: request => {
            if (page.server.isSameOrigin(request.requestedUrl))
                web.url = request.requestedUrl
            else
                Qt.openUrlExternally(request.requestedUrl)
        }
    }

    Connections {
        target: page.server
        function onOpenRequested(url) { web.url = url }
    }

    Pane {
        anchors.fill: parent
        visible: !page.connected

        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(parent.width - 48, 440)
            spacing: 16

            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                visible: running
                running: page.server.status === Server.Discovering || page.server.status === Server.Connecting
            }

            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: 22
                font.bold: true
                text: {
                    switch (page.server.status) {
                    case Server.Discovering: return qsTr("Contacting %1…").arg(page.server.host)
                    case Server.NeedsAuthorization: return qsTr("Connect to this Loomio host?")
                    case Server.Authorizing: return qsTr("Continue in your browser")
                    case Server.Connecting: return qsTr("Opening Loomio…")
                    case Server.Failed: return qsTr("Couldn't connect to %1").arg(page.server.host)
                    }
                    return ""
                }
            }

            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: page.server.status === Server.NeedsAuthorization
                font.family: "Menlo"
                text: page.server.origin.toString()
            }

            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                opacity: 0.75
                visible: text.length > 0
                text: {
                    if (page.server.errorString.length > 0)
                        return page.server.errorString
                    switch (page.server.status) {
                    case Server.NeedsAuthorization: return qsTr("Your browser will open so you can sign in. This app never sees your password.")
                    case Server.Authorizing: return qsTr("Sign in and approve this computer in the browser window that just opened.")
                    }
                    return ""
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Button {
                    visible: page.server.status === Server.NeedsAuthorization
                    highlighted: true
                    text: qsTr("Continue in browser")
                    onClicked: page.server.authorize()
                }
                Button {
                    visible: page.server.status === Server.Authorizing
                    text: qsTr("Open browser again")
                    onClicked: page.server.authorize()
                }
                Button {
                    visible: page.server.status === Server.Authorizing
                    text: qsTr("Cancel")
                    onClicked: page.server.cancelAuthorization()
                }
                Button {
                    visible: page.server.status === Server.Failed
                    highlighted: true
                    text: qsTr("Try again")
                    onClicked: page.server.start()
                }
                Button {
                    visible: page.server.status === Server.NeedsAuthorization || page.server.status === Server.Failed
                    text: qsTr("Remove")
                    onClicked: ServerList.removeServer(page.server)
                }
            }
        }
    }
}
