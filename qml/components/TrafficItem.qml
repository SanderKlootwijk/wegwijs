/*
* Copyright (C) 2023  Sander Klootwijk
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; version 3.
*
* wegwijs is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

ListItem {
    id: trafficItem
    
    height: visible ? units.gu(5) : 0

    property bool expanded: trafficListView.expandedIndex == index

    expansion.height: units.gu(5) + trafficRow.height
    expansion.expanded: trafficListView.expandedIndex == index

    highlightColor: "transparent"
    
    onClicked: {
        if (trafficListView.expandedIndex == index) {
            trafficListView.expandedIndex = -1
        }
        else {
            trafficListView.expandedIndex = index
            expandConnector.enabled = true
        }
    }

    Connections {
        id: expandConnector

        target: trafficItem
        enabled: false
        
        onHeightChanged: {
            if (trafficItem.height == expansion.height) {
                trafficListView.positionViewAtIndex(trafficListView.expandedIndex, ListView.Contain)
                enabled = false
            }
        }
    }

    Item {
        id: roadItem

        width: parent.width
        height: units.gu(5)

        LomiriShape {
            id: roadShape
            height: units.gu(3)
            width: units.gu(5.5)

            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                top: parent.top
                topMargin: units.gu(1)
            }

            backgroundColor: getRoadColor(roadNumber)

            aspect: LomiriShape.Flat

            Label {
                id: roadLabel

                anchors.centerIn: parent
                
                font.bold: true
                
                text: roadNumber
            }
        }

        Row {
            height: units.gu(3)
            
            anchors {
                left: roadShape.right
                leftMargin: units.gu(2.5)
                top: parent.top
                topMargin: units.gu(1)
            }

            spacing: units.gu(2.5)

            Item {
                id: obstructionType4Item

                height: units.gu(3)
                width: obstructionType4Image.width + obstructionType4Label.contentWidth + units.gu(1)

                visible: obstructionType4Count > 0

                Image {
                    id: obstructionType4Image
                    
                    height: units.gu(2.5)

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }

                    source: "../img/4.png"

                    fillMode: Image.PreserveAspectFit
                }

                Label {
                    id: obstructionType4Label

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    text: obstructionType4Count

                    font.bold: true
                }

                ColorOverlay {
                    anchors.fill: obstructionType4Image

                    source: obstructionType4Image

                    color: theme.palette.normal.foregroundText
                }
            }

            Item {
                id: obstructionType7Item

                height: units.gu(3)
                width: obstructionType7Image.width + obstructionType7Label.contentWidth + units.gu(1)

                visible: obstructionType7Count > 0

                Image {
                    id: obstructionType7Image
                    
                    height: units.gu(2.5)

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }

                    source: "../img/7.png"

                    fillMode: Image.PreserveAspectFit
                }

                Label {
                    id: obstructionType7Label

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    text: obstructionType7Count

                    font.bold: true
                }

                ColorOverlay {
                    anchors.fill: obstructionType7Image

                    source: obstructionType7Image

                    color: theme.palette.normal.foregroundText
                }
            }

            Item {
                id: obstructionType1Item

                height: units.gu(3)
                width: obstructionType1Image.width + obstructionType1Label.contentWidth + units.gu(0.75)

                visible: obstructionType1Count > 0

                Image {
                    id: obstructionType1Image
                    
                    height: units.gu(2.5)

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }

                    source: "../img/1.png"

                    fillMode: Image.PreserveAspectFit
                }

                Label {
                    id: obstructionType1Label

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    text: obstructionType1Count

                    font.bold: true
                }

                ColorOverlay {
                    anchors.fill: obstructionType1Image

                    source: obstructionType1Image

                    color: theme.palette.normal.foregroundText
                }
            }
        }

        Icon {
            id: expandIcon

            height: units.gu(2.5)
            width: units.gu(2.5)

            name: expansion.expanded ? 'up' : 'next'
            
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: units.gu(2)
            }
        }

        Rectangle {
            z: -1

            anchors.fill: parent

            color: trafficItem.highlighted ? theme.palette.focused.base : "transparent"
        }

        Rectangle {
            width: parent.width
            height: units.dp(1)

            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

            color: theme.palette.normal.base
        }
    }

    Column {
        id: trafficRow

        width: parent.width

        anchors.top: roadItem.bottom

        Repeater {
            id: repeater

            model: attributes

            delegate: ListItem {
                width: parent.width
                height: units.gu(2.5) + titleLabel.contentHeight + descriptionLabel.contentHeight

                MouseArea {
                    z: 1
                    
                    anchors.fill: parent
                }

                Item {
                    id: iconItem
                    height: units.gu(3)
                    width: units.gu(5.5)

                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        top: parent.top
                        topMargin: units.gu(1)
                    }

                    Image {
                        id: iconImage
                        
                        height: units.gu(2.5)

                        anchors.centerIn: parent

                        source: "../img/" + obstructionType + ".png"

                        fillMode: Image.PreserveAspectFit
                    }

                    ColorOverlay {
                        anchors.fill: iconImage

                        source: iconImage

                        color: theme.palette.normal.foregroundText
                    }
                }

                Label {
                    id: titleLabel

                    width: parent.width - iconItem.width - delayShape.width - timeShape.width - units.gu(6)

                    anchors {
                        left: iconItem.right
                        leftMargin: units.gu(1)
                        top: parent.top
                        topMargin: units.gu(1)
                    }
                            
                    text: directionText

                    //elide: Text.ElideRight
                    wrapMode: Text.WordWrap

                    font.bold: true
                }

                Label {
                    id: descriptionLabel
                    
                    width: parent.width - iconItem.width - units.gu(5)
                            
                    anchors {
                        left: iconItem.right
                        leftMargin: units.gu(1)
                        top: titleLabel.bottom
                    }
                    
                    text: {
                        if (obstructionType == 4) {
                            title + ". " + locationText
                        }
                        else if (obstructionType == 1) {
                            if (description.length > 1) {
                                title + ". " + description + "<br><br>" + timeEnd + "."
                            }
                            else {
                                title + ". " + locationText + "<br><br>" + timeEnd + "."
                            }
                        }
                        else if (obstructionType == 7) {
                            title + cause + ". " + locationText
                        }
                    }

                    wrapMode: Text.WordWrap
                    textFormat: Text.StyledText
                    color: theme.palette.normal.backgroundSecondaryText
                }

                LomiriShape {
                    id: delayShape
                    height: units.gu(2)
                    width: {
                        if (delay > 0) {
                            delayLabel.contentWidth + units.gu(1)
                        }
                        else {
                            0
                        }
                    }

                    anchors {
                        left: titleLabel.right
                        leftMargin: -(titleLabel.width - titleLabel.contentWidth) + units.gu(0.5)
                        top: titleLabel.top
                        topMargin: units.gu(0.15)
                    }

                    backgroundColor: {
                        if (delay >= 0 && delay <= 15) {
                            "#FFB400"
                        } else if (delay > 15 && delay <= 30) {
                            "#FF6600"
                        } else {
                            "#FF4500"
                        }
                    }

                    aspect: LomiriShape.Flat

                    Label {
                        id: delayLabel

                        anchors {
                            centerIn: parent
                        }

                        font.bold: true
                                    
                        text: {
                            if (delay > 0) {
                                delay + " min"
                            }
                            else {
                                ""
                            }
                        }
                    }

                }

                LomiriShape {
                    id: timeShape
                    height: units.gu(2)
                    width: {
                        if (delay > 0) {
                            timeLabel.contentWidth + units.gu(1)
                        }
                        else {
                            0
                        }
                    }

                    anchors {
                        left: delayShape.right
                        leftMargin: units.gu(0.5)
                        top: titleLabel.top
                        topMargin: units.gu(0.15)
                    }

                    backgroundColor: theme.palette.normal.base

                    aspect: LomiriShape.Flat

                    Label {
                        id: timeLabel

                        anchors {
                            centerIn: parent
                        }

                        font.bold: true
                                    
                        text: {
                            if (delay > 0) {
                                length + " km"
                            }
                            else {
                                ""
                            }
                        }
                    }

                }
            }
        }
    }
}