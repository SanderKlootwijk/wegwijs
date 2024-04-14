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

    height: locationName.implicitHeight + units.gu(5)

    Label {
        id: locationName
        
        width: parent.width - units.gu(4)
        
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            top: parent.top
            topMargin: units.gu(2.5)
        }
        
        text: name

        wrapMode: Text.WordWrap
    }

    onClicked: {
        settings.currentLatitude = latitude
        settings.currentLongitude = longitude

        getFuelPrices()

        adaptivePageLayout.removePages(searchPage)
        
        searchField.text = null
        locationListModel.clear()
        searchPage.searchExecuted = false
        if (settings.firstRun) {
            root.firstRunSlide = 3
        }
    }
}