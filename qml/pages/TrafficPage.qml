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

                Image {
                    id: icon4Image
                    
                    height: units.gu(3)

                    anchors.centerIn: parent

                    source: "../img/4.png"

                    fillMode: Image.PreserveAspectFit
                }

                ColorOverlay {
                    anchors.fill: icon4Image

                    source: icon4Image

                    color: settings.obstructionType4 ? theme.palette.normal.foregroundText : theme.palette.normal.base
                }
                
                onClicked: {  
                    trafficListView.expandedIndex = -1

                    settings.obstructionType4 ? settings.obstructionType4 = false : settings.obstructionType4 = true
                    
                    var newObstructionTypes = []

                    if (settings.obstructionType1) {
                        newObstructionTypes.push(1)
                    }
                    if (settings.obstructionType4) {
                        newObstructionTypes.push(4)
                    }
                    if (settings.obstructionType7) {
                        newObstructionTypes.push(7)
                    }

                    root.obstructionTypes = newObstructionTypes

                    getTrafficData()
                }
            }

            MouseArea {
                width: units.gu(6)
                height: units.gu(6)
                
                Image {
                    id: icon7Image
                    
                    height: units.gu(3)

                    anchors.centerIn: parent

                    source: "../img/7.png"

                    fillMode: Image.PreserveAspectFit
                }

                ColorOverlay {
                    anchors.fill: icon7Image

                    source: icon7Image

                    color: settings.obstructionType7 ? theme.palette.normal.foregroundText : theme.palette.normal.base
                }
                
                onClicked: {
                    trafficListView.expandedIndex = -1

                    settings.obstructionType7 ? settings.obstructionType7 = false : settings.obstructionType7 = true
                    
                    var newObstructionTypes = []

                    if (settings.obstructionType1) {
                        newObstructionTypes.push(1)
                    }
                    if (settings.obstructionType4) {
                        newObstructionTypes.push(4)
                    }
                    if (settings.obstructionType7) {
                        newObstructionTypes.push(7)
                    }

                    root.obstructionTypes = newObstructionTypes

                    getTrafficData()
                }
            }

            MouseArea {
                width: units.gu(6)
                height: units.gu(6)
                
                Image {
                    id: icon1Image
                    
                    height: units.gu(3)

                    anchors.centerIn: parent

                    source: "../img/1.png"

                    fillMode: Image.PreserveAspectFit
                }

                ColorOverlay {
                    anchors.fill: icon1Image

                    source: icon1Image

                    color: settings.obstructionType1 ? theme.palette.normal.foregroundText : theme.palette.normal.base
                }
                
                onClicked: {
                    trafficListView.expandedIndex = -1

                    settings.obstructionType1 ? settings.obstructionType1 = false : settings.obstructionType1 = true
                    
                    var newObstructionTypes = []

                    if (settings.obstructionType1) {
                        newObstructionTypes.push(1)
                    }
                    if (settings.obstructionType4) {
                        newObstructionTypes.push(4)
                    }
                    if (settings.obstructionType7) {
                        newObstructionTypes.push(7)
                    }

                    root.obstructionTypes = newObstructionTypes

                    getTrafficData()
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
            running: true
            visible: root.trafficLoading

            anchors {
                centerIn: parent
            }
        }

        Label {
            width: parent.width - units.gu(8)

            visible: !loadingIndicator.visible

            anchors {
                top: parent.top
                topMargin: units.gu(5)
                horizontalCenter: parent.horizontalCenter
            }

            text: {
                if (!settings.obstructionType1 && !settings.obstructionType4 && !settings.obstructionType7) {
                    i18n.tr("Select traffic jams, road closures, or roadworks from the options above")
                }
                else if (trafficListModel.count == 0) {
                    if (settings.obstructionType4 && !settings.obstructionType7 && !settings.obstructionType1) {
                        i18n.tr("No traffic jams found")
                    }
                    else if (!settings.obstructionType4 && settings.obstructionType7 && !settings.obstructionType1) {
                        i18n.tr("No road closures found")
                    }
                    else if (!settings.obstructionType4 && !settings.obstructionType7 && settings.obstructionType1) {
                        i18n.tr("No roadworks found")
                    }
                    else if (settings.obstructionType4 && settings.obstructionType7 && !settings.obstructionType1) {
                        i18n.tr("No traffic jams or road closures found")
                    }
                    else if (settings.obstructionType4 && !settings.obstructionType7 && settings.obstructionType1) {
                        i18n.tr("No traffic jams or roadworks found")
                    }
                    else if (!settings.obstructionType4 && settings.obstructionType7 && settings.obstructionType1) {
                        i18n.tr("No road closures or roadworks found")
                    }
                    else if (settings.obstructionType4 && settings.obstructionType7 && settings.obstructionType1) {
                        i18n.tr("No traffic jams, road closures or roadworks found")
                    }
                    else {
                        ""
                    }
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

            visible: !loadingIndicator.visible

            property int expandedIndex: -1

            anchors.fill: parent

            model: trafficListModel
            clip: true
            delegate: TrafficItem {}
        }
    }

    Component.onCompleted: {
        var newObstructionTypes = []

        if (settings.obstructionType1) {
            newObstructionTypes.push(1)
        }
        if (settings.obstructionType4) {
            newObstructionTypes.push(4)
        }
        if (settings.obstructionType7) {
            newObstructionTypes.push(7)
        }

        root.obstructionTypes = newObstructionTypes

        getTrafficData()
    }
}