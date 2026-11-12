pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Loomio

ApplicationWindow {
    id: window

    width: 1280
    height: 820
    minimumWidth: 720
    minimumHeight: 480
    visible: true
    title: ServerList.current && !addingServer ? qsTr("Loomio — %1").arg(ServerList.current.host) : qsTr("Loomio")
    color: palette.window

    property bool activityVisible: true
    property bool addingServer: ServerList.count === 0

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ServerRail {
            Layout.fillHeight: true
            addingServer: window.addingServer
            activityVisible: window.activityVisible
            onAddRequested: window.addingServer = true
            onServerSelected: window.addingServer = false
            onActivityToggled: window.activityVisible = !window.activityVisible
        }

        ActivityPane {
            Layout.fillHeight: true
            Layout.preferredWidth: 320
            visible: window.activityVisible && ServerList.count > 0
            onItemOpened: window.addingServer = false
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StackLayout {
                anchors.fill: parent
                visible: !window.addingServer
                currentIndex: ServerList.currentIndex

                Repeater {
                    model: ServerList
                    delegate: ServerPage {}
                }
            }

            AddServerPage {
                anchors.fill: parent
                visible: window.addingServer
                canCancel: ServerList.count > 0
                onFinished: window.addingServer = false
            }
        }
    }
}
