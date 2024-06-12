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
import QtQuick.Controls 2.2 as QtControls
import QtQuick.Controls.Suru 2.2
import Lomiri.Components 1.3
import Lomiri.Components.ListItems 1.3
import QtQuick.Layouts 1.3
import "../components"

Page {
    id: filterPage

    property bool filtersChanged: false
    property bool arrayUpdating: false

    Suru.theme: {
        switch (settings.theme) {
            case 0: return;
            case 1: return Suru.Light;
            case 2: return Suru.Dark;
            default: return;
        }
    }

    header: PageHeader {
        id: filterPageHeader
        
        title: i18n.tr("Filters")

        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: i18n.tr("Back")
                onTriggered: {
                    adaptivePageLayout.removePages(filterPage)

                    if (filtersChanged) {
                        root.fuelProvider.getFuelPrices()
                        filtersChanged = false
                    }
                }
            }
        ]
    }

    Scrollbar {
        z: 1
        flickableItem: filterFlickable
        align: Qt.AlignTrailing
    }

    Flickable {
        id: filterFlickable

        anchors {
            fill: parent
            topMargin: filterPageHeader.height
        }

        contentWidth: filterColumn.width
        contentHeight: filterColumn.height
    
        Column {
            id: filterColumn

            width: settingsPage.width

            ListItem {
                id: searchRadiusListItem

                height: units.gu(10)

                Label {
                    id: searchRadiusLabel

                    width: parent.width - kmLabel.width - units.gu(6)

                    anchors {
                        top: parent.top
                        topMargin: units.gu(2)
                        left: parent.left
                        leftMargin: units.gu(2)
                    }

                    text: i18n.tr("Search radius (as the crow flies)")
                    elide: Text.ElideRight
                }

                Label {
                    id: kmLabel

                    anchors {
                        top: parent.top
                        topMargin: units.gu(2)
                        right: parent.right
                        rightMargin: units.gu(2)
                    }

                    text: searchRadiusSlider.value + " km"
                }

                QtControls.Slider {
                    id: searchRadiusSlider

                    anchors {
                        top: searchRadiusLabel.bottom
                        left: parent.left
                        leftMargin: units.gu(1)
                        right: parent.right
                        rightMargin: units.gu(1)
                    }

                    value: settings.searchRadius
                    from: 2
                    to: 15
                    stepSize: 1
                    snapMode: QtControls.RangeSlider.SnapAlways

                    onValueChanged: {
                        settings.searchRadius = value
                        filterPage.filtersChanged = true
                    }

                    handle: LomiriShape {
                        x: searchRadiusSlider.leftPadding + searchRadiusSlider.visualPosition * (searchRadiusSlider.availableWidth - width)
                        y: searchRadiusSlider.topPadding + searchRadiusSlider.availableHeight / 2 - height / 2
                        width: units.gu(2)
                        height: units.gu(2)
                        aspect: LomiriShape.DropShadow
                        backgroundColor: "#FFFFFF"
                    }

                    background: Item {
                        implicitWidth: units.gu(5)
                        implicitHeight: units.gu(2)

                        x: searchRadiusSlider.leftPadding
                        y: searchRadiusSlider.topPadding + ((searchRadiusSlider.availableHeight - height) / 2)
                        width: searchRadiusSlider.availableWidth
                        height: implicitHeight

                        scale: 1

                        Rectangle {
                            x: 0
                            y: (parent.height - height) / 2
                            width: parent.width
                            height: units.dp(2)

                            color: Suru.neutralColor
                        }

                        Rectangle {
                            x: 0
                            y: (parent.height - height) / 2
                            width: searchRadiusSlider.position * parent.width
                            height: units.dp(2)

                            color: Suru.highlightColor
                        }
                    }
                }
            }

            ListItem {
                id: kilowattRangeListItem
                
                visible: settings.fuelType == 4

                height: units.gu(11)

                Label {
                    id: kilowattRangeLabel

                    width: parent.width - units.gu(4)

                    anchors {
                        top: parent.top
                        topMargin: units.gu(2)
                        left: parent.left
                        leftMargin: units.gu(2)
                    }

                    text: i18n.tr("Kilowatt Range")
                    elide: Text.ElideRight
                }

                QtControls.RangeSlider {
                    id: kilowattRangeSlider

                    anchors {
                        top: kilowattRangeLabel.bottom
                        left: parent.left
                        leftMargin: units.gu(1)
                        right: parent.right
                        rightMargin: units.gu(1)
                    }

                    from: 0
                    to: 100
                    first.value: getVisualValue(settings.minimumKw)
                    second.value: getVisualValue(settings.maximumKw)
                    stepSize: 25
                    snapMode: QtControls.RangeSlider.SnapAlways

                    function getVisualValue(value) {
                        if (value == 1) return 0;
                        else if (value == 22) return 25;
                        else if (value == 50) return 50;
                        else if (value == 150) return 75;
                        else if (value == 350) return 350;
                    }

                    function getKwValue(visualValue) {
                        if (visualValue == 0) return 1;
                        else if (visualValue == 25) return 22;
                        else if (visualValue == 50) return 50;
                        else if (visualValue == 75) return 150;
                        else if (visualValue == 100) return 350;
                    }

                    first.onValueChanged: {
                        let maxValue = (second.value === 100) ? 75 :
                                       (second.value === 75) ? 50 :
                                       (second.value === 50) ? 25 :
                                       (second.value === 25) ? 0 : 0;

                        if (first.value > maxValue) {
                            first.value = maxValue
                        }

                        let newValue = getKwValue(first.value);

                        settings.minimumKw = newValue
                        filterPage.filtersChanged = true
                    }

                    second.onValueChanged: {
                        let minValue = (first.value === 0) ? 25 :
                                       (first.value === 25) ? 50 :
                                       (first.value === 50) ? 75 :
                                       (first.value === 75) ? 100 : 100;
                        
                        if (second.value < minValue) {
                            second.value = minValue
                        }

                        let newValue = getKwValue(second.value);

                        settings.maximumKw = newValue
                        filterPage.filtersChanged = true
                    }

                    first.handle: LomiriShape {
                        x: kilowattRangeSlider.leftPadding + kilowattRangeSlider.first.visualPosition * (kilowattRangeSlider.availableWidth - width)
                        y: kilowattRangeSlider.topPadding + kilowattRangeSlider.availableHeight / 2 - height / 2
                        width: units.gu(2)
                        height: units.gu(2)

                        aspect: LomiriShape.DropShadow
                        backgroundColor: "#FFFFFF"
                    }

                    second.handle: LomiriShape {
                        x: kilowattRangeSlider.leftPadding + kilowattRangeSlider.second.visualPosition * (kilowattRangeSlider.availableWidth - width)
                        y: kilowattRangeSlider.topPadding + kilowattRangeSlider.availableHeight / 2 - height / 2
                        width: units.gu(2)
                        height: units.gu(2)

                        aspect: LomiriShape.DropShadow
                        backgroundColor: "#FFFFFF"
                    }

                    background: Item {
                        implicitWidth: units.gu(5)
                        implicitHeight: units.gu(2)

                        x: kilowattRangeSlider.leftPadding
                        y: kilowattRangeSlider.topPadding + ((kilowattRangeSlider.availableHeight - height) / 2)
                        width: kilowattRangeSlider.availableWidth
                        height: implicitHeight

                        scale: 1

                        Rectangle {
                            x: 0
                            y: (parent.height - height) / 2
                            width: parent.width
                            height: units.dp(2)

                            color: Suru.neutralColor
                        }

                        Rectangle {
                            x: kilowattRangeSlider.leftPadding - (width / 2)
                            y: (parent.height - height) / 2
                            width: units.gu(0.75)
                            height: units.gu(0.75)
                            radius: 180
                            color: Suru.neutralColor

                            Rectangle {
                                anchors.centerIn: parent
                                width: units.gu(0.5)
                                height: units.gu(0.5)
                                radius: 180
                                color: kilowattRangeSlider.first.value == 1 ? Suru.highlightColor : "#A0A0A0"
                            }
                        }

                        Rectangle {
                            x: (kilowattRangeSlider.availableWidth / 4)
                            y: (parent.height - height) / 2
                            width: units.gu(0.75)
                            height: units.gu(0.75)
                            radius: 180
                            color: Suru.neutralColor

                            Rectangle {
                                anchors.centerIn: parent
                                width: units.gu(0.5)
                                height: units.gu(0.5)
                                radius: 180
                                color: kilowattRangeSlider.first.value <= 25 && kilowattRangeSlider.second.value >= 25 ? Suru.highlightColor : "#A0A0A0"
                            }
                        }

                        Rectangle {
                            x: (kilowattRangeSlider.availableWidth / 2) - (width / 2)
                            y: (parent.height - height) / 2
                            width: units.gu(0.75)
                            height: units.gu(0.75)
                            radius: 180
                            color: Suru.neutralColor

                            Rectangle {
                                anchors.centerIn: parent
                                width: units.gu(0.5)
                                height: units.gu(0.5)
                                radius: 180
                                color: kilowattRangeSlider.first.value <= 50 && kilowattRangeSlider.second.value >= 50 ? Suru.highlightColor : "#A0A0A0"
                            }
                        }

                        Rectangle {
                            x: (3 * kilowattRangeSlider.availableWidth / 4) - width
                            y: (parent.height - height) / 2
                            width: units.gu(0.75)
                            height: units.gu(0.75)
                            radius: 180
                            color: Suru.neutralColor

                            Rectangle {
                                anchors.centerIn: parent
                                width: units.gu(0.5)
                                height: units.gu(0.5)
                                radius: 180
                                color: kilowattRangeSlider.first.value <= 75 && kilowattRangeSlider.second.value >= 75 ? Suru.highlightColor : "#A0A0A0"
                            }
                        }

                        Rectangle {
                            x: kilowattRangeSlider.availableWidth - (width / 2) - kilowattRangeSlider.rightPadding
                            y: (parent.height - height) / 2
                            width: units.gu(0.75)
                            height: units.gu(0.75)
                            radius: 180
                            color: Suru.neutralColor

                            Rectangle {
                                anchors.centerIn: parent
                                width: units.gu(0.5)
                                height: units.gu(0.5)
                                radius: 180
                                color: kilowattRangeSlider.second.value == 100 ? Suru.highlightColor : "#A0A0A0"
                            }
                        }

                        Rectangle {
                            x: kilowattRangeSlider.first.position * parent.width
                            y: (parent.height - height) / 2
                            width: kilowattRangeSlider.second.position * parent.width - kilowattRangeSlider.first.position * parent.width
                            height: units.dp(2)

                            color: Suru.highlightColor
                        }
                    }
                }

                Label {
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        bottom: kilowattRangeSlider.bottom
                        bottomMargin: -units.dp(4)
                    }

                    text: settings.minimumKw + " kW"

                    textSize: Label.Small
                }

                Label {
                    anchors {
                        right: parent.right
                        rightMargin: units.gu(2)
                        bottom: kilowattRangeSlider.bottom
                        bottomMargin: -units.dp(4)
                    }

                    text: settings.maximumKw == 350 ? "350+ kW" : settings.maximumKw + " kW"

                    textSize: Label.Small
                }
            }

            ListItem {
                id: connectionTypesListItem

                visible: settings.fuelType == 4

                height: units.gu(5)
                
                divider.colorFrom: theme.palette.normal.background
                divider.colorTo: theme.palette.normal.background

                Label {
                    id: connectionTypesLabel

                    width: parent.width - units.gu(4)

                    anchors {
                        top: parent.top
                        topMargin: units.gu(2)
                        left: parent.left
                        leftMargin: units.gu(2)
                    }

                    text: i18n.tr("Connection Types:")
                    elide: Text.ElideRight
                }
            }

            Column {
                visible: settings.fuelType == 4
                
                width: parent.width
            
                ConnectionTypeItem {
                    connectiontypeid: 1
                    connectiontypes: [1]
                    name: "Type 1"
                }

                ConnectionTypeItem {
                    connectiontypeid: 25
                    connectiontypes: [25,1036]
                    name: "Type 2"
                }
                
                ConnectionTypeItem {
                    connectiontypeid: 2
                    connectiontypes: [2]
                    name: "CHAdeMO"
                }

                ConnectionTypeItem {
                    connectiontypeid: 32
                    connectiontypes: [32]
                    name: "CCS (Type 1)"
                }

                ConnectionTypeItem {
                    connectiontypeid: 33
                    connectiontypes: [33]
                    name: "CCS (Type 2)"
                }

                ConnectionTypeItem {
                    connectiontypeid: 27
                    connectiontypes: [27]
                    name: "Tesla Supercharger"
                }

                ConnectionTypeItem {
                    connectiontypeid: 30
                    connectiontypes: [8,30]
                    name: "Tesla Connector"
                }
            }
        }
    }
}