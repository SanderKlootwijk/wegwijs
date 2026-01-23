/*
* Copyright (C) 2026  Sander Klootwijk
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
    id: warningItem
    
    width: parent.width
    height: descriptionLabel.implicitHeight + units.gu(6)

    Icon {
        id: warningIcon

        height: units.gu(2.5)
        width: units.gu(2.5)

        name: 'dialog-warning-symbolic'
        color: theme.palette.normal.foregroundText
        
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            top: parent.top
            topMargin: units.gu(1)
        }
    }

    Label {
        id: titleLabel
        
        width: parent.width - warningIcon.width - units.gu(6)
        
        anchors {
            left: warningIcon.right
            leftMargin: units.gu(1)
            verticalCenter: warningIcon.verticalCenter
        }
        
        text: i18n.tr("Traffic warning")
        font.bold: true

        wrapMode: Text.WordWrap
    }

    Label {
        id: descriptionLabel
        
        width: parent.width - units.gu(4)
        
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            top: warningIcon.bottom
            topMargin: units.gu(1)
        }
        
        text: description

        wrapMode: Text.WordWrap
    }
}