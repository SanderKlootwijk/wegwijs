/*
* Copyright (C) 2024  Sander Klootwijk
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
            width: roadNumber.length > 4 ? roadLabel.contentWidth + units.gu(1.25) : units.gu(5.5)

            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                top: parent.top
                topMargin: units.gu(1)
            }

            backgroundColor: roadColor

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
                id: jamsItem

                height: units.gu(3)
                width: jamsImage.width + jamsLabel.contentWidth + units.gu(1)

                visible: root.trafficProvider.hasJams ? jamsCount > 0 : false

                Image {
                    id: jamsImage
                    
                    height: units.gu(2.5)

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }

                    source: "../img/jams.png"

                    fillMode: Image.PreserveAspectFit
                }

                Label {
                    id: jamsLabel

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    text: root.trafficProvider.hasJams ? jamsCount : ""

                    font.bold: true
                }

                ColorOverlay {
                    anchors.fill: jamsImage

                    source: jamsImage

                    color: theme.palette.normal.foregroundText
                }
            }

            Item {
                id: closuresItem

                height: units.gu(3)
                width: closuresImage.width + closuresLabel.contentWidth + units.gu(1)

                visible: root.trafficProvider.hasClosures ? closuresCount > 0 : false

                Image {
                    id: closuresImage
                    
                    height: units.gu(2.5)

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }

                    source: "../img/closures.png"

                    fillMode: Image.PreserveAspectFit
                }

                Label {
                    id: closuresLabel

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    text: root.trafficProvider.hasClosures ? closuresCount : ""

                    font.bold: true
                }

                ColorOverlay {
                    anchors.fill: closuresImage

                    source: closuresImage

                    color: theme.palette.normal.foregroundText
                }
            }

            Item {
                id: roadworksItem

                height: units.gu(3)
                width: roadworksImage.width + roadworksLabel.contentWidth + units.gu(0.75)

                visible: root.trafficProvider.hasRoadworks ? roadworksCount > 0 : false

                Image {
                    id: roadworksImage
                    
                    height: units.gu(2.5)

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }

                    source: "../img/roadworks.png"

                    fillMode: Image.PreserveAspectFit
                }

                Label {
                    id: roadworksLabel

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    text: root.trafficProvider.hasRoadworks ? roadworksCount : ""

                    font.bold: true
                }

                ColorOverlay {
                    anchors.fill: roadworksImage

                    source: roadworksImage

                    color: theme.palette.normal.foregroundText
                }
            }

            Item {
                id: speedcamerasItem

                height: units.gu(3)
                width: speedcamerasImage.width + speedcamerasLabel.contentWidth + units.gu(0.75)

                visible: root.trafficProvider.hasSpeedcameras ? speedcamerasCount > 0 : false

                Image {
                    id: speedcamerasImage
                    
                    height: units.gu(2.5)

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }

                    source: "../img/speedcameras.png"

                    fillMode: Image.PreserveAspectFit
                }

                Label {
                    id: speedcamerasLabel

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    text: root.trafficProvider.hasSpeedcameras ? speedcamerasCount : ""

                    font.bold: true
                }

                ColorOverlay {
                    anchors.fill: speedcamerasImage

                    source: speedcamerasImage

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
                height: information.length > 0 ? units.gu(2.5) + titleLabel.contentHeight + descriptionLabel.contentHeight + informationShape.height + units.gu(1.25) : units.gu(2.5) + titleLabel.contentHeight + descriptionLabel.contentHeight

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
                            
                    text: direction

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
                    
                    text: description

                    wrapMode: Text.WordWrap
                    textFormat: Text.StyledText
                    color: theme.palette.normal.backgroundSecondaryText
                }

                LomiriShape {
                    id: informationShape

                    height: information.length > 0 ? units.gu(2): 0
                    width: information.length > 0 ? informationLabel.contentWidth + units.gu(1) : 0
                    
                    anchors {
                        left: iconItem.right
                        leftMargin: units.gu(1)
                        top: descriptionLabel.bottom
                        topMargin: units.gu(1.25)
                    }

                    backgroundColor: informationColor

                    aspect: LomiriShape.Flat

                    Label {
                        id: informationLabel

                        anchors {
                            centerIn: parent
                        }

                        font.bold: true
                                    
                        text: information
                    }
                }

                LomiriShape {
                    id: delayShape

                    height: units.gu(2)
                    width: delay > 0 ? delayLabel.contentWidth + units.gu(1) : 0

                    anchors {
                        left: titleLabel.right
                        leftMargin: titleLabel.contentWidth > 0 ? -(titleLabel.width - titleLabel.contentWidth) + units.gu(0.5) : -(titleLabel.width - titleLabel.contentWidth)
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
                    width: delay > 0 ? timeLabel.contentWidth + units.gu(1) : 0

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
                                    
                        text: delay > 0 ? length + " km" : ""
                    }
                }
            }
        }
    }
}