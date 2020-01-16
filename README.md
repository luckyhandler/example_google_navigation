# flutter_navigation
Prototype for google maps / geolocation / geocoding in Flutter.

This prototype includes
- Tracking of geolocation (using geolocator)
- Display of Google Maps (using google_maps_flutter)
- Geocoding from String to Location (using google_maps_webservice)
- Display Polyline from current location to geocoded destination (using google_maps_webservice)

How to setup the project to try it out:
- Go [here](https://developers.google.com/maps/gmp-get-started) and get your Google Maps API key.
- Activate [here](https://console.cloud.google.com/google/maps-apis/api-list) Geocoding, Directions & Places API
- Create a keys.dart file in the root of your `lib` folder.
It should look like this 

```dart
class Keys {
  static const String GOOGLE_API_KEY = "Enter your key here";
}
```

- Add a keys.xml to your Android project at `app > src > main > res > values` which looks like this:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="GoogleMapsKey">Enter your key here</string>
</resources>
```  

- Go to the ios project and add the key into `Runner > AppDelegate`:
```swift
GMSServices.provideAPIKey("Enter your key here")
``` 
- And if you know how to extract the api key from iOS create a ticket or a PR. :-) 

And now, happy coding! 
Star and share this project if you like.