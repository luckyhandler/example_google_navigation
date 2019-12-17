import 'package:flutter_navigation/disposable.dart';
import 'package:flutter_navigation/entity/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class MarkerProvider extends Disposable {
  static const String KEY_LOCATION = 'Location';
  static const String KEY_DESTINATION = 'Destination';

  final Map<MarkerId, Marker> _markers = {};

  BehaviorSubject<Map<MarkerId, Marker>> _markerSubject =
      BehaviorSubject<Map<MarkerId, Marker>>();

  Map<MarkerId, Marker> get markers => _markers;

  Marker get currentLocationMarker => _markers[KEY_LOCATION];

  Marker get currentDestinationMarker => _markers[KEY_DESTINATION];

  Stream<Map<MarkerId, Marker>> get markerStream => _markerSubject.stream;

  /// Adds a marker for the current location to the markers map
  Location createLocationMarker(Location location) {
    final MarkerId markerId = MarkerId(KEY_LOCATION);
    final Marker marker = Marker(
      markerId: markerId,
      position: location.toLatLon(),
      infoWindow: InfoWindow(
        title: 'Location',
        snippet: 'Your Current Location',
      ),
    );
    _markers[markerId] = marker;
    _markerSubject.sink.add(_markers);
    return location;
  }

  /// Adds a marker for the current location to the markers map
  void createDestinationMarker(double latitude, double longitude) {
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
    _markerSubject.sink.add(_markers);
  }

  @override
  void dispose() {
    _markerSubject.close();
  }

  @override
  void init() {
    _markerSubject = BehaviorSubject<Map<MarkerId, Marker>>();
  }
}
