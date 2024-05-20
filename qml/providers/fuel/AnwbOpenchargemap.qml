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

Item {
    id: anwb_openchargemap

    property bool loading: false

    property var lowestPrice: -1
    property var lowestPriceStation: -1

    property string bounds

    property string fuelSource: {
        switch (settings.fuelType) {
            case 0: return "https://api.anwb.nl/v2/pois?fuelTypes=euro95&types=fuel&details=full";
            case 1: return "https://api.anwb.nl/v2/pois?fuelTypes=euro98&types=fuel&details=full";
            case 2: return "https://api.anwb.nl/v2/pois?fuelTypes=diesel&types=fuel&details=full";
            case 3: return "https://api.anwb.nl/v2/pois?fuelTypes=autogas&types=fuel&details=full";
            case 4: return "https://api.openchargemap.io/v3/poi?key=" + root.openchargemapKey;
            default: return "";
        }
    }

    property string fuelType: {
        switch (settings.fuelType) {
            case 0: return "euro95";
            case 1: return "euro98";
            case 2: return "diesel";
            case 3: return "autogas";
            case 4: return "electric";
            default: return "";
        }
    }

    // Get the current fuel prices and information from the API
    function getFuelPrices(isRetry = false) {
        loading = true;
        var request = new XMLHttpRequest();
        var currentLatitude = settings.currentLatitude;
        var currentLongitude = settings.currentLongitude;
        var searchRadius = settings.searchRadius;
        var fuelSourceUrl = fuelSource;
        var apiKey = isRetry ? root.anwbKeyBackup : root.anwbKey;

        if (currentLatitude === undefined || currentLongitude === undefined) {
            return;
        }

        var bounds = calculateBounds(currentLatitude, currentLongitude, searchRadius);

        if (fuelType === "electric") {
            fuelSourceUrl += `&latitude=${currentLatitude}&longitude=${currentLongitude}&distance=${searchRadius}&distanceunit=km`;
        } else {
            fuelSourceUrl += `&bounds=${bounds}&apikey=${apiKey}`;
        }

        request.open("GET", fuelSourceUrl);

        request.onreadystatechange = function() {
            if (request.readyState == XMLHttpRequest.DONE) {
                if (request.status && request.status === 200) {
                    var responseData = JSON.parse(request.responseText);
                    
                    var list;
                    if (fuelType === "electric") {
                        list = responseData;
                    } else {
                        list = responseData.pois;
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
                            var price = "";
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
                                "distance": parseFloat(distance.toFixed(1))
                            });
                        }
                    } else {
                        for (var k in list) {
                            var fuelTypes = list[k].fuels;
                            var currentFuelType = fuelTypes.find(fuel => fuel.type === fuelType);

                            if (!currentFuelType || !currentFuelType.price || currentFuelType.price.value === null || currentFuelType.price.value === undefined) {
                                continue;
                            }
                            
                            if (calcCrow(currentLatitude, currentLongitude, list[k].geo.latitude, list[k].geo.longitude) < searchRadius) {
                                fuelListModel.append({
                                    "address": list[k].address.displayAddress,
                                    "organization": list[k].displayName ? list[k].displayName : list[k].name,
                                    "points": 0,
                                    "connections": [],
                                    "highestpower": 0,
                                    "town": list[k].address.displayAddress.split(',')[1].trim(),
                                    "latitude": list[k].geo.latitude,
                                    "longitude": list[k].geo.longitude,
                                    "price": currentFuelType ? (currentFuelType.price.value / Math.pow(10, currentFuelType.price.scale)).toString() : null,
                                    "distance": Math.round(calcCrow(settings.currentLatitude, settings.currentLongitude, list[k].geo.latitude, list[k].geo.longitude) * 10) / 10
                                });
                            }
                        }
                    }

                    fuelListModel.quick_sort();
                    fuelPage.fuelListView.positionViewAtBeginning();
                    loading = false;
                    findLowestPrice();
                } else {
                    console.log("HTTP:", request.status, request.statusText);
                    
                    if (!isRetry) {
                        // Retry with backup API key
                        getFuelPrices(true);
                    }
                    
                    loading = false;
                }
            }
        };
        request.send();
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
}
