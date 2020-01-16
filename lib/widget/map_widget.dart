import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_navigation/entity/location.dart';
import 'package:flutter_navigation/entity/route_data.dart';
import 'package:flutter_navigation/data/map_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MapState();
  }
}

class MapState extends State {
  final RouteRepository _repository = RouteRepository.instance;
  final Completer<GoogleMapController> _completer = Completer();

  Set<Marker> _markers;
  RouteData _routeData;
  Location _location;
  bool _moveToLocation = true;

  StreamSubscription<Map<MarkerId, Marker>> _markerSubscription;
  StreamSubscription<Location> _locationSubscription;
  StreamSubscription<RouteData> _routeSubscription;

  @override
  void initState() {
    super.initState();

    _location = _getBestMapPosition();
    _routeData = _repository.routeData;
  }

  @override
  void dispose() {
    super.dispose();
    _routeSubscription.cancel();
    _markerSubscription.cancel();
    _locationSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
            padding: EdgeInsets.only(top: 124),
            scrollGesturesEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: _location.toCameraNearPosition(),
            onMapCreated: (controller) => _onMapCreated(controller),
            onCameraMoveStarted: () => setState(() {
                  _moveToLocation = false;
                }),
            cameraTargetBounds: _routeData == null || _routeData.bounds == null
                ? null
                : CameraTargetBounds(_routeData.bounds),
            myLocationEnabled: true,
            buildingsEnabled: true,
            polylines: _routeData == null || _routeData.polyline == null
                ? {}
                : [_routeData.polyline].toSet(),
            markers: _markers),
        Positioned(
          top: 60,
          left: MediaQuery.of(context).size.width * 0.05,
          right: MediaQuery.of(context).size.width * 0.05,
          child: Container(
            decoration: BoxDecoration(border: Border.all()),
            child: TextField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  hintText: "destination"),
              onSubmitted: (destinationText) async {
                await _repository.addDestination(destinationText);
                _moveToLocation = true;
              },
            ),
          ),
        ),
      ],
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _completer.complete(controller);
    // Keep markers up-to-date
    _markerSubscription = _repository.markersStream.listen((markerMap) {
      setState(() {
        _markers = Set.from(markerMap.values);
      });
    });

    // Keep route data up-to-date
    _routeSubscription = _repository.routeStream
        .map((routeData) => routeData)
        .listen((routeData) {
      setState(() {
        if (routeData != null && routeData.polyline != null) {
          _routeData = routeData;
        }
      });
    });

    // Keep location up-to-date
    _locationSubscription =
        _repository.locationStream.listen((Location location) {
          print('${location.latitude}, ${location.longitude}');

          setState(() {
            _location = _getBestMapPosition();
          });

          if (_moveToLocation) {
            controller.animateCamera(
                CameraUpdate.newCameraPosition((_location.toCameraFarPosition())));
          }
        });
  }

  Location _getBestMapPosition() {
    if (_repository.destination != null) {
      return _repository.destination;
    } else if (_repository.location != null) {
      return _repository.location;
    } else {
      return Location(
          longitude: 11.00783, latitude: 49.59099, timestamp: DateTime.now());
    }
  }
}
