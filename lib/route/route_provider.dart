import 'package:flutter_navigation/disposable.dart';
import 'package:flutter_navigation/entity/location.dart' as local;
import 'package:flutter_navigation/entity/polyline_definition.dart';
import 'package:flutter_navigation/entity/route_data.dart';
import 'package:flutter_navigation/keys.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as ws;
import 'package:rxdart/rxdart.dart';

class RouteProvider extends Disposable {
  RouteData _routeData;
  BehaviorSubject<RouteData> _routeDataSubject = BehaviorSubject<RouteData>();

  Stream<RouteData> get routeStream => _routeDataSubject.stream;

  RouteData get routeData => _routeData;

  /// Adds a polyline to the google map
  Future<void> setPolyline(PolylineDefinition polylineDefinition,
      {LocalRouteMode routeMode = LocalRouteMode.driving}) async {
    final ws.GoogleMapsDirections directions =
        ws.GoogleMapsDirections(apiKey: Keys.GOOGLE_API_KEY);

    ws.TravelMode travelMode = routeMode.toTravelMode();
    final ws.DirectionsResponse response =
        await directions.directionsWithLocation(
            ws.Location(polylineDefinition.location.latitude,
                polylineDefinition.location.longitude),
            ws.Location(polylineDefinition.destination.latitude,
                polylineDefinition.destination.longitude),
            travelMode: travelMode,
            trafficModel: ws.TrafficModel.bestGuess,
            departureTime: DateTime.now(),
            language: "de");

    final List<ws.Step> steps = response.routes[0].legs[0].steps;
    final String durationText = response.routes[0].legs[0].duration.text;
    final num durationValue = response.routes[0].legs[0].duration.value;
    final String distanceText = response.routes[0].legs[0].distance.text;
    final num distanceValue = response.routes[0].legs[0].distance.value;
    final String durationInTrafficText =
        response.routes[0].legs[0].durationInTraffic.text;
    final num durationInTrafficValue =
        response.routes[0].legs[0].durationInTraffic.value;
    final String summary = response.routes[0].summary;
    final ws.Bounds bounds = response.routes[0].bounds;
    final List<LatLng> wayPoints = List<LatLng>();

    steps.forEach((ws.Step step) {
      final ws.Polyline polyline = step.polyline;
      final String points = polyline.points;

      final List<LatLng> singlePolyLine = _decodePolyLine(points);
      singlePolyLine.forEach(wayPoints.add);
    });

    final PolylineId polyId = PolylineId('polyline');
    Polyline polyline = Polyline(
      polylineId: polyId,
      points: wayPoints,
      color: polylineDefinition.color,
      width: 5,
    );

    LatLngBounds latLngBounds = LatLngBounds(
        northeast: local.Location(
                longitude: bounds.northeast.lng, latitude: bounds.northeast.lat)
            .toLatLon(),
        southwest: local.Location(
                longitude: bounds.southwest.lng, latitude: bounds.southwest.lat)
            .toLatLon());

    _routeData = RouteData(
        polyline,
        latLngBounds,
        durationText,
        durationValue,
        distanceText,
        distanceValue,
        durationInTrafficText,
        durationInTrafficValue,
        summary);

    _routeDataSubject.sink.add(_routeData);
  }

  List<LatLng> _decodePolyLine(String encoded) {
    // credits go to FabianVarela
    // (https://github.com/FabianVarela/flutter_maps_bloc/blob/master/lib/ui/map_screen.dart)
    final List<LatLng> wayPoints = List<LatLng>();
    final int length = encoded.length;

    int index = 0;
    int latitude = 0;
    int longitude = 0;

    while (index < length) {
      int bit;
      int shift = 0;
      int result = 0;

      do {
        bit = encoded.codeUnitAt(index++) - 63;
        result |= (bit & 0x1f) << shift;
        shift += 5;
      } while (bit >= 0x20);

      final int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      latitude += dLat;
      shift = 0;
      result = 0;

      do {
        bit = encoded.codeUnitAt(index++) - 63;
        result |= (bit & 0x1f) << shift;
        shift += 5;
      } while (bit >= 0x20);

      final int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      longitude += dLng;

      final LatLng wayPoint =
          LatLng(latitude.toDouble() / 1E5, longitude.toDouble() / 1E5);
      wayPoints.add(wayPoint);
    }

    return wayPoints;
  }

  @override
  void dispose() {
    _routeDataSubject.close();
  }

  @override
  void init() {
    _routeDataSubject = BehaviorSubject<RouteData>();
  }
}

extension RouteModeTravelMode on LocalRouteMode {
  ws.TravelMode toTravelMode() {
    ws.TravelMode travelMode = ws.TravelMode.driving;
    switch (this) {
      case LocalRouteMode.driving:
        travelMode = ws.TravelMode.driving;
        break;
      case LocalRouteMode.walking:
        travelMode = ws.TravelMode.walking;
        break;
      case LocalRouteMode.bicycling:
        travelMode = ws.TravelMode.bicycling;
        break;
    }
    return travelMode;
  }
}
