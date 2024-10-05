import 'package:flutter/material.dart';
import 'package:food/restaurants/_tests/tests.dart';
import 'package:food/location/_tests/tests.dart';

void main() {
  runApp(MaterialApp(
    home: Material(
      child: Center(
        child: Text("Running tests..."),
      ),
    ),
  ));
  //hot restart avec "R"
  testRestaurants();
  testLocations();
}
