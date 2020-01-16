import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerRepository {
  static const String KEY_LOCATION = 'Location';
  static const String KEY_DESTINATION = 'Destination';

  final Map<MarkerId, Marker> _markers = {};

  Map<MarkerId, Marker> get markers => _markers;

  Marker get currentLocationMarker => _markers[KEY_LOCATION];

  Marker get currentDestinationMarker => _markers[KEY_DESTINATION];

  /// Adds a marker for the current location to the markers map
  Marker createLocationMarker(double latitude, double longitude) {
    final MarkerId markerId = MarkerId(KEY_LOCATION);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: 'Location',
        snippet: 'Your Current Location',
      ),
    );
    _markers[markerId] = marker;
    return marker;
  }

  /// Adds a marker for the current location to the markers map
  Marker createDestinationMarker(double latitude, double longitude) {
    final MarkerId markerId = MarkerId(KEY_DESTINATION);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: 'Destination',
        snippet: 'Your Destination',
      ),
    );

    _markers[markerId] = marker;
    return marker;
  }
}
