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
import Lomiri.Connectivity 1.0
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtPositioning 5.2
import "components"
import "pages"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'wegwijs.sanderklootwijk'
    automaticOrientation: true
    anchorToKeyboard: true

    width: units.gu(45)
    height: units.gu(75)

    theme.name: {
        switch (settings.theme) {
            case 0: return "";
            case 1: return "Lomiri.Components.Themes.Ambiance";
            case 2: return "Lomiri.Components.Themes.SuruDark";
            default: return "";
        }
    }

    // To use the Geocoding key API for the search function, insert a key below
    property string geocodeKey: ""
    // To use the Open Charge Map API, insert a key below
    property string openchargemapKey: ""
    
    property string locationSource
    property string tempLatitude
    property string tempLongitude
    
    property bool searchLoading: false

    property string version: "1.5.0"
    property int firstRunSlide: 0

    // Fuel
    property bool fuelLoading: false
    property var lowestPrice: -1
    property var lowestPriceStation: -1
    property string bounds

    property string fuelType: {
        switch (settings.fuelType) {
            case 0: return "EURO95";
            case 1: return "EURO98";
            case 2: return "DIESEL";
            case 3: return "AUTOGAS";
            case 4: return "electric";
            default: return "";
        }
    }

    // Traffic
    property bool trafficLoading: false

    property int numberOfJams: -1
    property int totalLengthOfJams: -1
    
    Settings {
        id: settings

        property int theme: 0

        property int fuelType: 0
        property int searchRadius: 4
        property double currentLatitude: 0
        property double currentLongitude: 0

        property var minimumKw: 0
        property var maximumKw: 350
        property variant connectionTypes: [[1],[25, 1036],[2],[32],[33],[27],[8, 30]]
        
        property bool showJams: true
        property bool showRoadworks: false
        property bool showSpeedcameras: true
        
        property bool firstRun: true

        Component.onCompleted: {
            if (settings.currentLatitude !== 0) {
                settings.firstRun = false
            }
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
                fetchTrafficData()
                fetchFuelPrices()
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

    ListModel {
        id: warningsListModel
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

    GpsPage {
        id: gpsPage

        visible: false
        
        anchors.fill: parent
    }

    FilterPage {
        id: filterPage

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

    // Functions

    // Fetch current fuel prices and information
    function fetchFuelPrices() {
        var xhr = new XMLHttpRequest();

        var lat = settings.currentLatitude;
        var lon = settings.currentLongitude;
        var radius = settings.searchRadius;
        var bounds = calculateBounds(lat, lon, radius);

        // electric
        var minimumKw = settings.minimumKw;
        var maximumKw = settings.maximumKw;
        var connectionTypes = settings.connectionTypes;

        var url;

        if (fuelType === "electric") {
            url = "https://api.openchargemap.io/v3/poi?key=" + root.openchargemapKey + `&latitude=${lat}&longitude=${lon}&distance=${radius}&distanceunit=km&minpowerkw=${minimumKw}&maxpowerkw=${maximumKw}&connectiontypeid=${connectionTypes}`;
        } else {
            url = "https://api.anwb.nl/routing/points-of-interest/v3/all?type-filter=FUEL_STATION&show-all-pois-along-route-filter=true&bounding-box-filter=" + bounds.replace(":", ",");
        }

        fuelLoading = true;

        xhr.open("GET", url, true);

        xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
                        var list;

                        if (fuelType === "electric") {
                            list = JSON.parse(xhr.responseText);
                        } else {
                            var data = JSON.parse(xhr.responseText);
                            list = data.value;
                        }

                        fuelListModel.clear();

                        if (fuelType === "electric") {
                            for (var i = 0; i < list.length; i++) {
                                var chargingStation = list[i];

                                var address = chargingStation.AddressInfo.Title;
                                var organization = chargingStation.OperatorInfo ? chargingStation.OperatorInfo.Title : i18n.tr("Charging station");
                                var points = chargingStation.NumberOfPoints;
                                var highestpower = getHighestPowerKW(chargingStation.Connections);
                                var town = chargingStation.AddressInfo.Town;
                                var latitude = chargingStation.AddressInfo.Latitude;
                                var longitude = chargingStation.AddressInfo.Longitude;
                                var price = 0.0;
                                var distance = chargingStation.AddressInfo.Distance;
                                var connections = [];

                                for (var j = 0; j < chargingStation.Connections.length; j++) {
                                    var connection = chargingStation.Connections[j];

                                    var data = {
                                        "connectiontypeid": connection.ConnectionTypeID,
                                        "connectiontypetitle": connection.ConnectionType.Title,
                                        "power": connection.PowerKW !== null ? connection.PowerKW : 0,
                                        "quantity": connection.Quantity !== null ? connection.Quantity : 1
                                    };

                                    connections.push(data);
                                }

                                fuelListModel.append({
                                    "address": address,
                                    "organization": organization.replace(/\(Unknown Operator\)/g, i18n.tr("Charging station")),
                                    "points": points,
                                    "connections": connections,
                                    "highestpower": highestpower,
                                    "town": town,
                                    "latitude": latitude,
                                    "longitude": longitude,
                                    "price": price,
                                    "priceLevel": "",
                                    "distance": parseFloat(distance.toFixed(1))
                                });
                            }
                        } else {
                            for (var j = 0; j < list.length; j++) {
                                var station = list[j];

                                // find requested fuel price
                                var priceObj = station.prices.find(p => p.fuelType === fuelType);
                                if (!priceObj)
                                    continue;
                                
                                var priceLevel = priceObj.priceTier
                                ? (priceObj.priceTier.value === 1 ? "LOW" :
                                priceObj.priceTier.value === 2 ? "AVG" :
                                priceObj.priceTier.value === 3 ? "HIGH" : "")
                                : "";

                                var sLat = station.coordinates.latitude;
                                var sLon = station.coordinates.longitude;
                                var distance = calcCrow(lat, lon, sLat, sLon);

                                if (distance > radius)
                                    continue;

                                fuelListModel.append({
                                    "address": station.address.streetAddress,
                                    "organization": station.title,
                                    "points": 0,
                                    "connections": [],
                                    "highestpower": 0,
                                    "town": station.address.city,
                                    "latitude": sLat,
                                    "longitude": sLon,
                                    "price": priceObj.value,
                                    "priceLevel": priceLevel,
                                    "distance": Math.round(distance * 10) / 10
                                });
                            }
                        }

                        fuelListModel.quick_sort();
                        fuelPage.fuelListView.positionViewAtBeginning();

                        fuelLoading = false;

                        findLowestPrice();
                    } else {
                        console.log("Failed to fetch fuel prices:", xhr.status, xhr.statusText);
                    
                        fuelLoading = false;
                    }
                }
        }
        
        xhr.send();
    }

    function calculateBounds(lat, lon, radius) {
        // Earth's radius in kilometers
        const earthRadius = 6371; 

        // Convert latitude and longitude from degrees to radians
        const latRad = lat * Math.PI / 180;
        const lonRad = lon * Math.PI / 180;

        // Convert radius from kilometers to radians
        const radiusRad = radius / earthRadius;

        // Calculate the maximum and minimum latitudes
        const maxLat = lat + (radiusRad * (180 / Math.PI));
        const minLat = lat - (radiusRad * (180 / Math.PI));

        // Calculate the maximum and minimum longitudes
        const maxLon = lon + (radiusRad / Math.cos(latRad)) * (180 / Math.PI);
        const minLon = lon - (radiusRad / Math.cos(latRad)) * (180 / Math.PI);

        return `${parseFloat(minLat).toFixed(6)},${parseFloat(minLon).toFixed(6)}:${parseFloat(maxLat).toFixed(6)},${parseFloat(maxLon).toFixed(6)}`;
    }

    // Sort fuel prices by lowest price
    function findLowestPrice() {
        if (fuelListModel.count === 0) {
            lowestPrice = -1;
            lowestPriceStation = -1;
            return null;
        }

        var minItem = fuelListModel.get(0);

        for (var i = 1; i < fuelListModel.count; ++i) {
            var currentItem = fuelListModel.get(i);
            if (currentItem.price < minItem.price) {
                minItem = currentItem;
            }
        }

        lowestPrice = minItem.price;
        lowestPriceStation = minItem.organization + " " + minItem.town;
    }

    // Get highest PowerKW from a charging station
    function getHighestPowerKW(connections) {
        let highestPowerKW = 0;

        connections.forEach(connection => {
            if (connection.PowerKW > highestPowerKW) {
                highestPowerKW = connection.PowerKW;
            }
        });

        return highestPowerKW;
    }

    // Fetch traffic data from the API
    function fetchTrafficData() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://api.anwb.nl/routing/v1/incidents/incidents-desktop", true);

        trafficLoading = true;
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    let data = JSON.parse(xhr.responseText);
                    let roads = data.roads;
                    let warnings = data.warnings;

                    numberOfJams = data.totals.all.count;
                    totalLengthOfJams = data.totals.all.distance;

                    trafficListModel.clear();

                    var roadList = [];

                    // Iterate over each road number and handle its obstructions
                    for (var i = 0; i < roads.length; i++) {
                        var road = roads[i];

                        var attributes = [];
                        var jamsCount = 0;
                        var roadworksCount = 0;
                        var speedcamerasCount = 0;

                        // Handle obstruction for the current road
                        for (var j = 0; j < road.segments.length; j++) {
                            var segment = road.segments[j];

                            var direction = segment.start ? segment.start + " ➜ " + segment.end : "";

                            if (segment.jams) {
                                if (settings.showJams) {
                                    for (var k = 0; k < segment.jams.length; k++) {
                                        var jam = segment.jams[k];

                                        var lengthInKm = jam.distance !== undefined ? jam.distance / 1000 : 0;
                                        
                                        jamsCount++

                                        var jams = {
                                            "obstructionType": "jams",
                                            "direction": direction,
                                            "delay": jam.delay !== undefined ? jam.delay / 60 : 0,
                                            "length": lengthInKm.toFixed(1),
                                            "description": jam.from === jam.to ? jam.from + "<br><br><i>" + jam.reason + "</i>" : jam.from + " - " + jam.to + "<br><br><i>" + jam.reason + "</i>",
                                            "information": "",
                                            "informationColor": ""
                                        };
                                        
                                        attributes.push(jams);
                                    }
                                }
                            }

                            if (segment.roadworks) {
                                if (settings.showRoadworks) {
                                    for (var l = 0; l < segment.roadworks.length; l++) {
                                        var roadwork = segment.roadworks[l];

                                        roadworksCount++

                                        var roadworks = {
                                            "obstructionType": "roadworks",
                                            "direction": direction,
                                            "delay": 0,
                                            "length": "0",
                                            "description": roadwork.from === roadwork.to ? roadwork.from + "<br><br><i>" + roadwork.reason + "</i>" : roadwork.from + " - " + roadwork.to + "<br><br><i>" + roadwork.reason + "</i>",
                                            "information": "",
                                            "informationColor": ""
                                        };
                                        
                                        attributes.push(roadworks);
                                    }
                                }
                            }

                            if (segment.radars) {
                                if (settings.showSpeedcameras) {
                                    for (var m = 0; m < segment.radars.length; m++) {
                                        var speedcamera = segment.radars[m];

                                        speedcamerasCount++

                                        var speedcameras = {
                                            "obstructionType": "speedcameras",
                                            "direction": direction,
                                            "delay": 0,
                                            "length": "0",
                                            "description": speedcamera.from === speedcamera.to ? speedcamera.from : speedcamera.from + " - " + speedcamera.to,
                                            "information": speedcamera.HM ? speedcamera.HM.toString() : "",
                                            "informationColor": "#00A651"
                                        };
                                        
                                        attributes.push(speedcameras);
                                    }
                                }
                            }
                        }

                        // Push each road object into roadList
                        if (attributes.length > 0) {
                            roadList.push({
                                roadNumber: road.road,
                                roadType: road.type,
                                attributes: attributes,
                                jamsCount: jamsCount,
                                roadworksCount: roadworksCount,
                                speedcamerasCount: speedcamerasCount
                            });
                        }
                    }

                    trafficListModel.append(roadList);                    

                    warningsListModel.clear();

                    warnings.forEach(warning => {
                        warningsListModel.append({ description: warning });
                    });
                    
                    trafficPage.trafficListView.positionViewAtBeginning();
                    trafficLoading = false;
                } else {
                    console.log("Failed to fetch traffic information:", xhr.status, xhr.statusText);
                    
                    trafficLoading = false;
                }
            }
        };
        xhr.send();
    }

    // Fetch locations
    function fetchLocations(term) {
        var xhr = new XMLHttpRequest();

        var retries = 3;
        var retryDelay = 1000;
        var retryTimer = Qt.createQmlObject('import QtQuick 2.7; Timer {}', searchPage);

        searchLoading = true;
        
        function makeRequest() {
            xhr.open("GET", "https://geocode.maps.co/search?q=" + term + "&api_key=" + root.geocodeKey, true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState == XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
                        var list = JSON.parse(xhr.responseText);

                        searchPage.locationListModel.clear();

                        for (var i in list) {
                            searchPage.locationListModel.append({ 
                                "name": list[i].display_name, 
                                "latitude": Number(list[i].lat), 
                                "longitude": Number(list[i].lon) 
                            });
                        }
                        
                        searchLoading = false;
                    } else if (xhr.status === 429 && retries > 0) {
                        // Retry after a delay
                        retryTimer.interval = retryDelay;
                        retryTimer.repeat = false;
                        retryTimer.triggered.connect(makeRequest);
                        retryTimer.start();
                        retries--;
                    } else {
                        console.log("Failed to fetch locations:", xhr.status, xhr.statusText);
                        searchLoading = false;
                    }
                }
            };
            xhr.send();
        }

        makeRequest();
    }

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
}
