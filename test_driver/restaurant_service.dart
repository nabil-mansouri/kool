import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter/material.dart';
import 'package:food/app_test.dart' as app;
import 'package:food/restaurants/domain/services/services.dart';

void main() {
  // This line enables the extension
  enableFlutterDriverExtension();
  // Call the `main()` of your app or call `runApp` with whatever widget
  // you are interested in testing.
  runApp(app.MyApp());
  print("yeah");
  RestaurantServiceFirebase f = RestaurantServiceFirebase();
  print("yo");
}
