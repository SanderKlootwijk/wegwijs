/*
* Copyright (C) 2026  Sander Klootwijk
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
        flickableItem: settingsFlickable
        align: Qt.AlignTrailing
    }

    Flickable {
        id: settingsFlickable

        anchors {
            fill: parent
            topMargin: settingsPageHeader.height
        }

        contentWidth: settingsColumn.width
        contentHeight: settingsColumn.height
    
        Column {
            id: settingsColumn

            width: settingsPage.width

            ListItem {
                id: themeTitle

                height: units.gu(6.25)

                divider.colorFrom: theme.palette.normal.background
                divider.colorTo: theme.palette.normal.background

                Label {
                    id: themeTitleLabel
                    width: parent.width - units.gu(4)

                    anchors {
                        bottom: parent.bottom
                        bottomMargin: units.gu(1.25)
                        left: parent.left
                        leftMargin: units.gu(2)
                    }
                    
                    text: i18n.tr("Theme") + ":"

                    color: theme.palette.normal.backgroundSecondaryText
                    font.bold: true
                    elide: Text.ElideRight
                }
            }

            ListItem {
                id: themeListItem

                height: themeOptionSelector.height + units.gu(4)

                OptionSelector {
                    id: themeOptionSelector

                    width: parent.width - units.gu(4)

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        topMargin: units.gu(2)
                    }

                    model: [i18n.tr("System"), "Ambiance", "Suru Dark"]

                    onSelectedIndexChanged: settings.theme = selectedIndex

                    Component.onCompleted: selectedIndex = settings.theme
                }   
            }

            ListItem {
                id: fuelTitle

                height: units.gu(6.25)

                divider.colorFrom: theme.palette.normal.background
                divider.colorTo: theme.palette.normal.background

                Label {
                    id: fuelTitleLabel
                    width: parent.width - units.gu(4)

                    anchors {
                        bottom: parent.bottom
                        bottomMargin: units.gu(1.25)
                        left: parent.left
                        leftMargin: units.gu(2)
                    }
                    
                    text: i18n.tr("Fuel") + ":"

                    color: theme.palette.normal.backgroundSecondaryText
                    font.bold: true
                    elide: Text.ElideRight
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
                        fetchFuelPrices()
                    }

                    Component.onCompleted: selectedIndex = settings.fuelType
                }   
            }

            ListItem {
                id: aboutTitle

                height: units.gu(6.25)

                divider.colorFrom: theme.palette.normal.background
                divider.colorTo: theme.palette.normal.background

                Label {
                    id: aboutTitleLabel

                    width: parent.width - units.gu(4)

                    anchors {
                        bottom: parent.bottom
                        bottomMargin: units.gu(1.25)
                        left: parent.left
                        leftMargin: units.gu(2)
                    }

                    text: i18n.tr("About") + ":"

                    color: theme.palette.normal.backgroundSecondaryText
                    elide: Text.ElideRight
                    font.bold: true
                }
            }

            ListItem {
                id: aboutListItem

                height: units.gu(6)

                ListItemLayout {
                    id: layoutAbout

                    anchors.verticalCenter: parent.verticalCenter

                    title.text : i18n.tr("About this app")
                    ProgressionSlot { color: theme.palette.normal.baseText; }
                }

                onClicked: settingsPage.pageStack.addPageToNextColumn(settingsPage, aboutPage)
            }
        }
    }
}