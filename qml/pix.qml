import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0

Window {
    id: window

    property var jsonData: ({})
    property var activeRegion: regions.length > 0 ? regions[regionIndex] : undefined
    property var regions: []
    property var colors
    property int regionSize: 29
    property int regionIndex: 0
    property int gridWidth: jsonData.hasOwnProperty("width") && !switchRegions.checked ? jsonData.width : regionSize
    property int gridHeight: jsonData.hasOwnProperty("height") && !switchRegions.checked ? jsonData.height : regionSize

    visible: true
    width: 640
    height: 720

    Settings {
        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height
        property alias textData: textFieldData.text
        property alias borders: switchBorders.checked
        property alias regions: switchRegions.checked
        property alias index: switchIndex.checked
    }

    ColorDialog {
        id: colorDialog

        property int colorIndex: -1

        title: qsTr("Please choose a color")

        onAccepted: {
            var c = colors
            c[colorIndex] = color.toString()
            colors = c
            colorIndex = -1
        }
    }

    ColumnLayout {
        id: columnLayout

        anchors {
            left: parent.left
            right: parent.right
            margins: 10
        }

        spacing: 10

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

                text: "Borders:"
            }

            Switch {
                id: switchBorders
            }

            Label {
                anchors.verticalCenter: parent.verticalCenter

                text: "Regions:"
            }

            Switch {
                id: switchRegions
            }

            Button {
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Next")
                visible: switchRegions.checked
                z: 2

                onClicked: {
                    if (regionIndex < regions.length - 1) {
                        regionIndex = regionIndex + 1
                    } else {
                        regionIndex = 0
                    }
                }
            }

            Label {
                anchors.verticalCenter: parent.verticalCenter

                text: "Index:"
            }

            Switch {
                id: switchIndex
            }

            Label {
                anchors.verticalCenter: parent.verticalCenter

                text: "Colors:"
            }

            TextField {
                anchors.verticalCenter: parent.verticalCenter
                readOnly: true

                text: colors !== undefined ? colors.length : ""
            }

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

                onTextChanged: {
                    try {
                        JSON.parse(textFieldData.text)
                        action()
                    } catch (e){

                    }
                }
            }

            Button {
                id: button

                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Process")

                onClicked: {
                    jsonData = JSON.parse(textFieldData.text)

                    var offsetX = 0
                    var offsetY = 0

                    var totalRegions = []

                    while (offsetX < gridHeight) {
                        var processedData = []

                        for (var i = 0; i < regionSize; ++i) {
                            if (processedData[i] === undefined)
                                processedData[i] = []

                            for (var j = 0; j < regionSize; ++j) {
                                processedData[i][j] = 0
                            }
                        }

                        for (i = offsetY; i < offsetY + regionSize && i < gridHeight; ++i) {
                            for (j = offsetX; j < offsetX + regionSize && j < gridWidth; ++j) {
                                processedData[i - offsetY][j - offsetX] = jsonData.data[i][j]
                            }
                        }

                        totalRegions.push(processedData)
                        offsetY += regionSize

                        if (offsetY > gridWidth && offsetX < gridHeight) {
                            offsetY = 0;
                            offsetX += regionSize;
                        }

                        regions = totalRegions
                    }

                    colors = jsonData.colors
                }
            }
        }

        Flow {
            Layout.fillWidth: true

            spacing: 2

            Repeater {
                model: colors

                Rectangle {
                    height: 18
                    width: 18

                    border {
                        width: 1
                        color: "#000000"
                    }

                    color: modelData

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            colorDialog.colorIndex = index
                            colorDialog.open()
                        }
                    }
                }
            }
        }
    }

    Item {
        anchors {
            top: columnLayout.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 10
        }

        GridView {
            id: gridView

            property int size: Math.min(Math.floor(parent.width / gridWidth), Math.floor(parent.height / gridHeight))
            property var gridData: switchRegions.checked ? activeRegion : jsonData.data

            width: size * gridWidth
            height: size * gridHeight

            interactive: false
            model: gridWidth * gridHeight
            cellHeight: height / gridHeight
            cellWidth: width / gridWidth

            delegate: Rectangle {
                border {
                    color: "#000000"
                    width: switchBorders.checked ? 1 : 0
                }

                height: GridView.view.cellHeight
                width: GridView.view.cellWidth

                color: (colors !== undefined && gridView.gridData !== undefined && gridView.gridData[Math.floor(index / gridWidth)] !== undefined) ? colors[gridView.gridData[Math.floor(index / gridWidth)][index - (Math.floor(index / gridWidth) * gridWidth)]] || "#ffffff"
                                                                                                                                                   : "#ffffff"

                Label {
                    anchors.fill: parent

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    visible: switchIndex.checked
                    fontSizeMode: Text.Fit
                    font.pixelSize: 11
                    text: Math.floor(index / gridWidth) + "x" + (index - (Math.floor(index / gridWidth) * gridWidth))
                }
            }
        }
    }
}
