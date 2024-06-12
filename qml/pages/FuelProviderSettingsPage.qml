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
    id: fuelProviderSettingsPage

    header: PageHeader {
        id: fuelProviderSettingsPageHeader
        
        title: i18n.tr("Fuel")

        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: i18n.tr("Back")
                onTriggered: adaptivePageLayout.removePages(fuelProviderSettingsPage)
            }
        ]
    }

    Scrollbar {
        z: 1
        flickableItem: flickFuelProviderSettings
        align: Qt.AlignTrailing
    }

    Flickable {
        id: flickFuelProviderSettings

        anchors {
            fill: parent
            topMargin: fuelProviderSettingsPageHeader.height
        }

        contentWidth: fuelProviderSettingsColumn.width
        contentHeight: fuelProviderSettingsColumn.height

        Column {
            id: fuelProviderSettingsColumn

            width: fuelProviderSettingsPage.width

            Repeater {
                id: repeater

                model: fuelProviders

                delegate: FuelProviderItem {}
            }
        }
    }
}