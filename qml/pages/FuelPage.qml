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
    id: fuelPage

    property alias fuelListView: fuelListView
    property alias fuelSections: fuelSections

    header: PageHeader {
        id: fuelPageHeader
        title: i18n.tr("Wegwijs")
        subtitle: {
            if (settings.fuelType == 0) {
                "Euro 95 (E10)"
            }
            else if (settings.fuelType == 1) {
                "Euro 98 (E5)"
            }
            else if (settings.fuelType == 2) {
                "Diesel (B7)"
            }
            else if (settings.fuelType == 3) {
                "LPG"
            }
            else if (settings.fuelType == 4) {
                i18n.tr("Electric")
            }
        }

        extension: Sections {
            id: fuelSections

            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                bottom: parent.bottom
            }

            enabled: settings.fuelType == 4 ? false : true
            model: [i18n.tr("Price"), i18n.tr("Distance")]
            onSelectedIndexChanged: {
                if (selectedIndex == 0) {
                    fuelListView.model = null
                    fuelListModel.sortColumnName = "price"
                    fuelListModel.quick_sort()
                    fuelListView.model = fuelListModel
                }
                else if (selectedIndex == 1) {
                    fuelListView.model = null
                    fuelListModel.sortColumnName = "distance"
                    fuelListModel.quick_sort()
                    fuelListView.model = fuelListModel
                }
            }

            Component.onCompleted: {
                settings.fuelType == 4 ? fuelSections.selectedIndex = 1 : fuelSections.selectedIndex = 0
            }
        }

        trailingActionBar.actions: [
            Action {
                text: i18n.tr("Search")
                iconName: "find"
                onTriggered: {
                    fuelPage.pageStack.addPageToCurrentColumn(fuelPage, searchPage)
                }
            }
        ]
    }

    Scrollbar {
        z: 1
        flickableItem: fuelListView
        align: Qt.AlignTrailing
    }

    ActivityIndicator {
        id: loadingIndicator
        running: true
        visible: root.fuelLoading

        anchors.centerIn: parent
    }

    Label {
        width: parent.width - units.gu(8)

        visible: !loadingIndicator.visible

        anchors {
            top: fuelPageHeader.bottom
            topMargin: units.gu(5)
            horizontalCenter: parent.horizontalCenter
        }

        text: fuelListModel.count == 0 ? i18n.tr("No nearby fuel stations found") + "\n\n" + i18n.tr("Search for another location or expand the search radius in the settings") : ""

        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }

    ListView {
        id: fuelListView

        visible: !root.fuelLoading

        anchors {
            fill: parent
            topMargin: fuelPageHeader.height
        }

        model: fuelListModel
        delegate: FuelStationItem {}
        clip: true
    }

    Component.onCompleted: {
        getFuelPrices()
    }
}