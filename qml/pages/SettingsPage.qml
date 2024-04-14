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
import Lomiri.Components.ListItems 1.3
import QtQuick.Layouts 1.3
import "../components"

Page {
    id: settingsPage

    property alias fuelTypeOptionSelector: fuelTypeOptionSelector

    header: PageHeader {
        id: settingsPageHeader
        
        title: i18n.tr("Settings")

        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: i18n.tr("Back")
                onTriggered: {
                    themeOptionSelector.currentlyExpanded = false
                    fuelTypeOptionSelector.currentlyExpanded = false
                    settings.fuelType == 4 ? fuelPage.fuelSections.selectedIndex = 1 : fuelPage.fuelSections.selectedIndex = 0
                    adaptivePageLayout.removePages(settingsPage)
                }
            }
        ]
    }
    
    Scrollbar {
        z: 1
        id: scrollSettings

        flickableItem: flickSettings
        align: Qt.AlignTrailing
    }

    Flickable {
        id: flickSettings

        anchors {
            fill: parent
            topMargin: settingsPageHeader.height
        }

        contentWidth: columnSettings.width
        contentHeight: columnSettings.height
    
        Column {
            id: columnSettings

            width: settingsPage.width

            ListItem {
                id: themeListItem

                height: themeLabel.height + themeOptionSelector.height + units.gu(6)

                Label {
                    id: themeLabel
                    
                    width: parent.width - units.gu(4)

                    anchors {
                        top: parent.top
                        topMargin: units.gu(2)
                        left: parent.left
                        leftMargin: units.gu(2)
                    }
                    
                    text: i18n.tr("Theme")

                    elide: Text.ElideRight
                }

                OptionSelector {
                    id: themeOptionSelector

                    width: parent.width - units.gu(4)

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: themeLabel.bottom
                        topMargin: units.gu(2)
                    }

                    model: [i18n.tr("System"), "Ambiance", "Suru Dark"]

                    onSelectedIndexChanged: settings.theme = selectedIndex

                    Component.onCompleted: selectedIndex = settings.theme
                }   
            }

            ListItem {
                id: searchRadiusListItem

                height: units.gu(10)

                Label {
                    id: searchRadiusLabel

                    width: parent.width - units.gu(10)

                    anchors {
                        top: parent.top
                        topMargin: units.gu(2)
                        left: parent.left
                        leftMargin: units.gu(2)
                    }

                    text: i18n.tr("Search radius in km (as the crow flies)")
                    elide: Text.ElideRight
                }

                Slider {
                    id: searchRadiusSlider

                    anchors {
                        top: searchRadiusLabel.bottom
                        left: parent.left
                        leftMargin: units.gu(2)
                        right: parent.right
                        rightMargin: units.gu(2)
                    }

                    live: false
                    value: settings.searchRadius
                    minimumValue: 2
                    maximumValue: 10
                }

                Binding {
                    target: settings
                    property: "searchRadius"
                    value: searchRadiusSlider.value
                }
            }

            ListItem {
                id: fuelTypeListItem

                height: fuelTypeLabel.height + fuelTypeOptionSelector.height + units.gu(6)

                Label {
                    id: fuelTypeLabel
                    width: parent.width - units.gu(4)

                    anchors {
                        top: parent.top
                        topMargin: units.gu(2)
                        left: parent.left
                        leftMargin: units.gu(2)
                    }
                    
                    text: i18n.tr("Fuel type")

                    elide: Text.ElideRight
                }

                OptionSelector {
                    id: fuelTypeOptionSelector

                    width: parent.width - units.gu(4)

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: fuelTypeLabel.bottom
                        topMargin: units.gu(2)
                    }

                    model: ["Euro 95 (E10)", "Euro 98 (E5)", "Diesel (B7)", "LPG", i18n.tr("Electric")]

                    onSelectedIndexChanged: {
                        settings.fuelType = selectedIndex
                        getFuelPrices()
                    }

                    Component.onCompleted: selectedIndex = settings.fuelType
                }   
            }
        }
    }
}