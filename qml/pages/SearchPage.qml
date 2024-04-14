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
    property bool searchExecuted: false

    header: searchPageHeader

    PageHeader {
        id: searchPageHeader

        contents: TextField {
            id: searchField

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
                searchPage.searchExecuted = true
            }
        }

        onVisibleChanged: if (visible) searchField.forceActiveFocus()
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                onTriggered: {
                    adaptivePageLayout.removePages(searchPage)
                    searchField.text = null
                    searchPage.searchExecuted = false
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
                        searchPage.searchExecuted = true
                    }
                }
            }
        ]               
    }

    Scrollbar {
        z: 1
        flickableItem: locationListView
        align: Qt.AlignTrailing
    }

    ActivityIndicator {
        id: loadingIndicator
        running: true
        visible: root.searchLoading

        anchors {
            centerIn: parent
        }
    }

    Label {
        width: parent.width - units.gu(8)

        visible: !loadingIndicator.visible

        anchors {
            top: searchPageHeader.bottom
            topMargin: units.gu(5)
            horizontalCenter: parent.horizontalCenter
        }

        text: {
            if (locationListModel.count == 0 && searchPage.searchExecuted) {
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

    ListView {
        id: locationListView

        visible: !root.searchLoading

        model: locationListModel
        delegate: Location {}

        anchors {
            fill: parent
            topMargin: searchPageHeader.height
        }
    }
}