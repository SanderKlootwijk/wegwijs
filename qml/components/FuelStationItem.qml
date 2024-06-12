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
    id: fuelStationItem
    
    height: units.gu(6.5)

    Label {
        id: fuelStationName
        
        width: parent.width - units.gu(16)
        
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            top: parent.top
            topMargin: units.gu(1)
        }
        
        elide: Text.ElideRight
        font.bold: true
        
        text: organization
    }

    Label {
        id: fuelStationDistance
        
        width: parent.width - units.gu(16)
        
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            top: fuelStationName.bottom
        }
        
        elide: Text.ElideRight
        
        text: town + ", " + distance + " km"
    }

    Label {
        id: fuelStationPrice
        
        width: units.gu(10)
        
        anchors {
            right: nextIcon.left
            rightMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }
        
        maximumLineCount: 1
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideLeft
        
        text: settings.fuelType == 4 ? highestpower + " kW" : "€" + price
    }

    Icon {
        id: nextIcon

        height: units.gu(2.5)
        width: units.gu(2.5)

        name: 'next'
        
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: units.gu(2)
        }
    } 

    onClicked: {
        resultPage.qtObject.latitude = latitude
        resultPage.qtObject.longitude = longitude

        resultPage.webEngineView.reload()
        
        resultPage.infoFlickable.expanded = false
        resultPage.infoFlickable.contentY = 0
        resultPage.resultPageHeader.title = organization
        resultPage.resultPageHeader.subtitle = town
        resultPage.fuelpriceLabel.text = "€" + price
        resultPage.adressLabel.text = address + ", " + town
        settings.fuelType == 4 ? resultPage.connectionsData = connections : resultPage.connectionsData = null
        
        fuelPage.pageStack.addPageToNextColumn(fuelPage, resultPage)
    }
}