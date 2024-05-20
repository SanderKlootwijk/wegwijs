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
import Lomiri.Connectivity 1.0
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtPositioning 5.2
import "providers/traffic"
import "providers/fuel"
import "components"
import "pages"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'wegwijs.sanderklootwijk'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    anchors {
        fill: parent
        bottomMargin: LomiriApplication.inputMethod.visible ? LomiriApplication.inputMethod.keyboardRectangle.height/(units.gridUnit / 8) : 0
        Behavior on bottomMargin {
            NumberAnimation {
                duration: 175
                easing.type: Easing.OutQuad
            }
        }
    }

    theme.name: {
        switch (settings.theme) {
            case 0: return "";
            case 1: return "Ubuntu.Components.Themes.Ambiance";
            case 2: return "Ubuntu.Components.Themes.SuruDark";
            default: return "";
        }
    }

    property var trafficProviders: [
        {name: "anwb", id: anwb, label: "ANWB", country: i18n.tr("Netherlands")},
        {name: "rijkswaterstaat", id: rijkswaterstaat, label: "Rijkswaterstaat", country: i18n.tr("Netherlands")}
    ]

    property var defaultTrafficProvider: anwb

    property var trafficProvider: {
        for(let i = 0; i < trafficProviders.length; i++) {
            if (trafficProviders[i].name === settings.trafficProvider) {
                return trafficProviders[i].id;
            }
        }

        return defaultTrafficProvider;
    }

    property var fuelProviders: [
        {name: "anwb_openchargemap", id: anwb_openchargemap, label: "ANWB, Open Charge Map", country: i18n.tr("Netherlands")}
        // Tankplanner.nl currently seems to be broken
        //{name: "tankplanner_openchargemap", id: tankplanner_openchargemap, label: "Tankplanner, Open Charge Map", country: i18n.tr("Netherlands")}
    ]

    property var defaultFuelProvider: anwb_openchargemap

    property var fuelProvider: {
        for(let i = 0; i < fuelProviders.length; i++) {
            if (fuelProviders[i].name === settings.fuelProvider) {
                return fuelProviders[i].id;
            }
        }

        return defaultFuelProvider;
    }

    // To use the Geocoding key API for the search function, insert a key below
    property string geocodeKey: ""
    // To use the Open Charge Map API, insert a key below
    property string openchargemapKey: ""
    // To use the ANWB API, insert a key below
    property string anwbKey: ""
    property string anwbKeyBackup: ""
    
    property string locationSource
    property string tempLatitude
    property string tempLongitude
    
    property bool searchLoading: false

    property string version: "1.2.0"
    property int firstRunSlide: 0

    Settings {
        id: settings

        property int theme: 0

        property int fuelType: 0
        property int searchRadius: 4
        property double currentLatitude: 0
        property double currentLongitude: 0

        property string trafficProvider: "anwb"
        property string fuelProvider: "anwb_openchargemap"
        
        property bool showJams: true
        property bool showClosures: true
        property bool showRoadworks: false
        property bool showSpeedcameras: true
        
        property bool firstRun: true

        Component.onCompleted: {
            if (settings.currentLatitude !== 0) {
                settings.firstRun = false
            }
        }

        onSearchRadiusChanged: {
            root.fuelProvider.getFuelPrices()
        }

        onFuelTypeChanged: {
            if (firstRun) {
                settingsPage.fuelTypeOptionSelector.selectedIndex = fuelType
            }
        }
    }

    Connections {
        target: Connectivity
        
        onStatusChanged: {
            if (Connectivity.status == NetworkingStatus.Online) {
                root.trafficProvider.getTrafficData()
                root.fuelProvider.getFuelPrices()
            }
        }
    }

    AdaptivePageLayout {
        id: adaptivePageLayout
        
        anchors.fill: parent
        
        primaryPage: mainPage

        layouts: [
            PageColumnsLayout {
                when: width > units.gu(80) && fuelPage.visible
                // column #0
                PageColumn {
                    minimumWidth: units.gu(40)
                    maximumWidth: units.gu(40)
                    preferredWidth: units.gu(40)
                }
                // column #1
                PageColumn {
                    fillWidth: true
                }
            },
            PageColumnsLayout {
                when: true
                PageColumn {
                    fillWidth: true
                    minimumWidth: units.gu(10)
                }
            }
        ]
    }

    // ListModels, for fuel and for traffic conditions

    ListModel {
        id: fuelListModel

        property string sortColumnName: "price"

        function swap(a,b) {
            if (a<b) {
                move(a,b,1);
                move (b-1,a,1);
            }
            else if (a>b) {
                move(b,a,1);
                move (a-1,b,1);
            }
        }

        function partition(begin, end, pivot) {
            var piv=get(pivot)[sortColumnName];
            swap(pivot, end-1);
            var store=begin;
            var ix;
            for(ix=begin; ix<end-1; ++ix) {
                if(get(ix)[sortColumnName] < piv) {
                    swap(store,ix);
                    ++store;
                }
            }
            swap(end-1, store);

            return store;
        }

        function qsort(begin, end) {
            if (end-1>begin) {
                var pivot=begin+Math.floor(Math.random()*(end-begin));

                pivot=partition( begin, end, pivot);

                qsort(begin, pivot);
                qsort(pivot+1, end);
            }
        }

        function quick_sort() {
            qsort(0,count)
        }
    }

    ListModel {
        id: trafficListModel
    }

    // Pages

    MainPage {
        id: mainPage

        visible: false

        anchors.fill: parent
    }

    SearchPage {
        id: searchPage

        visible: false
        
        anchors.fill: parent
    }

    SettingsPage {
        id: settingsPage

        visible: false

        anchors.fill: parent
    }

    ResultPage {
        id: resultPage

        visible: false

        anchors.fill: parent
    }

    FuelPage {
        id: fuelPage

        visible: false

        anchors.fill: parent
    }

    TrafficPage {
        id: trafficPage

        visible: false

        anchors.fill: parent
    }
    
    AboutPage {
        id: aboutPage

        visible: false

        anchors.fill: parent
    }

    FuelProviderSettingsPage {
        id: fuelProviderSettingsPage

        visible: false

        anchors.fill: parent
    }

    TrafficProviderSettingsPage {
        id: trafficProviderSettingsPage

        visible: false

        anchors.fill: parent
    }

    // Traffic providers

    Anwb {
        id: anwb
    }

    Rijkswaterstaat {
        id: rijkswaterstaat
    }
    
    // Fuel providers

    AnwbOpenchargemap {
        id: anwb_openchargemap
    }

    TankplannerOpenchargemap {
        id: tankplanner_openchargemap
    }

    // Functions

    // Takes latitude and longitude of two locations and returns the distance between them as the crow flies (in km)
    function calcCrow(lat1, lon1, lat2, lon2) {
        var R = 6371; // km
        var dLat = toRad(lat2-lat1);
        var dLon = toRad(lon2-lon1);
        var lat1 = toRad(lat1);
        var lat2 = toRad(lat2);

        var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
        var d = R * c;
        return d;
    }

    // Converts numeric degrees to radians
    function toRad(Value) {
        return Value * Math.PI / 180;
    }

    // Get locations after a search result
    function getLocations() {
        root.searchLoading = true;
        root.fuelProvider.lowestPriceStation = -1
        root.fuelProvider.lowestPrice = -1
        
        var request = new XMLHttpRequest();
        var retries = 3; // Number of retries
        var retryDelay = 1000; // Retry delay in milliseconds

        var retryTimer = Qt.createQmlObject('import QtQuick 2.7; Timer {}', searchPage);

        function makeRequest() {
            request.open("GET", locationSource);
            request.onreadystatechange = function() {
                if (request.readyState == XMLHttpRequest.DONE) {
                    if (request.status === 200) {
                        var list = JSON.parse(request.responseText);
                        searchPage.locationListModel.clear();
                        for (var i in list) {
                            searchPage.locationListModel.append({ 
                                "name": list[i].display_name, 
                                "latitude": Number(list[i].lat), 
                                "longitude": Number(list[i].lon) 
                            });
                        }
                        root.searchLoading = false;
                    } else if (request.status === 429 && retries > 0) {
                        // Retry after a delay
                        retryTimer.interval = retryDelay;
                        retryTimer.repeat = false;
                        retryTimer.triggered.connect(makeRequest);
                        retryTimer.start();
                        retries--;
                    } else {
                        console.log("HTTP:", request.status, request.statusText);
                        root.searchLoading = false;
                    }
                }
            };
            request.send();
        }

        makeRequest();
    }
}
