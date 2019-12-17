import 'package:flutter/material.dart';
import 'package:flutter_navigation/widget/map_widget.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Google Maps Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(body: MapWidget()));
  }
}
