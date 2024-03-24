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

    theme.name: {
        switch (settings.theme) {
        case 0:
            ""
            break
        case 1:
            "Ubuntu.Components.Themes.Ambiance"
            break
        case 2:
            "Ubuntu.Components.Themes.SuruDark"
            break
        default:
            ""
        }
    }


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

    width: units.gu(45)
    height: units.gu(75)

    // To use the Geocoding key API for the search function, insert a key below
    property string geocodeKey: ""
    property string trafficSource: "https://api.rwsverkeersinfo.nl/api/traffic/"
    property string fuelSource: {
        if (settings.fuelType == 0) {
            "https://www.tankplanner.nl/api/v1/price/euro95/"
        }
        else if (settings.fuelType == 1) {
            "https://www.tankplanner.nl/api/v1/price/euro98/"
        }
        else if (settings.fuelType == 2) {
            "https://www.tankplanner.nl/api/v1/price/diesel/"
        }
        else if (settings.fuelType == 3) {
            "https://www.tankplanner.nl/api/v1/price/lpg/"
        }
    }

    property int numberOfJams: -1
    property int totalLengthOfJams: -1
    property int numberOfRoadworks: -1
    property var obstructionTypes: [1, 4, 7]
    
    property string locationSource
    property string tempLatitude
    property string tempLongitude
    property var lowestPrice: -1
    property var lowestPriceStation: -1
    
    property bool trafficLoading: false
    property bool fuelLoading: false
    property bool searchLoading: false

    property string version: "1.0.0"
    property int firstRunSlide: 0

    Settings {
        id: settings

        property int theme: 0

        property int fuelType: 0
        property int searchRadius: 4
        property var currentLatitude
        property var currentLongitude

        property bool obstructionType1: false
        property bool obstructionType4: true
        property bool obstructionType7: true
        
        property bool firstRun: true

        onSearchRadiusChanged: {
            getFuelPrices()
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
                getFuelPrices()
                getTrafficData()
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

    // Takes latitude and longitude of two locations and returns the distance between them as the crow flies (in km)
    function calcCrow(lat1, lon1, lat2, lon2) 
    {
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
    function toRad(Value) 
    {
        return Value * Math.PI / 180;
    }

    // Get the current fuel prices and information from the API
    function getFuelPrices() {
        root.fuelLoading = true;
        var request = new XMLHttpRequest;
        request.open("GET", fuelSource);
        request.onreadystatechange = function() {
            if (request.readyState == XMLHttpRequest.DONE) {
                if (request.status && request.status === 200) {
                    var list = JSON.parse(request.responseText);
                    fuelListModel.clear();
                    for (var i in list)
                        if (calcCrow(settings.currentLatitude, settings.currentLongitude, list[i].gps[0], list[i].gps[1]) < settings.searchRadius) {
                            fuelListModel.append({ "organization": list[i].organization, "address": list[i].address, "town": list[i].town, "latitude": list[i].gps[0], "longitude": list[i].gps[1], "price": list[i].price, "distance": Math.round(calcCrow(settings.currentLatitude, settings.currentLongitude, list[i].gps[0], list[i].gps[1]) * 10) / 10 });
                        }
                }
                else {
                    console.log("HTTP:", request.status, request.statusText)
                }
                fuelListModel.quick_sort()
                fuelPage.fuelListView.positionViewAtBeginning()
                root.fuelLoading = false;
                findLowestPrice()
            }
        }
        request.send();
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

        root.lowestPrice = minItem.price;
        root.lowestPriceStation = minItem.organization + " " + minItem.town;
    }

    // Get traffic data from the API
    function getTrafficData() {
        root.trafficLoading = true;
        var request = new XMLHttpRequest();
        request.open("GET", trafficSource);
        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (request.status === 200) {
                    handleTrafficData(JSON.parse(request.responseText).obstructions);

                    root.numberOfJams = JSON.parse(request.responseText).numberOfJams;
                    root.totalLengthOfJams = JSON.parse(request.responseText).totalLengthOfJams / 1000;
                    root.numberOfRoadworks = JSON.parse(request.responseText).numberOfRoadworks;
                } else {
                    console.log("HTTP:", request.status, request.statusText);
                }
                trafficPage.trafficListView.positionViewAtBeginning();
                root.trafficLoading = false;
            }
        };
        request.send();
    }

    function handleTrafficData(obstructions) {
        var roadData = {};

        // Organize obstructions by road number
        for (var i = 0; i < obstructions.length; i++) {
            var obstruction = obstructions[i];
            if (root.obstructionTypes.includes(obstruction.obstructionType)) {
                if (!roadData[obstruction.roadNumber]) {
                    roadData[obstruction.roadNumber] = {
                        obstructions: [],
                        obstructionType1Count: 0,
                        obstructionType4Count: 0,
                        obstructionType7Count: 0
                    };
                }
                roadData[obstruction.roadNumber].obstructions.push(obstruction);
                // Increment the count for the respective obstruction type
                if (obstruction.obstructionType === 1) {
                    roadData[obstruction.roadNumber].obstructionType1Count++;
                } else if (obstruction.obstructionType === 4) {
                    roadData[obstruction.roadNumber].obstructionType4Count++;
                } else if (obstruction.obstructionType === 7) {
                    roadData[obstruction.roadNumber].obstructionType7Count++;
                }
            }
        }

        trafficListModel.clear();

        // Iterate over each road number and handle its obstructions
        for (var roadNumber in roadData) {
            var roadObstructions = roadData[roadNumber].obstructions;
            var roadList = {
                roadNumber: roadNumber,
                attributes: [],
                obstructionType1Count: roadData[roadNumber].obstructionType1Count,
                obstructionType4Count: roadData[roadNumber].obstructionType4Count,
                obstructionType7Count: roadData[roadNumber].obstructionType7Count
            };

            // Sort obstructions by obstructionType (4 first, then 7, and lastly 1)
            roadObstructions.sort(function(a, b) {
                if (a.obstructionType === 4) {
                    return -1;
                } else if (b.obstructionType === 4) {
                    return 1;
                } else if (a.obstructionType === 7) {
                    return -1;
                } else if (b.obstructionType === 7) {
                    return 1;
                } else {
                    return a.obstructionType - b.obstructionType;
                }
            });

            // Handle obstructions for the current road
            for (var j = 0; j < roadObstructions.length; j++) {
                var obstruction = roadObstructions[j];
                var lengthInKm = obstruction.length / 1000;
                
                const causeReplacements = [
                    { pattern: /Ongeval\(len\)/, replacement: " door een ongeval" },
                    { pattern: /Wegwerkzaamheden/, replacement: " door wegwerkzaamheden" },
                    { pattern: /Bergingswerkzaamheden/, replacement: " door bergingswerkzaamheden" },
                    { pattern: /Ongevalsonderzoek/, replacement: " door een ongevalsonderzoek" },
                    { pattern: /Wegdek in slechte toestand/, replacement: " door slecht wegdek" },
                    { pattern: /Technische storing/, replacement: " door een technische storing" },
                    { pattern: /Defect voertuig/, replacement: " door een defect voertuig" },
                    { pattern: /Defecte vrachtwagen/, replacement: " door een defecte vrachtwagen" },
                    { pattern: /Ongeval met vrachtwagen/, replacement: " door een ongeval met een vrachtwagen" },
                    { pattern: /Opruimwerkzaamheden/, replacement: " door opruimwerkzaamheden" },
                    { pattern: /Te hoog voertuig/, replacement: " door een te hoog voertuig" },
                    { pattern: /Spoedreparatie/, replacement: " door een spoedreparatie" },
                    { pattern: /Gekantelde vrachtwagen/, replacement: " door een gekantelde vrachtwagen" },
                    { pattern: /Omgewaaide bo\(o\)m\(en\)/, replacement: " door omgewaaide bomen" },
                    { pattern: /Water op de weg/, replacement: " door water op de weg" },
                    { pattern: /Olie op het wegdek/, replacement: " door olie op het wegdek" },
                    { pattern: /Brand in de buurt van de weg/, replacement: " door brand in de buurt van de weg" },
                    { pattern: /Schade aan wegmeubilair/, replacement: " door schade aan wegmeubilair" },
                    { pattern: /Schade aan tunnel/, replacement: " door schade aan tunnel" },
                    { pattern: /Demonstratie/, replacement: " door een demonstratie" }
                ];

                var cause = (obstruction.obstructionType === 7) ? causeReplacements.reduce((acc, { pattern, replacement }) => acc.replace(pattern, replacement), obstruction.cause) : "";

                if (cause === obstruction.cause) {
                    cause = ". " + cause;
                }

                var data = {
                    "obstructionType": obstruction.obstructionType,
                    "title": obstruction.title.replace(/Verbindingsweg afgesloten op verbindingsweg/, "Verbindingsweg afgesloten"),
                    "directionText": obstruction.directionText.replace(/Knooppunt/g, "knp.").replace(/ - /, " ➜ "),
                    "locationText": obstruction.locationText,
                    "delay": (obstruction.obstructionType === 4) ? obstruction.delay : 0,
                    "length": (obstruction.obstructionType === 1) ? "0" : lengthInKm.toFixed(1),
                    "cause": cause,
                    "description": (obstruction.obstructionType === 1) ? obstruction.description : "",
                    "timeEnd": (obstruction.obstructionType === 1) ? formatDate(obstruction.timeEnd) : ""
                };

                roadList.attributes.push(data);
            }

            trafficListModel.append(roadList);
        }
    }

    // Get color for roadShape
    function getRoadColor(text) {
        const match = text.match(/[AN]\d+/);

        if (match) {
            const roadType = match[0][0]; // Get the first character (A or N)
            return roadType === 'A' ? "#FF4500" : roadType === 'N' ? "#FFB400" : null;
        }

        return null;
    }
    
    // Format date to a readable string
    function formatDate(inputDateStr) {
        const inputDateUTC = new Date(inputDateStr + 'Z'); // 'Z' indicates UTC

        const localOffset = 60; // Offset for UTC+1 in minutes
        const inputDate = new Date(inputDateUTC.getTime() + localOffset * 60 * 1000);

        const currentDate = new Date(); // Current date in local time

        // Calculate two months from the current date
        const twoMonthsFromNow = new Date(currentDate);
        twoMonthsFromNow.setMonth(twoMonthsFromNow.getMonth() + 2);

        const isMoreThanTwoMonthsInFuture = inputDate > twoMonthsFromNow;

        const months = ['januari', 'februari', 'maart', 'april', 'mei', 'juni', 'juli', 'augustus', 'september', 'oktober', 'november', 'december'];

        const dayOfMonth = inputDate.getUTCDate();
        const month = months[inputDate.getUTCMonth()];
        const year = inputDate.getUTCFullYear();
        
        if (isMoreThanTwoMonthsInFuture) {
            const outputDateStr = `Periode: tot ${dayOfMonth} ${month} ${year}`;
            return outputDateStr;
        } else {
            const hours = inputDate.getUTCHours();
            const minutes = ('0' + inputDate.getUTCMinutes()).slice(-2);
            const outputDateStr = `Periode: tot ${dayOfMonth} ${month} ${year} ${hours}:${minutes} uur`;
            return outputDateStr;
        }
    }

    // Get locations after a search result
    function getLocations() {
        root.searchLoading = true;
        root.lowestPriceStation = -1
        root.lowestPrice = -1
        
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
