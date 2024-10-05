import 'package:rxdart/rxdart.dart';
import 'dart:convert' as JSON;

class NavigationDump {
  final double latitude;
  final double longitude;
  //camera
  final double cameraLatitude;
  final double cameraLongitude;
  final double bearing;
  final double tilt;
  final double zoom;
  NavigationDump(
      {this.bearing,
      this.cameraLatitude,
      this.cameraLongitude,
      this.latitude,
      this.longitude,
      this.tilt,
      this.zoom});
  factory NavigationDump.fromJson(dynamic json) {
    return NavigationDump(
      bearing: json["bearing"] as double,
      cameraLatitude: json["cameraLatitude"] as double,
      cameraLongitude: json["cameraLongitude"] as double,
      latitude: json["latitude"] as double,
      longitude: json["longitude"] as double,
      tilt: json["tilt"] as double,
      zoom: json["zoom"] as double,
    );
  }
  toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
      "cameraLatitude": cameraLatitude,
      "cameraLongitude": cameraLongitude,
      "bearing": bearing,
      "tilt": tilt,
      "zoom": zoom
    };
  }

  toString() {
    return "latitude=$latitude, longitude= $longitude, cameraLatitude=$cameraLatitude, cameraLongitude=$cameraLongitude, bearing=$bearing, tilt=$tilt, zoom=$zoom";
  }
}

class NavigationDumpGenerator {
  final List<NavigationDump> json;
  final int hertz;
  NavigationDumpGenerator(this.json, {this.hertz = 10});
  factory NavigationDumpGenerator.fromJson(String jsonStr, {int hertz}) {
    final json = JSON.jsonDecode(jsonStr) as List<dynamic>;
    return NavigationDumpGenerator(
        json.map((f) => NavigationDump.fromJson(f)).toList(),
        hertz: hertz);
  }
  Observable<NavigationDump> createObservable() {
    return Observable.periodic(Duration(milliseconds: (1000 / hertz).round()),
        (index) {
      return index < json.length ? json[index] : null;
    }).takeWhile((json) => json != null);
  }
}
