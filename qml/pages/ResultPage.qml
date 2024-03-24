/*
* Copyright (C) 2023  Sander Klootwijk
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
import QtWebEngine 1.6
import QtWebChannel  1.0
import "../components"

Page {
    id: resultPage

    property alias resultPageHeader: resultPageHeader
    property alias qtObject: qtObject
    property alias webEngineView: webEngineView
    property alias fuelpriceLabel: fuelpriceLabel
    property alias adressLabel: adressLabel

    Component.onCompleted: {
        myWebChannel.registerObject("qtObject",qtObject);   
    }

    header: PageHeader {
        id: resultPageHeader
    }

    WebChannel {
        id: myWebChannel
    }

    QtObject {
        id: qtObject

        signal onRefresh()

        property var latitude
        property var longitude

        onLongitudeChanged: onRefresh()
        onLatitudeChanged: onRefresh()
    }

    Label {
        id: fuelpriceLabel

        anchors {
            top: resultPageHeader.bottom
            topMargin: units.gu(2)
            left: parent.left
            leftMargin: units.gu(2)
        }
    }

    WebEngineView {
        id: webEngineView

        webChannel: myWebChannel

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
            top: fuelpriceLabel.bottom
            topMargin: units.gu(2)
            bottom: navButton.top
            bottomMargin: units.gu(2)
        }

        url: "../webview/index.html"

        onNavigationRequested: function(request) {
            if (request.navigationType === WebEngineNavigationRequest.LinkClickedNavigation) {
                Qt.openUrlExternally(request.url)
                request.action = WebEngineNavigationRequest.IgnoreRequest
            }
        }

    }

    Label {
        id: adressLabel

        width: parent.width - navButton.width - units.gu(5)

        anchors {
            verticalCenter: navButton.verticalCenter
            left: parent.left
            leftMargin: units.gu(2)
        }

        elide: Text.ElideRight
    }

    Button {
        id: navButton

        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
        }

        text: i18n.tr("Navigate")
        strokeColor: theme.palette.normal.baseText

        onClicked: {
            Qt.openUrlExternally("geo:"+qtObject.latitude+","+qtObject.longitude)
        }
    }
}