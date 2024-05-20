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
import QtWebEngine 1.6
import QtWebChannel  1.0
import "../components"

Page {
    id: resultPage

    property alias resultPageHeader: resultPageHeader
    property alias qtObject: qtObject
    property alias webEngineView: webEngineView
    property alias fuelpriceLabel: fuelpriceLabel
    property alias adressLabel: adressLabel
    property alias infoFlickable: infoFlickable
    property var connectionsData

    Component.onCompleted: {
        myWebChannel.registerObject("qtObject",qtObject);   
    }

    header: PageHeader {
        id: resultPageHeader

        leadingActionBar.actions: [
            Action {
                iconName: "back"
                onTriggered: {
                    infoFlickable.expanded = false
                    adaptivePageLayout.removePages(resultPage)
                }
            }
        ]
    }

    WebChannel {
        id: myWebChannel
    }

    QtObject {
        id: qtObject

        signal onRefresh()

        property var latitude
        property var longitude

        onLongitudeChanged: onRefresh()
        onLatitudeChanged: onRefresh()
    }

    Flickable {
        id: infoFlickable

        z: 2

        property bool expanded: false

        width: parent.width
        height: {
            if (expanded) {
                contentHeight
            }
            else {
                if (contentHeight > units.gu(14)) {
                    units.gu(13)
                }
                else {
                    contentHeight
                }
            }
        }

        anchors {
            top: resultPageHeader.bottom
            horizontalCenter: parent.horizontalCenter
        }

        contentWidth: infoColumn.width
        contentHeight: infoColumn.height
        
        clip: true
        
        Column {
            id: infoColumn

            width: resultPage.width

            Repeater {
                model: connectionsData

                delegate: ConnectionItem {}
            }

            ListItem {
                z: 1

                id: fuelPriceItem
                
                width: parent.width
                height: units.gu(6.5)

                visible: settings.fuelType != 4

                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: fuelTypeImage

                    width: units.gu(3.5)
                    height: units.gu(3.5)

                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }

                    source: "../img/" + settings.fuelType + ".svg"
                    smooth: true
                }

                Label {
                    id: fuelTypeLabel

                    width: parent.width - fuelTypeImage.width - fuelpriceLabel.width - units.gu(5)

                    anchors {
                        left: fuelTypeImage.right
                        leftMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }

                    text: {
                        if (settings.fuelType == 0) {
                            "Euro 95"
                        }
                        else if (settings.fuelType == 1) {
                            "Euro 98"
                        }
                        else if (settings.fuelType == 2) {
                            "Diesel"
                        }
                        else if (settings.fuelType == 3) {
                            "LPG"
                        }
                        else if (settings.fuelType == 4) {
                            i18n.tr("Electric")
                        }
                    }

                    elide: Text.ElideRight
                }

                Label {
                    id: fuelpriceLabel

                    width: contentWidth

                    anchors {
                        right: parent.right
                        rightMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    Rectangle {
        z: 1

        anchors.fill: infoFlickable

        color: theme.palette.normal.background
    }

    Rectangle {
        z: 1

        width: parent.width
        height: units.dp(1)

        anchors {
            bottom: infoFlickable.bottom
            horizontalCenter: parent.horizontalCenter
        }

        color: theme.palette.normal.base
    }

    Rectangle {
        id: expandItem

        z: 1
        
        width: parent.width
        height: infoFlickable.contentHeight > units.gu(14) ? units.gu(3) : 0
        
        anchors {
            top: infoFlickable.bottom
            horizontalCenter: parent.horizontalCenter
        }

        visible: infoFlickable.contentHeight > units.gu(14)

        color: theme.palette.normal.background

        MouseArea {
            anchors.fill: parent

            onClicked: infoFlickable.expanded ? infoFlickable.expanded = false : infoFlickable.expanded = true
        }

        Icon {
            width: units.gu(2)
            height: units.gu(2)
            
            anchors.centerIn: parent
            
            name: infoFlickable.expanded ? "up" : "down"
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

    DropShadow {
        z: 1
        visible: infoFlickable.expanded
        anchors.fill: expandItem
        horizontalOffset: 0
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#777777"
        source: expandItem
    }

    WebEngineView {
        id: webEngineView

        anchors {
            fill: parent
            topMargin: infoFlickable.contentHeight > units.gu(14) ? resultPageHeader.height + units.gu(16) : resultPageHeader.height + infoFlickable.height
            bottomMargin: adressItem.height + units.gu(2.5)
        }

        webChannel: myWebChannel
        
        url: "../webview/index.html"

        onNavigationRequested: function(request) {
            if (request.navigationType === WebEngineNavigationRequest.LinkClickedNavigation) {
                Qt.openUrlExternally(request.url)
                request.action = WebEngineNavigationRequest.IgnoreRequest
            }
        }

    }

    Rectangle {
        width: parent.width
        height: units.dp(1)

        anchors {
            top: webEngineView.bottom
            horizontalCenter: parent.horizontalCenter
        }

        color: theme.palette.normal.base
    }

    Item {
        id: adressItem

        width: parent.width - units.gu(4)
        height: units.gu(4)

        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(1.25)
            horizontalCenter: parent.horizontalCenter
        }

        Label {
            id: adressLabel

            width: parent.width - navButton.width - units.gu(2)

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }

            elide: Text.ElideRight
        }

        Button {
            id: navButton

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }

            text: i18n.tr("Navigate")
            strokeColor: theme.palette.normal.baseText

            onClicked: {
                Qt.openUrlExternally("geo:"+qtObject.latitude+","+qtObject.longitude)
            }
        }
    }
}