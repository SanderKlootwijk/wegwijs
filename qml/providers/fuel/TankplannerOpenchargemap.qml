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
    id: tankplanner_openchargemap

    // Each fuel provider should have the following properties:

    property bool loading: false

    property var lowestPrice: -1
    property var lowestPriceStation: -1

    property string fuelSource: {
        switch (settings.fuelType) {
            case 0: return "https://www.tankplanner.nl/api/v1/price/euro95/";
            case 1: return "https://www.tankplanner.nl/api/v1/price/euro98/";
            case 2: return "https://www.tankplanner.nl/api/v1/price/diesel/";
            case 3: return "https://www.tankplanner.nl/api/v1/price/lpg/";
            case 4: return "https://api.openchargemap.io/v3/poi?key=" + root.openchargemapKey;
            default: return "";
        }
    }

    // Get the current fuel prices and information from the API
    function getFuelPrices() {
        loading = true;
        var request = new XMLHttpRequest();
        var currentLatitude = settings.currentLatitude;
        var currentLongitude = settings.currentLongitude;
        var searchRadius = settings.searchRadius;
        var fuelType = settings.fuelType;
        var fuelSourceUrl = fuelSource;

        if (fuelType === 4) {
            fuelSourceUrl += `&latitude=${currentLatitude}&longitude=${currentLongitude}&distance=${searchRadius}&distanceunit=km`;
        }

        request.open("GET", fuelSourceUrl);
        request.onreadystatechange = function() {
            if (request.readyState == XMLHttpRequest.DONE) {
                if (request.status && request.status === 200) {
                    var list = JSON.parse(request.responseText);
                    fuelListModel.clear();

                    if (fuelType === 4) {
                        for (var i = 0; i < list.length; i++) {
                            var chargingStation = list[i];

                            var address = chargingStation.AddressInfo.Title;
                            var organization = chargingStation.OperatorInfo ? chargingStation.OperatorInfo.Title : i18n.tr("Charging station");
                            var points = chargingStation.NumberOfPoints;
                            var highestpower = getHighestPowerKW(chargingStation.Connections);
                            var town = chargingStation.AddressInfo.Town;
                            var latitude = chargingStation.AddressInfo.Latitude;
                            var longitude = chargingStation.AddressInfo.Longitude;
                            var price = chargingStation.UsageCost;
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
                                "distance": distance.toFixed(1)
                            });
                        }
                    } else {
                        for (var k in list) {
                            if (calcCrow(currentLatitude, currentLongitude, list[k].gps[0], list[k].gps[1]) < searchRadius) {
                                fuelListModel.append({
                                    "address": list[k].address,
                                    "organization": list[k].organization,
                                    "points": 0,
                                    "connections": [],
                                    "highestpower": 0,
                                    "town": list[k].town,
                                    "latitude": list[k].gps[0],
                                    "longitude": list[k].gps[1],
                                    "price": list[k].price.toString(),
                                    "distance": (Math.round(calcCrow(settings.currentLatitude, settings.currentLongitude, list[k].gps[0], list[k].gps[1]) * 10) / 10).toString()
                                });
                            }
                        }
                    }
                } else {
                    console.log("HTTP:", request.status, request.statusText);
                }
                fuelListModel.quick_sort();
                fuelPage.fuelListView.positionViewAtBeginning();
                loading = false;
                findLowestPrice();
            }
        };
        request.send();
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
