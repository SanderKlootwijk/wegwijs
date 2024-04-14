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
    id: connectionItem
    
    width: parent.width

    height: units.gu(6.5)

    Rectangle {        
        width: parent.width
        height: units.dp(1)

        anchors.fill: parent

        color: theme.palette.normal.background
    }

    Image {
        id: connectionTypeImage

        width: units.gu(3.5)
        height: units.gu(3.5)

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }

        source: "../img/connection-" + connectiontypeid + ".svg"
        smooth: true
    }

    ColorOverlay {
        anchors.fill: connectionTypeImage

        source: connectionTypeImage

        color: theme.palette.normal.foregroundText
    }

    Item {
        id: connectionLabels

        width: parent.width - connectionTypeImage.width - connectionPowerLabel.width - units.gu(7)
        height: units.gu(4)

        anchors {
            left: connectionTypeImage.right
            leftMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
        }

        Label {
            width: parent.width

            anchors {
                left: parent.left
                top: parent.top
            }

            text: connectiontypetitle

            elide: Text.ElideRight
            font.bold: true
        }

        Label {
            width: parent.width

            anchors {
                left: parent.left
                bottom: parent.bottom
            }

            text: quantity == 1 ? quantity + " " + i18n.tr("charging point") : quantity + " " + i18n.tr("charging points")

            elide: Text.ElideRight
        }
    }

    Label {
        id: connectionPowerLabel
        
        width: contentWidth
        
        anchors {
            right: parent.right
            rightMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }
        
        text: power + " kW"
    }
}