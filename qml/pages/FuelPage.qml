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
            switch (settings.fuelType) {
                case 0: return "Euro 95 (E10)";
                case 1: return "Euro 98 (E5)";
                case 2: return "Diesel (B7)";
                case 3: return "LPG";
                case 4: return i18n.tr("Electric");
                default: return "";
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
            },
            Action {
                text: i18n.tr("Filters")
                iconName: "filters"
                onTriggered: {
                    fuelPage.pageStack.addPageToCurrentColumn(fuelPage, filterPage)
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
        running: root.fuelProvider.loading

        anchors.centerIn: parent
    }

    Label {
        width: parent.width - units.gu(8)

        visible: !loadingIndicator.running

        anchors {
            top: fuelPageHeader.bottom
            topMargin: units.gu(5)
            horizontalCenter: parent.horizontalCenter
        }

        text: {
            if (fuelListModel.count == 0) {
                if (settings.fuelType == 4) {
                    i18n.tr("No nearby charging stations found") + "\n\n" + i18n.tr("Try another location or adjust your filters")
                }
                else {
                    i18n.tr("No nearby fuel stations found") + "\n\n" + i18n.tr("Try another location or adjust your filters")
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
        id: fuelListView

        visible: !root.fuelProvider.loading

        anchors {
            fill: parent
            topMargin: fuelPageHeader.height
        }

        model: fuelListModel
        delegate: FuelStationItem {}
        clip: true
    }

    Component.onCompleted: {
        root.fuelProvider.getFuelPrices()
    }
}