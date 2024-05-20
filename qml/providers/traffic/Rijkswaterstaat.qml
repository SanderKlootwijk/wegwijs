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
    id: rijkswaterstaat

    property bool hasJams: true
    property bool hasClosures: true
    property bool hasRoadworks: true
    property bool hasSpeedcameras: false
    
    property bool loading: false

    property int numberOfJams: -1
    property int totalLengthOfJams: -1

    property string trafficSource: "https://api.rwsverkeersinfo.nl/api/traffic/"

    // Get traffic data from the API
    function getTrafficData() {
        loading = true;
        var request = new XMLHttpRequest();
        request.open("GET", trafficSource);
        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (request.status === 200) {
                    var responseData = JSON.parse(request.responseText);
                    handleTrafficData(responseData.obstructions);

                    numberOfJams = responseData.numberOfJams;
                    totalLengthOfJams = responseData.totalLengthOfJams / 1000;
                } else {
                    console.log("HTTP:", request.status, request.statusText);
                }
                trafficPage.trafficListView.positionViewAtBeginning();
                loading = false;
            }
        };
        request.send();
    }

    function handleTrafficData(obstructions) {
        var roadData = {};

        var obstructionTypes = []

        if (settings.showJams) {
            obstructionTypes.push("jams")
        }
        if (settings.showClosures) {
            obstructionTypes.push("closures")
        }
        if (settings.showRoadworks) {
            obstructionTypes.push("roadworks")
        }
        if (settings.showSpeedcameras) {
            obstructionTypes.push("speedcameras")
        }

        // Organize obstructions by road number
        for (var i = 0; i < obstructions.length; i++) {
            var obstruction = obstructions[i];

            if (obstructionTypes.includes(getObstructionTypeString(obstruction.obstructionType))) {
                if (!roadData[obstruction.roadNumber]) {
                    roadData[obstruction.roadNumber] = {
                        obstructions: [],
                        roadworksCount: 0,
                        jamsCount: 0,
                        closuresCount: 0
                    };
                }
                roadData[obstruction.roadNumber].obstructions.push(obstruction);

                // Increment the count for the respective obstruction type
                if (obstruction.obstructionType === 1) {
                    roadData[obstruction.roadNumber].roadworksCount++;
                } else if (obstruction.obstructionType === 4) {
                    roadData[obstruction.roadNumber].jamsCount++;
                } else if (obstruction.obstructionType === 7) {
                    roadData[obstruction.roadNumber].closuresCount++;
                }
            }
        }

        trafficListModel.clear();

        // Iterate over each road number and handle its obstructions
        for (var roadNumber in roadData) {
            var roadObstructions = roadData[roadNumber].obstructions;
            var roadList = {
                roadNumber: roadNumber,
                roadColor: getRoadColor(roadNumber),
                attributes: [],
                jamsCount: roadData[roadNumber].jamsCount,
                roadworksCount: roadData[roadNumber].roadworksCount,
                closuresCount: roadData[roadNumber].closuresCount,
                speedcamerasCount: 0
            };

            // Sort obstructions by obstructionType (jams first, then closures, and lastly roadworks)
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

                var obstructionType = getObstructionTypeString(obstruction.obstructionType);
                var description = (obstruction.obstructionType === 1) ? obstruction.description : "";
                var locationText = obstruction.locationText;
                var timeEnd = (obstruction.obstructionType === 1) ? formatDate(obstruction.timeEnd) : "";
                var title = obstruction.title.replace(/Verbindingsweg afgesloten op verbindingsweg/, "Verbindingsweg afgesloten");
                var description;
                if (obstructionType === "jams") {
                    description = title + ". " + locationText;
                } else if (obstructionType === "roadworks") {
                    description = (description.length > 1) ? title + ". " + description + "<br><br>" + timeEnd + "." : title + ". " + locationText + "<br><br>" + timeEnd + ".";
                } else if (obstructionType === "closures") {
                    description = title + cause + ". " + locationText;
                } else {
                    description = "";
                }

                var data = {
                    "obstructionType": obstructionType,
                    "direction": obstruction.directionText.replace(/Knooppunt/g, "knp.").replace(/ - /, " ➜ "),
                    "delay": (obstruction.obstructionType === 4) ? obstruction.delay : 0,
                    "length": (obstruction.obstructionType === 1) ? "0" : lengthInKm.toFixed(1),
                    "description": description,
                    "information": "",
                    "informationColor": ""
                };

                roadList.attributes.push(data);
            }
            
            trafficListModel.append(roadList);
        }
    }
    
    // Convert numerical obstruction types to their corresponding strings
    function getObstructionTypeString(type) {
        switch (type) {
            case 1:
                return "roadworks";
            case 4:
                return "jams";
            case 7:
                return "closures";
            default:
                return "";
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
}
