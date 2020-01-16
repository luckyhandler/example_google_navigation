import 'package:google_maps_flutter/google_maps_flutter.dart';

class Location {
  final double latitude;
  final double longitude;
  final String country;
  final String locality;
  final String postalCode;
  final String name;
  final String isoCountryCode;
  // can't be final as google web service's
  // placemarkFromCoordinates doesn't return date
  DateTime timestamp;

  Location({
    this.longitude,
    this.latitude,
    this.timestamp,
    this.country,
    this.locality,
    this.postalCode,
    this.name,
    this.isoCountryCode,
  });
}

extension LocationMapper on Location {
  CameraPosition toCameraNearPosition() {
    return this == null
        ? null
        : CameraPosition(
            target: LatLng(this.latitude, this.longitude), zoom: 11.0);
  }

  CameraPosition toCameraFarPosition() {
    return this == null
        ? null
        : CameraPosition(
            target: LatLng(this.latitude, this.longitude), zoom: 14.0);
  }

  LatLng toLatLon() {
    return this == null ? null : LatLng(this.latitude, this.longitude);
  }
}
