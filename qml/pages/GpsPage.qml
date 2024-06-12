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
import QtPositioning 5.2
import QtSystemInfo 5.5
import "../components"

Page {
    id: gpsPage

    property alias positionSource: positionSource
    property alias gpsLabelTimer: gpsLabelTimer

    header: PageHeader {
        id: gpsPageHeader

        title: i18n.tr("Current location")

        leadingActionBar.actions: [
            Action {
                iconName: "back"
                onTriggered: {
                    positionSource.active = false
                    gpsLabelTimer.stop()
                    gpsLabel.text = i18n.tr("Waiting for GPS signal...")
                    adaptivePageLayout.removePages(gpsPage)
                }
            }
        ]
    }

    ScreenSaver {
        id: screenSaver

        screenSaverEnabled: {
            if (Qt.application.state == Qt.ApplicationActive) {
                !positionSource.active
            } else {
                true
            }
        }
    }

    PositionSource {
        id: positionSource
        
        property var coordinate: position.coordinate

        active: false
        preferredPositioningMethods: PositionSource.SatellitePositioningMethods
        updateInterval: 1000

        onCoordinateChanged: {
            if (active == true) {
                positionSource.active = false

                settings.currentLatitude = position.coordinate.latitude
                settings.currentLongitude = position.coordinate.longitude

                gpsLabelTimer.stop()
                gpsLabel.text = i18n.tr("Waiting for GPS signal...")

                root.fuelProvider.getFuelPrices()

                adaptivePageLayout.removePages(gpsPage)
                adaptivePageLayout.removePages(searchPage)
                
                searchPage.searchField.text = null
                searchPage.searchField.searchExecuted = false
                
                if (settings.firstRun) {
                    root.firstRunSlide = 3
                }
                
                searchPage.locationListModel.clear()
            }
        }
    }

    ActivityIndicator {
        id: loadingIndicator
        running: positionSource.active

        anchors {
            centerIn: parent
        }
    }

    Label {
        id: gpsLabel
        
        width: parent.width - units.gu(8)

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: loadingIndicator.bottom
            topMargin: units.gu(2)
        }

        text: i18n.tr("Waiting for GPS signal...")

        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }

    Timer {
        id: gpsLabelTimer

        interval: 15000
        repeat: false
        running: false

        onTriggered: {
            gpsLabel.text = i18n.tr("This could take a while...")
        }
    }
}