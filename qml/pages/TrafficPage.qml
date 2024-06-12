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
import "../components"

Page {
    id: trafficPage
    
    property alias trafficListView: trafficListView
    property alias loadingIndicator: loadingIndicator

    header: PageHeader {
        id: trafficPageHeader
        title: i18n.tr("Wegwijs")
        subtitle: i18n.tr("Traffic Conditions")

        leadingActionBar.actions: [
            Action {
                text: i18n.tr("Back")
                iconName: "previous"
                onTriggered: {
                    trafficListView.expandedIndex = -1
                    pageStack.removePages(trafficPage)
                }
            }
        ]
    }

    Item {
        id: buttonsItem

        width: parent.width
        height: units.gu(6)

        anchors {
            top: trafficPageHeader.bottom
            horizontalCenter: parent.horizontalCenter
        }

        Row {
            anchors.centerIn: parent
            
            spacing: units.gu(4)

            MouseArea {
                width: units.gu(6)
                height: units.gu(6)

                visible: root.trafficProvider.hasJams

                Image {
                    id: jamsImage
                    
                    height: units.gu(3)

                    anchors.centerIn: parent

                    source: "../img/jams.png"

                    fillMode: Image.PreserveAspectFit
                }

                ColorOverlay {
                    anchors.fill: jamsImage

                    source: jamsImage

                    color: settings.showJams ? theme.palette.normal.foregroundText : theme.palette.normal.base
                }
                
                onClicked: {  
                    trafficListView.expandedIndex = -1

                    settings.showJams ? settings.showJams = false : settings.showJams = true
                    
                    root.trafficProvider.getTrafficData()
                }
            }

            MouseArea {
                width: units.gu(6)
                height: units.gu(6)

                visible: root.trafficProvider.hasClosures
                
                Image {
                    id: closuresImage
                    
                    height: units.gu(3)

                    anchors.centerIn: parent

                    source: "../img/closures.png"

                    fillMode: Image.PreserveAspectFit
                }

                ColorOverlay {
                    anchors.fill: closuresImage

                    source: closuresImage

                    color: settings.showClosures ? theme.palette.normal.foregroundText : theme.palette.normal.base
                }
                
                onClicked: {
                    trafficListView.expandedIndex = -1

                    settings.showClosures ? settings.showClosures = false : settings.showClosures = true
                    
                    root.trafficProvider.getTrafficData()
                }
            }

            MouseArea {
                width: units.gu(6)
                height: units.gu(6)

                visible: root.trafficProvider.hasRoadworks
                
                Image {
                    id: roadworksImage
                    
                    height: units.gu(3)

                    anchors.centerIn: parent

                    source: "../img/roadworks.png"

                    fillMode: Image.PreserveAspectFit
                }

                ColorOverlay {
                    anchors.fill: roadworksImage

                    source: roadworksImage

                    color: settings.showRoadworks ? theme.palette.normal.foregroundText : theme.palette.normal.base
                }
                
                onClicked: {
                    trafficListView.expandedIndex = -1

                    settings.showRoadworks ? settings.showRoadworks = false : settings.showRoadworks = true
                    
                    root.trafficProvider.getTrafficData()
                }
            }

            MouseArea {
                width: units.gu(6)
                height: units.gu(6)

                visible: root.trafficProvider.hasSpeedcameras
                
                Image {
                    id: speedcamerasImage
                    
                    height: units.gu(3)

                    anchors.centerIn: parent

                    source: "../img/speedcameras.png"

                    fillMode: Image.PreserveAspectFit
                }

                ColorOverlay {
                    anchors.fill: speedcamerasImage

                    source: speedcamerasImage

                    color: settings.showSpeedcameras ? theme.palette.normal.foregroundText : theme.palette.normal.base
                }
                
                onClicked: {
                    trafficListView.expandedIndex = -1

                    settings.showSpeedcameras ? settings.showSpeedcameras = false : settings.showSpeedcameras = true
                    
                    root.trafficProvider.getTrafficData()
                }
            }
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

    Item {
        id: feedListItem

        anchors {
            fill: parent
            topMargin: trafficPageHeader.height + buttonsItem.height
        }

        Scrollbar {
            z: 1
            flickableItem: trafficListView
            align: Qt.AlignTrailing
        }

        ActivityIndicator {
            id: loadingIndicator
            running: root.trafficProvider.loading

            anchors {
                centerIn: parent
            }
        }

        Label {
            width: parent.width - units.gu(8)

            visible: !loadingIndicator.running

            anchors {
                top: parent.top
                topMargin: units.gu(5)
                horizontalCenter: parent.horizontalCenter
            }

            text: {
                if (!settings.showRoadworks && !settings.showJams && !settings.showClosures && !settings.showSpeedcameras) {
                    i18n.tr("Select options above to show reports")
                }
                else if (trafficListModel.count == 0) {
                    i18n.tr("No reports found")
                }
                else {
                    ""
                }
            }

            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        ListView {
            id: trafficListView

            visible: !loadingIndicator.running

            property int expandedIndex: -1

            anchors.fill: parent

            model: trafficListModel
            clip: true
            delegate: TrafficItem {}
        }
    }

    Component.onCompleted: root.trafficProvider.getTrafficData()
}