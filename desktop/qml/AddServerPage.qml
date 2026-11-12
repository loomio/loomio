import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Loomio

Pane {
    id: page

    property bool canCancel

    signal finished()

    function submit() {
        const error = ServerList.addServer(address.text)
        message.text = error
        if (error.length === 0) {
            address.clear()
            page.finished()
        }
    }

    onVisibleChanged: if (visible) address.forceActiveFocus()

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 440)
        spacing: 14

        Label {
            Layout.fillWidth: true
            text: qsTr("Add a Loomio host")
            font.pixelSize: 24
            font.bold: true
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            opacity: 0.75
            text: qsTr("Enter the address you use to open Loomio in your browser, such as loomio.com or your organization's own Loomio.")
        }

        TextField {
            id: address
            Layout.fillWidth: true
            placeholderText: "loomio.com"
            inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoAutoUppercase
            onAccepted: page.submit()
            onTextEdited: message.text = ""
        }

        Label {
            id: message
            Layout.fillWidth: true
            visible: text.length > 0
            wrapMode: Text.Wrap
            color: "#d93025"
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 12

            Button {
                visible: page.canCancel
                text: qsTr("Cancel")
                onClicked: page.finished()
            }
            Button {
                highlighted: true
                enabled: address.text.trim().length > 0
                text: qsTr("Continue")
                onClicked: page.submit()
            }
        }
    }
}
