new QWebChannel(qt.webChannelTransport, function(channel) {
    var myObj = channel.objects.qtObject;

    let config = {
        minZoom: 10,
        maxZoom: 18,
    };

    const zoom = 16;
    
    const lat = myObj.latitude;
    const lng = myObj.longitude;

    const map = L.map("map", config);

    // Used to load and display tiles on the map
    // Most tile servers require attribution, which you can set under `Layer`
    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution:
            '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributers',
    }).addTo(map);

    var marker = L.marker();

    marker.setLatLng([lat, lng]);
    marker.addTo(map);
    map.setView([myObj.latitude, myObj.longitude],zoom);
})