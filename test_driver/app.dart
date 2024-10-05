import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter/material.dart';
import 'package:food/app_test.dart' as app;

void main() {
  // This line enables the extension
  enableFlutterDriverExtension();

  // Call the `main()` function of your app or call `runApp` with any widget you
  // are interested in testing.
  runApp(app.MyApp());
}
