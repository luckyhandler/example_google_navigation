import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_navigation/entity/location.dart';

class PolylineDefinition {
  final Location location;
  final Location destination;
  final LocalRouteMode routeMode;
  final Color color;

  PolylineDefinition(
      {this.location,
      this.destination,
      this.routeMode = LocalRouteMode.driving,
      this.color = Colors.blueAccent});
}

enum LocalRouteMode {
  driving,
  walking,
  bicycling,
}
