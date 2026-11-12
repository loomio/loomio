pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Loomio

Rectangle {
    id: rail

    property bool addingServer
    property bool activityVisible

    signal addRequested()
    signal serverSelected()
    signal activityToggled()

    implicitWidth: 68
    color: Qt.darker(palette.window, 1.06)

    Rectangle {
        anchors.right: parent.right
        width: 1
        height: parent.height
        color: palette.mid
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        spacing: 10

        RailButton {
            Layout.alignment: Qt.AlignHCenter
            label: "☰"
            selected: rail.activityVisible
            badge: ActivityFeed.unreadCount
            ToolTip.text: qsTr("Activity")
            onClicked: rail.activityToggled()
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 32
            Layout.preferredHeight: 1
            color: palette.mid
        }

        ListView {
            id: servers
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            clip: true
            model: ServerList

            delegate: Item {
                id: entry
                required property Server server
                required property int index

                width: servers.width
                height: 44

                RailButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: entry.server.initials
                    selected: !rail.addingServer && ServerList.currentIndex === entry.index
                    badge: entry.server.unreadCount
                    dimmed: entry.server.status !== Server.Connected
                    ToolTip.text: entry.server.host
                    onClicked: {
                        ServerList.currentIndex = entry.index
                        rail.serverSelected()
                    }
                    onSecondaryClicked: menu.popup()
                }

                Menu {
                    id: menu
                    MenuItem {
                        text: qsTr("Reload")
                        enabled: entry.server.status === Server.Connected
                        onTriggered: entry.server.open(entry.server.startUrl)
                    }
                    MenuItem {
                        text: qsTr("Open session again")
                        onTriggered: entry.server.reconnectWebSession()
                    }
                    MenuItem {
                        text: qsTr("Open in browser")
                        onTriggered: Qt.openUrlExternally(entry.server.origin)
                    }
                    MenuSeparator {}
                    MenuItem {
                        text: qsTr("Disconnect this computer…")
                        onTriggered: confirm.open()
                    }
                }

                Dialog {
                    id: confirm
                    parent: Overlay.overlay
                    anchors.centerIn: parent
                    modal: true
                    title: qsTr("Disconnect from %1?").arg(entry.server.host)
                    standardButtons: Dialog.Cancel | Dialog.Ok
                    Label {
                        width: 360
                        wrapMode: Text.Wrap
                        text: qsTr("This signs this computer out of %1 and removes its saved data from this app. Your Loomio account is not affected.").arg(entry.server.host)
                    }
                    onAccepted: ServerList.removeServer(entry.server)
                }
            }
        }

        RailButton {
            Layout.alignment: Qt.AlignHCenter
            label: "+"
            selected: rail.addingServer
            ToolTip.text: qsTr("Add a Loomio host")
            onClicked: rail.addRequested()
        }
    }

    component RailButton: AbstractButton {
        id: button

        property string label
        property bool selected
        property bool dimmed
        property int badge

        signal secondaryClicked()

        implicitWidth: 44
        implicitHeight: 44
        hoverEnabled: true
        ToolTip.visible: hovered && ToolTip.text.length > 0
        ToolTip.delay: 500
        opacity: dimmed ? 0.55 : 1

        background: Rectangle {
            radius: button.selected ? 14 : 22
            color: button.selected ? palette.highlight : (button.hovered ? palette.midlight : palette.button)
            Behavior on radius { NumberAnimation { duration: 120 } }
        }

        contentItem: Label {
            text: button.label
            font.pixelSize: 15
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: button.selected ? palette.highlightedText : palette.buttonText
        }

        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: button.secondaryClicked()
        }

        Rectangle {
            visible: button.badge > 0
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: -4
            height: 18
            width: Math.max(18, count.implicitWidth + 8)
            radius: 9
            color: "#d93025"
            Label {
                id: count
                anchors.centerIn: parent
                text: button.badge > 99 ? "99+" : button.badge
                color: "white"
                font.pixelSize: 11
                font.bold: true
            }
        }
    }
}
