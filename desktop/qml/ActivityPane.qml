pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Loomio

Rectangle {
    id: pane

    signal itemOpened()

    color: palette.base

    Rectangle {
        anchors.right: parent.right
        width: 1
        height: parent.height
        color: palette.mid
    }

    function since(date) {
        const seconds = Math.max(0, (Date.now() - date.getTime()) / 1000)
        if (seconds < 60) return qsTr("now")
        if (seconds < 3600) return qsTr("%1m").arg(Math.floor(seconds / 60))
        if (seconds < 86400) return qsTr("%1h").arg(Math.floor(seconds / 3600))
        if (seconds < 604800) return qsTr("%1d").arg(Math.floor(seconds / 86400))
        return date.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Label {
            Layout.fillWidth: true
            Layout.margins: 16
            text: qsTr("Activity")
            font.pixelSize: 18
            font.bold: true
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: ActivityFeed
            ScrollBar.vertical: ScrollBar {}

            delegate: ItemDelegate {
                id: row
                required property Server server
                required property var activityId
                required property string summary
                required property string actorName
                required property string path
                required property date createdAt
                required property bool viewed

                width: list.width
                padding: 12
                leftPadding: 16
                rightPadding: 16

                contentItem: RowLayout {
                    spacing: 10

                    Rectangle {
                        Layout.alignment: Qt.AlignTop
                        Layout.topMargin: 6
                        Layout.preferredWidth: 8
                        Layout.preferredHeight: 8
                        radius: 4
                        color: row.viewed ? "transparent" : palette.highlight
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            Layout.fillWidth: true
                            text: row.summary
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            font.bold: !row.viewed
                        }
                        Label {
                            Layout.fillWidth: true
                            text: [row.actorName, row.server.host, pane.since(row.createdAt)].filter(part => part).join(" · ")
                            elide: Text.ElideRight
                            opacity: 0.65
                            font.pixelSize: 12
                        }
                    }
                }

                onClicked: {
                    ServerList.selectServer(row.server)
                    row.server.open(row.path)
                    row.server.markViewed(row.activityId)
                    pane.itemOpened()
                }
            }

            Label {
                anchors.centerIn: parent
                width: parent.width - 48
                visible: list.count === 0
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                opacity: 0.6
                text: qsTr("New activity from all your Loomio hosts appears here.")
            }
        }
    }
}
