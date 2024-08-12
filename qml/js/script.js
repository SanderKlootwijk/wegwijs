var globalMyObj;
var map;
var currentSelectedMarker;
var currentSelectedMarkerIndex;
var poiMarkers = {};

function selectPoiMarker(index, lat, lng) {
    globalMyObj.selectPoiMarker(index);
    
    if (map && globalMyObj) {
        map.setView([lat, lng], 18);
    }

    var currentMarker = document.querySelector('.poi-marker[data-index="' + index + '"]');

    if (currentMarker) {
        // Remove the selected class from the previous marker
        if (currentSelectedMarker) {
            currentSelectedMarker.classList.remove('selected');
            poiMarkers[currentSelectedMarkerIndex].setZIndexOffset(0);
        }
        // Bring the current marker to front
        poiMarkers[index].setZIndexOffset(500);
        // Add the selected class to the current marker
        currentMarker.classList.add('selected');
        currentSelectedMarker = currentMarker;
        currentSelectedMarkerIndex = index;
    }
}

function setMapToCurrentLocation() {
    if (map && globalMyObj) {
        map.setView([globalMyObj.currentLatitude, globalMyObj.currentLongitude], 12);
    }
}

new QWebChannel(qt.webChannelTransport, function(channel) {
    var myObj = channel.objects.qtObject;
    globalMyObj = myObj;

    let config = {
        minZoom: 10,
        maxZoom: 18,
        zoom: 18,
        zoomControl: false
    };

    map = L.map("map", config);

    map.on('zoomend', function() {
        var zoomLevel = map.getZoom();
        updateMarkerStyles(zoomLevel);
    });    
    
    L.control.zoom({
        position: 'bottomright'
    }).addTo(map);

    var poiList = myObj.poiList;

    // Used to load and display tiles on the map
    // Most tile servers require attribution, which you can set under Layer
    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributers',
    }).addTo(map);

    map.createPane("positionMarker");
    map.getPane("positionMarker").style.zIndex = 999;

    var positionMarkerBackground = L.circleMarker([myObj.currentLatitude, myObj.currentLongitude], {radius: 18, color: '#3c8bf7', opacity: 0.3, fillOpacity: 0.3, weight: 0, pane: "positionMarker", interactive: false});
    positionMarkerBackground.addTo(map);
    
    var positionMarker = L.circleMarker();
    positionMarker.setStyle({color: '#ffffff', fillColor: '#3e8cf9', fillOpacity: 1.0, pane: "positionMarker", interactive: false});
    positionMarker.setLatLng([myObj.currentLatitude, myObj.currentLongitude]);
    positionMarker.addTo(map);
    
    function createPoiMarker(index, lat, lng, text, priceLevel) {
        var icon = myObj.fuelType === 4 ? 'chargingstation.svg' : 'fuelstation.svg';
        var kW = myObj.fuelType === 4 ? '&nbsp;kW' : '';
        var poiIndex = index;
        var zoomLevel = map.getZoom();
        var zoomClass = zoomLevel > 13 ? 'zoomed-in' : 'zoomed-out';
        var html = '<div class="poi-marker ' + zoomClass + ' ' + priceLevel + '" data-index="' + poiIndex + '" onclick="selectPoiMarker(' + poiIndex + ', ' + lat + ', ' + lng + ')">' +
                   '<div class="text ' + priceLevel + '">' + text + kW + '</div>' +
                   '<div class="icon"><img src="' + icon + '" width="24" height="24"></div>' +
                   '</div>';
    
        var icon = L.divIcon({
            className: '',
            html: html
        });
    
        return L.marker([lat, lng], { icon: icon });
    }    

    for (var i = 0; i < poiList.length; i++) {
        var index = i;
        var latitude = poiList[i].latitude;
        var longitude = poiList[i].longitude;
        var text = poiList[i].text;
        var priceLevel = poiList[i].priceLevel;

        poiMarkers[index] = createPoiMarker(index, latitude, longitude, text, priceLevel);
        map.addLayer(poiMarkers[index]);
        poiMarkers[index].setZIndexOffset(0);
    }

    selectPoiMarker(globalMyObj.poiIndex, globalMyObj.poiLatitude, globalMyObj.poiLongitude);

    function updateMarkerStyles(zoomLevel) {
        var markers = document.getElementsByClassName('poi-marker');
        for (var i = 0; i < markers.length; i++) {
            if (zoomLevel > 13) {
                markers[i].classList.add('zoomed-in');
                markers[i].classList.remove('zoomed-out');
            } else {
                markers[i].classList.add('zoomed-out');
                markers[i].classList.remove('zoomed-in');
            }
        }
    }    
});