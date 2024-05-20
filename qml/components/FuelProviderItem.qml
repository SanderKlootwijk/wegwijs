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
import QtGraphicalEffects 1.12

ListItem {
    id: fuelProviderItem

    height: units.gu(6.25)

    property string fuelProvider

    Label {
        id: countryLabel

        width: parent.width - units.gu(8)

        anchors{
            top: parent.top
            topMargin: units.gu(1)
            left: parent.left
            leftMargin: units.gu(2)
        }

        elide: Text.ElideRight

        text: modelData.country
    }

    Label {
        width: parent.width - units.gu(8)

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            top: countryLabel.bottom
        }

        color: theme.palette.normal.backgroundSecondaryText
        textSize: Label.Small
        elide: Text.ElideRight

        text: modelData.label
    }

    Icon {
        height: units.gu(2)
        width: units.gu(2)

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: units.gu(2)    
        }

        visible: modelData.name === settings.fuelProvider

        name: 'toolkit_tick'
    }
    
    onClicked: {
        if (settings.fuelProvider != modelData.name) {
            settings.fuelProvider = modelData.name
            root.fuelProvider.getFuelPrices()
        }
    }
}