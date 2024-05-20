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
    id: trafficProviderSettingsPage

    header: PageHeader {
        id: trafficProviderSettingsPageHeader
        
        title: i18n.tr("Traffic")

        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: i18n.tr("Back")
                onTriggered: adaptivePageLayout.removePages(trafficProviderSettingsPage)
            }
        ]
    }

    Scrollbar {
        z: 1
        id: scrollTrafficProviderSettings

        flickableItem: flickTrafficProviderSettings
        align: Qt.AlignTrailing
    }

    Flickable {
        id: flickTrafficProviderSettings

        anchors {
            fill: parent
            topMargin: trafficProviderSettingsPageHeader.height
        }

        contentWidth: columnTrafficProviderSettings.width
        contentHeight: columnTrafficProviderSettings.height

        Column {
            id: columnTrafficProviderSettings

            width: trafficProviderSettingsPage.width

            Repeater {
                id: repeater

                model: trafficProviders

                delegate: TrafficProviderItem {}
            }
        }
    }
}