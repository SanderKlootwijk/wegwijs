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
import Lomiri.Connectivity 1.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12
import "../components"

Page {
    id: mainPage

    header: PageHeader {
        id: mainPageHeader
        title: i18n.tr("Wegwijs")

        trailingActionBar {
            visible: !settings.firstRun

            numberOfSlots: 1

            actions: [
                Action {
                    text: i18n.tr("Settings")
                    iconName: "settings"
                    onTriggered: {
                        mainPage.pageStack.addPageToCurrentColumn(mainPage, settingsPage)
                    }
                },
                Action {
                    text: i18n.tr("About")
                    iconName: "info"
                    onTriggered: {
                        mainPage.pageStack.addPageToCurrentColumn(mainPage, aboutPage)
                    }
                }
            ]
        }
    }

    Item {
        id: firstRunItem

        anchors {
            fill: parent
            topMargin: mainPageHeader.height
        }

        visible: {
            if (settings.firstRun == false) {
                false
            }
            else if (Connectivity.status == NetworkingStatus.Offline) {
                false
            }
            else {
                true
            }
        }

        Flickable {
            id: firstRunFlickable

            anchors.fill: parent

            contentWidth: firstRunColumn.width
            contentHeight: firstRunColumn.height

            Column {
                id: firstRunColumn

                property int slide: 0

                width: firstRunItem.width

                anchors {
                    top: parent.top
                    topMargin: units.gu(2)
                    horizontalCenter: parent.horizontalCenter
                }

                spacing: units.gu(1)

                LomiriShape {
                    width: units.gu(15)
                    height: units.gu(15)

                    anchors.horizontalCenter: parent.horizontalCenter

                    source: Image {
                        sourceSize.width: width
                        sourceSize.height: height
                        smooth: true
                        source: "../img/wegwijs.svg"
                    }
                }

                Item {
                    width: parent.width
                    height: units.gu(1)
                }

                Label {
                    width: parent.width - units.gu(4)

                    anchors.horizontalCenter: parent.horizontalCenter

                    text: {
                        if (root.firstRunSlide == 3) {
                            i18n.tr("You're all set!")
                        }
                        else {
                            i18n.tr("Welcome to Wegwijs!")
                        }
                    }
                    wrapMode: Text.WordWrap
                    textSize: Label.Large
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    width: parent.width - units.gu(4)

                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    visible: root.firstRunSlide == 0

                    text: i18n.tr("With Wegwijs, you're always informed about the current traffic conditions and can easily find nearby fuel prices") + "\n\n" + i18n.tr("Please note: Wegwijs currently only supports the Netherlands")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Label {
                    width: parent.width - units.gu(4)

                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    visible: root.firstRunSlide == 1

                    text: i18n.tr("Select a type of fuel below to begin:")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Item {
                    width: parent.width
                    height: units.gu(1)

                    visible: root.firstRunSlide == 1
                }

                OptionSelector {
                    id: firstRunOptionSelector

                    width: root.width > units.gu(60) ? units.gu(56) : parent.width - units.gu(4)

                    anchors.horizontalCenter: parent.horizontalCenter

                    visible: root.firstRunSlide == 1

                    model: ["Euro 95 (E10)", "Euro 98 (E5)", "Diesel (B7)", "LPG"]

                    onSelectedIndexChanged: {
                        settings.fuelType = selectedIndex
                        console.log(settings.fuelType)
                    }

                    expanded: true

                    Component.onCompleted: {
                        if (settings.firstRun) {
                            selectedIndex = 0
                        }
                    }
                    
                }

                Label {
                    width: parent.width - units.gu(4)

                    visible: root.firstRunSlide == 2

                    anchors.horizontalCenter: parent.horizontalCenter

                    text: i18n.tr("Now choose a location to find nearby fuel prices:")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Label {
                    width: parent.width - units.gu(4)

                    visible: root.firstRunSlide == 3

                    anchors.horizontalCenter: parent.horizontalCenter

                    text: i18n.tr("Wegwijs is ready for use, further settings can be found in the menu at the top right of the screen")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                ListItem {
                    width: parent.width
                    height: units.gu(6)

                    visible: root.firstRunSlide == 2

                    onClicked: mainPage.pageStack.addPageToCurrentColumn(mainPage, searchPage)

                    Label {
                        width: parent.width - units.gu(8)

                        anchors {
                            left: parent.left
                            leftMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }

                        text: i18n.tr("Search")
                        elide: Text.ElideRight
                    }

                    Icon {
                        height: units.gu(2.5)
                        width: units.gu(2.5)

                        name: 'next'
                        
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                            rightMargin: units.gu(2)    
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: units.gu(1)

                    visible: root.firstRunSlide == 0 || root.firstRunSlide == 2
                }

                Item {
                    width: root.width > units.gu(60) ? units.gu(56) : parent.width - units.gu(4)
                    height: units.gu(6)

                    anchors.horizontalCenter: parent.horizontalCenter

                    visible: root.firstRunSlide == 0 || root.firstRunSlide == 1 || root.firstRunSlide == 2

                    Button {
                        width: root.firstRunSlide == 2 ? parent.width : parent.width / 2 - units.gu(0.5)

                        visible: root.firstRunSlide == 1 || root.firstRunSlide == 2

                        anchors.left: parent.left
                        
                        text: i18n.tr("Previous")

                        onClicked: root.firstRunSlide == 1 ? root.firstRunSlide = 0 : root.firstRunSlide = 1
                    }

                    Button {
                        width: root.firstRunSlide == 0 ? parent.width : parent.width / 2 - units.gu(0.5)

                        visible: root.firstRunSlide == 0 || root.firstRunSlide == 1

                        anchors.right: parent.right
                        
                        text: i18n.tr("Next")

                        color: theme.palette.normal.positive

                        onClicked: root.firstRunSlide == 0 ? root.firstRunSlide = 1 : root.firstRunSlide = 2
                    }
                }

                Item {
                    width: parent.width
                    height: units.gu(1)

                    visible: root.firstRunSlide == 3
                }

                Button {
                    width: root.width > units.gu(60) ? units.gu(56) : parent.width - units.gu(4)

                    anchors.horizontalCenter: parent.horizontalCenter

                    visible: root.firstRunSlide == 3
                    
                    text: i18n.tr("Close")

                    color: theme.palette.normal.positive

                    onClicked: {
                        settings.firstRun = false
                        getTrafficData()
                        getFuelPrices()
                    }
                }

                Item {
                    width: parent.width
                    height: units.gu(5)
                }
            }
        }
    }

    Item {
        id: offlineItem

        width: parent.width
        height: units.gu(30)

        anchors {
            top: mainPageHeader.bottom
            horizontalCenter: parent.horizontalCenter
        }

        visible: Connectivity.status == NetworkingStatus.Offline

        Icon {
            id: offlineIcon
            
            width: units.gu(3.5)
            height: units.gu(3.5)

            anchors.centerIn: parent

            name: "nm-signal-00"
            color: offlineLabel.color
        }

        Label {
            id: offlineLabel

            width: parent.width - units.gu(4)

            anchors {
                top: offlineIcon.bottom
                topMargin: units.gu(1.5)
                horizontalCenter: parent.horizontalCenter
            }

            text: settings.firstRun ? i18n.tr("You are currently offline") + "\n\n" + i18n.tr("Connect to the internet to set up Wegwijs") : i18n.tr("You are currently offline") + "\n\n" + i18n.tr("Connect to the internet to use Wegwijs")
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Scrollbar {
        z: 1
        id: mainScrollbar
        
        visible: mainFlickable.visible

        flickableItem: mainFlickable
        align: Qt.AlignTrailing
    }

    Flickable {
        id: mainFlickable

        visible: {
            if (settings.firstRun == true) {
                false
            }
            else if (Connectivity.status == NetworkingStatus.Offline) {
                false
            }
            else {
                true
            }
        }

        anchors {
            top: mainPageHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        contentWidth: mainColumn.width
        contentHeight: mainColumn.height

        Column {
            id: mainColumn

            width: mainPage.width

            ListItem {
                id: trafficListItem
                
                width: parent.width

                height: units.gu(9)

                onClicked: {
                    getTrafficData()
                    mainPage.pageStack.addPageToCurrentColumn(mainPage, trafficPage)
                }

                LomiriShape {
                    id: trafficShape

                    height: units.gu(7)
                    width: units.gu(7)

                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }

                    Image {
                        id: trafficImage
                        
                        height: units.gu(3)

                        anchors.centerIn: parent

                        source: "../img/4.png"

                        fillMode: Image.PreserveAspectFit
                    }

                    ColorOverlay {
                        anchors.fill: trafficImage

                        source: trafficImage

                        color: theme.palette.normal.foregroundText
                    }
                    
                    backgroundColor: theme.palette.normal.base

                    aspect: LomiriShape.Flat 
                }

                Item {
                    id: trafficItem

                    width: parent.width - trafficShape.width - units.gu(8.5)
                    height: units.gu(4)

                    anchors {
                        left: trafficShape.right
                        leftMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }

                    Label {
                        id: trafficTitle

                        width: parent.width

                        anchors {
                            left: parent.left
                            top: parent.top
                        }

                        text: {
                            if (root.numberOfJams === -1 || root.trafficLoading == true) {
                                i18n.tr("Loading") + "..."
                            }
                            else if (root.numberOfJams == 0) {
                                root.numberOfJams + " " + i18n.tr("traffic jams")
                            }
                            else if (root.numberOfJams == 1) {
                                root.numberOfJams + " " + i18n.tr("traffic jam")
                            }
                            else {
                                root.numberOfJams + " " + i18n.tr("traffic jams")
                            }
                        }

                        elide: Text.ElideRight
                        font.bold: true
                    }

                    Label {
                        id: trafficSubtitle

                        width: parent.width

                        anchors {
                            left: parent.left
                            bottom: parent.bottom
                        }

                        text: root.totalLengthOfJams == -1 || root.trafficLoading == true ? "" : root.totalLengthOfJams + " " + "km"

                        elide: Text.ElideRight
                    }
                }

                Icon {
                    height: units.gu(2.5)
                    width: units.gu(2.5)

                    name: 'next'
                    
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: units.gu(2)    
                    }
                }  
            }

            ListItem {
                id: fuelListItem
                
                width: parent.width

                height: units.gu(9)

                onClicked: {
                    getFuelPrices()
                    mainPage.pageStack.addPageToCurrentColumn(mainPage, fuelPage)
                }

                FuelShape {
                    id: fuelShape

                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }

                    fuelType: settings.fuelType
                }

                Item {
                    id: fuelItem

                    width: parent.width - fuelShape.width - units.gu(8.5)
                    height: units.gu(4)

                    anchors {
                        left: fuelShape.right
                        leftMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }

                    Label {
                        id: fuelTitle

                        width: parent.width

                        anchors {
                            left: parent.left
                            top: parent.top
                        }

                        text: root.lowestPriceStation == -1 || root.fuelLoading == true ? i18n.tr("Loading") + "..." : lowestPriceStation

                        elide: Text.ElideRight
                        font.bold: true
                    }

                    Label {
                        id: fuelSubtitle

                        width: parent.width

                        anchors {
                            left: parent.left
                            bottom: parent.bottom
                        }

                        text: root.lowestPrice == -1 || root.fuelLoading == true ? "" : "€" + root.lowestPrice

                        elide: Text.ElideRight
                    }
                }

                Icon {
                    height: units.gu(2.5)
                    width: units.gu(2.5)

                    name: 'next'
                    
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: units.gu(2)    
                    }
                }
            }
        }
    }
}