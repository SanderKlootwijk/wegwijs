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
    id: connectionTypeItem

    height: units.gu(6)

    property string name
    property int connectiontypeid
    property variant connectiontypes

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

    Label {
        width: parent.width - connectionTypeImage.width - checkBox.width - units.gu(8)

        anchors {
            verticalCenter: parent.verticalCenter
    
            left: parent.left
            leftMargin: units.gu(4) + connectionTypeImage.width
        }

        text: name
        
        elide: Text.ElideRight
    }

    CheckBox {
        id: checkBox

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: units.gu(2)    
        }

        checked: searchForArray(settings.connectionTypes, connectiontypes) == -1 ? false : true
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        enabled: !filterPage.arraysUpdating

        onClicked: {
            filterPage.arrayUpdating = true

            var index = searchForArray(settings.connectionTypes, connectiontypes)
            
            if (index !== -1) {
                if(!isOnlyArrayInNestedArray(settings.connectionTypes, connectiontypes)) {
                    var tempArray = settings.connectionTypes.slice()
                    tempArray.splice(index, 1)
                    settings.connectionTypes = tempArray
                }
            }
            else {            
                var tempArray = settings.connectionTypes.slice()
                tempArray.push(connectiontypes)
                settings.connectionTypes = tempArray
            }

            filterPage.filtersChanged = true
            filterPage.arrayUpdating = false
        }
    }

    function searchForArray(array, target) {
        for (var i = 0; i < array.length; i++) {
            if (arraysEqual(array[i], target)) {
                return i;
            }
        }
        return -1;
    }

    function arraysEqual(a, b) {
        if (a.length !== b.length) return false;
        for (var i = 0; i < a.length; i++) {
            if (a[i] !== b[i]) return false;
        }
        return true;
    }

    function isOnlyArrayInNestedArray(nestedArray, targetArray) {
        if (nestedArray.length !== 1) return false;
        return arraysEqual(nestedArray[0], targetArray);
    }
}