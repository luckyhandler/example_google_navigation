import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class RouteData {
  Polyline polyline;
  LatLngBounds bounds;
  String durationText;
  num durationValue;
  String distanceText;
  num distanceValue;
  String durationInTrafficText;
  num durationInTrafficValue;
  String summary;
  String arrivalTime;

  RouteData(
      this.polyline,
      this.bounds,
      this.durationText,
      this.durationValue,
      this.distanceText,
      this.distanceValue,
      this.durationInTrafficText,
      this.durationInTrafficValue,
      this.summary) {
    DateTime arrival =
        DateTime.now().add(Duration(seconds: durationInTrafficValue.round()));
    initializeDateFormatting('de_DE', null).then((_) => _formatDate(arrival));
  }

  Future<void> _formatDate(DateTime arrival) async {
    DateFormat formatter = new DateFormat.Hm('de');
    arrivalTime = formatter.format(arrival);
  }
}
