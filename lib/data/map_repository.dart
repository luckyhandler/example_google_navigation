import 'package:flutter_navigation/data/disposable.dart';
import 'package:flutter_navigation/entity/location.dart';
import 'package:flutter_navigation/entity/polyline_definition.dart';
import 'package:flutter_navigation/entity/ride_details.dart';
import 'package:flutter_navigation/entity/route_data.dart';
import 'package:flutter_navigation/data/marker_provider.dart';
import 'package:flutter_navigation/data/route_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteRepository extends Disposable {
  static final RouteRepository instance = RouteRepository._internal();

  factory RouteRepository() {
    return instance;
  }

  RouteRepository._internal();

  Location _location;
  Location _destination;
  RouteData _routeData;
  RideDetails _rideDetails;

  final LocationOptions locationOptions =
      LocationOptions(accuracy: LocationAccuracy.high);

  final RouteProvider _routeProvider = RouteProvider();
  final MarkerProvider _markerProvider = MarkerProvider();
  final Geolocator _locationProvider = Geolocator();

  Location get location => _location;

  Location get destination => _destination;

  RouteData get routeData => _routeData;

  RideDetails get rideDetails => _rideDetails;

  // While retrieving location updates keep marker stream up-to-date
  Stream<Location> get locationStream => _locationProvider
      .getPositionStream(locationOptions)
      .map((position) => position.toLocation())
      .map((location) => _location = location);

  Stream<Map<MarkerId, Marker>> get markersStream =>
      _markerProvider.markerStream;

  Stream<RouteData> get routeStream =>
      _routeProvider.routeStream.map((routeData) => _routeData = routeData);

  @override
  void init() {
    _routeProvider.init();
    _markerProvider.init();
  }

  @override
  void dispose() {
    _routeProvider.dispose();
    _markerProvider.dispose();
  }

  Future<bool> addDestination(String destinationString,
      {routeMode = LocalRouteMode.driving}) async {
    final List<Placemark> placemarks =
        await _locationProvider.placemarkFromAddress(destinationString);

    if (placemarks.isNotEmpty) {
      _destination = placemarks[0].toLocation();
    } else {
      return false;
    }

    _markerProvider.createDestinationMarker(
        _destination.latitude, _destination.longitude);
    await _routeProvider.setPolyline(
        PolylineDefinition(
            location: _location,
            destination: _destination,
            routeMode: routeMode),
        routeMode: routeMode);

    return true;
  }

  Future<Location> getFullLocation() async {
    final List<Placemark> placemarks = await _locationProvider
        .placemarkFromCoordinates(_location.latitude, _location.longitude);

    if (placemarks.isNotEmpty) {
      Location fullLocation = placemarks[0].toLocation();
      fullLocation.timestamp = _location.timestamp;
      return fullLocation;
    } else {
      return null;
    }
  }

  void addRideDetails(RideDetails rideDetails) {
    _rideDetails = rideDetails;
  }
}

extension LocationPosition on Location {
  Position toPosition() {
    return this == null
        ? null
        : Position(
            latitude: this.latitude,
            longitude: this.longitude,
            timestamp: this.timestamp);
  }
}

extension PositionLocation on Position {
  Location toLocation() {
    return this == null
        ? null
        : Location(
            latitude: this.latitude,
            longitude: this.longitude,
            timestamp: this.timestamp);
  }
}

extension PlacemarkLocation on Placemark {
  Location toLocation() {
    return this == null
        ? null
        : Location(
            latitude: this.position.latitude,
            longitude: this.position.longitude,
            timestamp: this.position.timestamp,
            country: this.country,
            isoCountryCode: this.isoCountryCode,
            locality: this.locality,
            name: this.name,
            postalCode: this.postalCode);
  }
}
