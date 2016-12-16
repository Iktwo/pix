import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Window {
    visible: true
    width: 640
    height: 720

    property var jsonData: ({})
    property var colors
    property int gridWidth: 0
    property int gridHeight: 0

    RowLayout {
        id: rowData

        anchors {
            left: parent.left
            right: parent.right
            margins: 10
        }

        spacing: 10

        Label {
            anchors.verticalCenter: parent.verticalCenter

            text: "Size:"
        }

        TextField {
            id: textFieldWidth

            anchors.verticalCenter: parent.verticalCenter
            readOnly: true

            text: gridWidth + "x" + gridHeight
        }

        Label {
            anchors.verticalCenter: parent.verticalCenter

            text: "Data:"
        }

        TextField {
            id: textFieldData

            function action() {
                button.clicked()
            }

            anchors.verticalCenter: parent.verticalCenter

            placeholderText: "data"

            focus: true

            Keys.onEnterPressed: action()
            Keys.onReturnPressed: action()
        }

        Button {
            id: button

            anchors.verticalCenter: parent.verticalCenter

            text: "Process"

            onClicked: {
                try {
                    jsonData = JSON.parse(textFieldData.text)

                    gridWidth = jsonData.width
                    gridHeight = jsonData.height
                    colors = jsonData.colors
                } catch (e){

                }
            }
        }
    }

    Item {
        anchors {
            top: rowData.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 10
        }

        GridView {
            id: gridView

            property int size: Math.min(Math.floor(parent.width / gridWidth), Math.floor(parent.height / gridHeight))

            width: size * gridWidth
            height: size * gridHeight

            model: gridWidth * gridHeight
            cellHeight: height / gridHeight
            cellWidth: width / gridWidth

            delegate: Rectangle {
                border {
                    color: "black"
                    width: 1
                }

                height: GridView.view.cellHeight
                width: GridView.view.cellWidth

                color: (colors !== undefined) ? colors[jsonData.data[Math.floor(index / gridWidth)][index - (Math.floor(index / gridWidth) * gridWidth)]]
                                              : "#ffffff"
            }
        }
    }
}
