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

ListItem {
    id: locationItem
    
    width: parent.width
    height: locationName.implicitHeight + units.gu(5)

    Icon {
        id: locationIcon

        height: units.gu(2.5)
        width: units.gu(2.5)

        name: 'location'
        color: theme.palette.normal.foregroundText
        
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: units.gu(2)
        }
    }

    Label {
        id: locationName
        
        width: parent.width - locationIcon.width - units.gu(6)
        
        anchors {
            left: locationIcon.right
            leftMargin: units.gu(2)
            top: parent.top
            topMargin: units.gu(2.5)
        }
        
        text: name

        wrapMode: Text.WordWrap
        elide: Text.ElideRight
        maximumLineCount: 2
    }

    onClicked: {
        settings.currentLatitude = latitude
        settings.currentLongitude = longitude

        root.fuelProvider.getFuelPrices()

        adaptivePageLayout.removePages(searchPage)
        
        searchField.text = null
        searchField.searchExecuted = false
        
        if (settings.firstRun) {
            root.firstRunSlide = 3
        }
        
        locationListModel.clear()
    }
}