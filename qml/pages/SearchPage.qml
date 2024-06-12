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
import "../components"

Page {
    id: searchPage

    property alias locationListModel: locationListModel
    property alias searchField: searchField

    header: searchPageHeader

    PageHeader {
        id: searchPageHeader

        contents: TextField {
            id: searchField

            property bool searchExecuted: false

            width: Math.min(parent.width)
            
            anchors.centerIn: parent

            objectName: "searchField"
            
            enabled: !root.searchLoading
            inputMethodHints: Qt.ImhNoPredictiveText
            placeholderText: i18n.tr("Search for a location") + "..."
            hasClearButton: false
            
            onAccepted: {
                locationSource = "https://geocode.maps.co/search?q=" + searchField.text + "&api_key=" + root.geocodeKey
                getLocations()
                searchExecuted = true
            }
        }

        onVisibleChanged: if (visible) searchField.forceActiveFocus()
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                onTriggered: {
                    adaptivePageLayout.removePages(searchPage)
                    searchField.text = null
                    searchField.searchExecuted = false
                    locationListModel.clear()
                }
            }
        ]
        trailingActionBar.actions: [
            Action {
                iconName: "find"
                onTriggered: {
                    if (!root.searchLoading) {
                        locationSource = "https://geocode.maps.co/search?q=" + searchField.text + "&api_key=" + root.geocodeKey
                        getLocations()
                        searchField.searchExecuted = true
                    }
                }
            }
        ]        
    }

    Scrollbar {
        z: 1
        flickableItem: searchFlickable
        align: Qt.AlignTrailing
    }

    ActivityIndicator {
        id: loadingIndicator
        running: root.searchLoading

        anchors {
            centerIn: parent
        }
    }

    Label {
        width: parent.width - units.gu(8)

        visible: !loadingIndicator.running

        anchors {
            top: searchPageHeader.bottom
            topMargin: units.gu(13)
            horizontalCenter: parent.horizontalCenter
        }

        text: {
            if (locationListModel.count == 0 && searchField.searchExecuted) {
                i18n.tr("No locations found")
            }
            else {
                ""
            }
        }

        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }

    ListModel {
        id: locationListModel
    }

    Flickable {
        id: searchFlickable

        anchors {
            fill: parent
            topMargin: searchPageHeader.height
        }
        
        contentHeight: searchColumn.height

        Column {
            id: searchColumn
            
            width: parent.width

            ListItem {
                id: gpsItem

                width: parent.width
                height: gpsLabel.implicitHeight + units.gu(5)

                visible: !root.searchLoading

                Icon {
                    id: gpsIcon

                    height: units.gu(2.5)
                    width: units.gu(2.5)

                    name: 'gps'
                    color: theme.palette.normal.foregroundText
                    
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: units.gu(2)
                    }
                }

                Label {
                    id: gpsLabel
                    
                    width: parent.width - gpsIcon.width - units.gu(6)
                    
                    anchors {
                        left: gpsIcon.right
                        leftMargin: units.gu(2)
                        top: parent.top
                        topMargin: units.gu(2.5)
                    }
                    
                    text: i18n.tr("Current location")

                    elide: Text.ElideRight
                }

                onClicked: {
                    searchPage.pageStack.addPageToCurrentColumn(searchPage, gpsPage)
                    gpsPage.gpsLabelTimer.start()
                    gpsPage.positionSource.active = true
                }
            }

            Repeater {
                id: locationListView

                width: parent.width

                visible: !root.searchLoading

                model: locationListModel

                delegate: Location {}
            }
        }
    }
}