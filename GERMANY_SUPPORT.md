# Germany Support for Wegwijs

This fork adds support for German fuel stations using the Tankerkoenig API.

## Features Added

- **German Fuel Station Support**: Automatically detects when the user is in Germany and uses German data sources
- **Tankerkoenig API Integration**: Uses the free Tankerkoenig API to fetch fuel prices for German stations
- **Automatic Country Detection**: Based on GPS coordinates, the app automatically switches between:
  - **Netherlands**: Uses ANWB API (original functionality)
  - **Germany**: Uses Tankerkoenig API
  - **Other countries**: Uses ANWB API (fallback)

## Setup Instructions

### 1. Get a Tankerkoenig API Key

The Tankerkoenig API requires an API key, which can be obtained for free:

1. Go to https://creativecommons.tankerkoenig.de/
2. Register for a free API key
3. Add the API key to the `fetchGermanFuelData` function in `qml/Main.qml`:

```javascript
function fetchGermanFuelData(lat, lon, radius) {
    // Use Tankerkoenig API (free German fuel price API)
    var apiKey = "YOUR_API_KEY_HERE"; // Add your Tankerkoenig API key here
    
    if (!apiKey) {
        console.log("Tankerkoenig API key not set. Please add your API key in Main.qml");
        fuelLoading = false;
        return;
    }
    
    var xhr = new XMLHttpRequest();
    var url = `https://creativecommons.tankerkoenig.de/json/list.php?lat=${lat}&lng=${lon}&rad=${radius}&sort=dist&type=all&apikey=${apiKey}`;
    // ... rest of the function
}
```

### 2. Fuel Type Mapping

The app automatically maps between Wegwijs fuel types and Tankerkoenig fuel types:

- **EURO95** → e5 (Super E5)
- **EURO98** → e10 (Super E10)
- **DIESEL** → diesel
- **AUTOGAS** → lpg (Autogas/LPG)

### 3. Testing

To test the German functionality:

1. Set your location to a German city (e.g., Laichingen, Westerheim, Merklingen)
2. Open the Fuel Prices page
3. The app should automatically fetch data from Tankerkoenig API
4. You should see German fuel stations with current prices

## API Information

### Tankerkoenig API

- **Website**: https://creativecommons.tankerkoenig.de/
- **API Documentation**: https://creativecommons.tankerkoenig.de/api.php
- **Rate Limits**: Free tier allows 1000 requests per day
- **Coverage**: Germany-wide fuel station data

### ANWB API (Netherlands)

- **Website**: https://www.anwb.nl
- **Coverage**: Netherlands-only fuel station data
- **Status**: Still used for Dutch locations

## Future Enhancements

Possible future improvements:

1. **Additional German APIs**: Integrate with other German fuel price APIs like:
   - https://www.benzinpreis-blitz.de (requires API key)
   - https://ich-tanke.de (requires API key)
   
2. **Fallback Mechanism**: If one API fails, try another

3. **Caching**: Cache fuel price data to reduce API calls

4. **More Countries**: Add support for other European countries

## Contributing

If you want to contribute:

1. Fork this repository
2. Make your changes
3. Test thoroughly
4. Submit a pull request to the original repository

## License

This modification maintains the original GPLv3 license of the Wegwijs project.
