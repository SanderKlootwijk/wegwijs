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

Page {
    id: aboutPage

    header: PageHeader {
        id: aboutPageHeader

        title: i18n.tr("About")
    }

    Flickable {
        id: aboutFlickable

        anchors {
            fill: parent
            topMargin: aboutPageHeader.height
        }
        
        contentHeight: aboutCloumn.height

        Column {
            id: aboutCloumn
            
            width: parent.width
            
            spacing: units.gu(2)

            Item {
                width: parent.height
                height: units.gu(2)
            }

            LomiriShape {
                width: units.gu(15)
                height: units.gu(15)
                
                anchors.horizontalCenter: parent.horizontalCenter
                
                radius: "large"
                
                source: Image {
                    sourceSize.width: width
                    sourceSize.height: height
                    smooth: true
                    source: "../img/wegwijs.svg"
                }
            }

            Item {
                width: nameAndVersionLayout.width
                height: nameAndVersionLayout.height
                
                anchors.horizontalCenter: parent.horizontalCenter

                ListItemLayout {
                    id: nameAndVersionLayout
                    
                    padding {
                        top: units.gu(0)
                        bottom: units.gu(2)
                    }

                    title.text: i18n.tr("Wegwijs")
                    title.font.pixelSize: units.gu(3)
                    title.color: theme.palette.normal.backgroundText
                    title.horizontalAlignment: Text.AlignHCenter

                    subtitle.text: i18n.tr("Version") + " " + root.version

                    subtitle.color: theme.palette.normal.backgroundTertiaryText
                    subtitle.font.pixelSize: units.gu(1.75)
                    subtitle.horizontalAlignment: Text.AlignHCenter
                }
            }

            Column {
                width: parent.width

                Repeater {
                    
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    model: [
                    { name: i18n.tr("Source code"), url: "https://github.com/sanderklootwijk/wegwijs" },
                    { name: i18n.tr("Report issues"),  url: "https://github.com/sanderklootwijk/wegwijs/issues" }
                    ]

                    delegate: ListItem {
                        ListItemLayout {
                            title.text : modelData.name
                            ProgressionSlot {
                                width:units.gu(2)
                            }
                        }
                        onClicked: Qt.openUrlExternally(modelData.url)
                    }
                }
            }

            Item {
                width: parent.width
                height: units.gu(1)
            }

            Label {
                height: units.gu(0.5)

                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                }
                
                text: i18n.tr("API usage")
                color: theme.palette.normal.backgroundSecondaryText
                font.bold: true
            }

            Column {
                width: parent.width
                Repeater {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    model: [
                    { name: i18n.tr("Fuel prices by Tankplanner"), url: "https://www.tankplanner.nl/"},
                    { name: i18n.tr("Traffic information by Rijkswaterstaat"), url: "https://www.rwsverkeersinfo.nl"},
                    { name: i18n.tr("Address coordinates by Geocoding"), url: "https://geocode.maps.co"}
                    ]

                    delegate: ListItem {
                        ListItemLayout {
                            title.text : modelData.name
                            ProgressionSlot {
                                width:units.gu(2)
                            }
                        }
                        onClicked: Qt.openUrlExternally(modelData.url)
                    }
                }
            }
        }
    }    
}