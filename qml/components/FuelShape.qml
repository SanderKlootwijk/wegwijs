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

LomiriShape {
    height: units.gu(7)
    width: units.gu(7)

    property int fuelType

    Label {
        id: fuelShapeLabel

        anchors {
            top: parent.top
            topMargin: units.gu(1)
            horizontalCenter: parent.horizontalCenter
        }

        color: "#FFFFFF"
        textSize: text.length > 7 ? Label.XSmall : Label.Small
        font.bold: true
        
        text: {
            if (fuelType == 0) {
                "Euro 95"
            }
            else if (fuelType == 1) {
                "Euro 98"
            }
            else if (fuelType == 2) {
                "Diesel"
            }
            else if (fuelType == 3) {
                "LPG"
            }
            else if (fuelType == 4) {
                i18n.tr("Electric")
            }
        }
    }

    Item {
        anchors {
            left: parent.left
            right: parent.right
            top: fuelShapeLabel.bottom
            bottom: parent.bottom
        }

        Icon {
            width: units.gu(2.5)
            height: units.gu(2.5)

            anchors.centerIn: parent

            source: "../img/" + fuelType + ".svg"
        }
    }
    
    aspect: LomiriShape.Flat 
    
    backgroundColor: {
        if (fuelType == 0) {
            "#057535"
        }
        else if (fuelType == 1) {
            "#057535"
        }
        else if (fuelType == 2) {
            "#333333"
        }
        else if (fuelType == 3) {
            "#057535"
        }
        else if (fuelType == 4) {
            "#00bc4b"
        }
    }
}