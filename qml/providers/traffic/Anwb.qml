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
    id: anwb

    property bool hasJams: true
    property bool hasClosures: false
    property bool hasRoadworks: true
    property bool hasSpeedcameras: true

    property bool loading: false

    property int numberOfJams: -1
    property int totalLengthOfJams: -1

    property string trafficSource: "https://api.anwb.nl/v2/incidents/desktop?apikey="

    // Get traffic data from the API
    function getTrafficData(isRetry = false) {
        loading = true;
        var apiKey = isRetry ? root.anwbKeyBackup : root.anwbKey;
        var trafficSourceURL = trafficSource + apiKey;

        var request = new XMLHttpRequest();

        request.open("GET", trafficSourceURL);

        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (request.status === 200) {
                    var responseData = JSON.parse(request.responseText);
                    handleTrafficData(responseData.roads);

                    numberOfJams = responseData.totals.all.count;
                    totalLengthOfJams = responseData.totals.all.distance;

                    trafficPage.trafficListView.positionViewAtBeginning();
                    loading = false;
                } else {
                    console.log("HTTP:", request.status, request.statusText);
                    
                    if (!isRetry) {
                        // Retry with backup API key
                        getTrafficData(true);
                    }
                    
                    loading = false;
                }
            }
        };
        request.send();
    }

    function handleTrafficData(roads) {

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

                            var data = {
                                "obstructionType": "jams",
                                "direction": direction,
                                "delay": jam.delay !== undefined ? jam.delay / 60 : 0,
                                "length": lengthInKm.toFixed(1),
                                "description": jam.from === jam.to ? jam.from + "<br><br><i>" + jam.reason + "</i>" : jam.from + " - " + jam.to + "<br><br><i>" + jam.reason + "</i>",
                                "information": "",
                                "informationColor": ""
                            };
                            
                            attributes.push(data);
                        }
                    }
                }

                if (segment.roadworks) {
                    if (settings.showRoadworks) {
                        for (var l = 0; l < segment.roadworks.length; l++) {
                            var roadwork = segment.roadworks[l];

                            roadworksCount++

                            var data = {
                                "obstructionType": "roadworks",
                                "direction": direction,
                                "delay": 0,
                                "length": "0",
                                "description": roadwork.from === roadwork.to ? roadwork.from + "<br><br><i>" + roadwork.reason + "</i>" : roadwork.from + " - " + roadwork.to + "<br><br><i>" + roadwork.reason + "</i>",
                                "information": "",
                                "informationColor": ""
                            };
                            
                            attributes.push(data);
                        }
                    }
                }

                if (segment.radars) {
                    if (settings.showSpeedcameras) {
                        for (var m = 0; m < segment.radars.length; m++) {
                            var speedcamera = segment.radars[m];

                            speedcamerasCount++

                            var data = {
                                "obstructionType": "speedcameras",
                                "direction": direction,
                                "delay": 0,
                                "length": "0",
                                "description": speedcamera.from === speedcamera.to ? speedcamera.from : speedcamera.from + " - " + speedcamera.to,
                                "information": speedcamera.HM ? speedcamera.HM.toString() : "",
                                "informationColor": "#00A651"
                            };
                            
                            attributes.push(data);
                        }
                    }
                }
            }

            // Push each road object into roadList
            if (attributes.length > 0) {
                roadList.push({
                    roadNumber: road.road,
                    roadColor: getRoadColor(road.road),
                    attributes: attributes,
                    jamsCount: jamsCount,
                    roadworksCount: roadworksCount,
                    closuresCount: 0,
                    speedcamerasCount: speedcamerasCount
                });
            }
        }

        trafficListModel.append(roadList);
    }
    
    // Get color for roadShape
    function getRoadColor(text) {
        const match = text.match(/[AN]\d+/);

        if (match) {
            const roadType = match[0][0]; // Get the first character (A or N)
            return roadType === 'A' ? "#FF4500" : roadType === 'N' ? "#FFB400" : null;
        }

        return "#335de6";
    }
}
