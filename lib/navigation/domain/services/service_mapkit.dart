import 'dart:typed_data';
import 'dart:async';
import 'dart:convert' as JSON;
import 'package:optional/optional.dart';
import 'package:meta/meta.dart';
import 'package:food/commons/http/http.dart';
import 'position_geoloc.dart';
import '../geo/geo.dart';
import 'contract.dart';
import 'navigation.dart';

class _PlaceMapKit implements Place {
  final Map<String, dynamic> json;
  Point _point;
  _PlaceMapKit(this.json);
  String get name => json["name"] as String;

  String get country => json["country"] as String;
  String get url {
    final List<dynamic> urls = json["urls"];
    if (urls != null) {
      return urls.first as String;
    }
    return "";
  }

  String get formattedAddress {
    final List<dynamic> lines = json['formattedAddressLines'];
    if (lines != null) {
      return List.castFrom<dynamic, String>(lines).join(" ");
    }
    return "";
  }

  String get imageUrl => json["placecardUrl"] as String;
  String get phone => json["telephone"];
  Point get coordinate {
    if (_point != null) return _point;
    Map<String, dynamic> center = json["center"];
    _point = Point(center["lat"] as double, center["lng"] as double);
    return _point;
  }
}

class _DirectionStepMapKit extends DirectionStep {
  final Map<String, dynamic> json;
  final String shieldDomain;
  _DirectionStepMapKit _previous;
  _DirectionStepMapKit _nextStep;
  _DirectionStepMapKit(this.json, this.shieldDomain, this._previous) {
    if (_previous != null) {
      _previous._nextStep = this;
    }
  }
  int get distanceMeters => json["distanceMeters"] as int;
  int get durationSeconds => json['durationSeconds'] as int;
  String get instructions => json['instructions'] as String;
  Optional<DirectionStep> get next => Optional.ofNullable(_nextStep);
  Optional<DirectionStep> get previous => Optional.ofNullable(_previous);
  String get imageUrl {
    if (json['maneuver'] != null && json['maneuver']["arrowUrl"] != null) {
      final value = json['maneuver']["arrowUrl"] as String;
      return "https://$shieldDomain$value";
    }
    return "";
  }

  String getImageUrl({String hexColor}) {
    return this
        .imageUrl
        .replaceAll("{{scale}}", "1")
        .replaceAll("&arrowFill=000000", "&arrowFill=$hexColor");
  }

  String get manoeuvreType =>
      json['maneuver'] != null ? json['maneuver']["type"] as String : "";
}

class DirectionMapKit implements Direction {
  final Map<String, dynamic> json;
  final PolyLine polyline;
  final Map<String, dynamic> firstRoute;
  final Map<int, DirectionStep> stepsByIndex;
  final int stepsCount;
  DirectionMapKit._internal({
    @required this.json,
    @required this.polyline,
    @required this.firstRoute,
    @required this.stepsByIndex,
    @required this.stepsCount,
  });

  Map<String, dynamic> toJson() {
    return json;
  }

  static bool isValid(Map<String, dynamic> json) {
    final List<dynamic> routes = json["routes"];
    return (routes != null && routes.length > 0);
  }

  factory DirectionMapKit.fromRoutes(Map<String, dynamic> json) {
    //json values
    final routes = json["routes"] as List<dynamic>; //up to 3 routes
    final firstRoute = routes[0] as Map<String, dynamic>;
    final stepIndexes = firstRoute["stepIndexes"] as List<dynamic>;
    final stepPaths = json["stepPaths"] as List<dynamic>;
    final steps = json["steps"] as List<dynamic>;
    final shieldDomains = json["shieldDomains"] as List<dynamic>;
    //local var
    Map<int, DirectionStep> stepsByIndex = {};
    int stepsCount = stepIndexes.length;
    List<Point> points = [];
    //
    var domainIndex = 0;
    _DirectionStepMapKit previousStep;
    for (var stepIndex in stepIndexes) {
      final stepJson = steps[stepIndex] as Map<String, dynamic>;
      final index = stepJson["stepPathIndex"] as int;
      final pathJson = stepPaths[index] as List<dynamic>;
      final domain =
          shieldDomains[domainIndex % shieldDomains.length] as String;
      final step = _DirectionStepMapKit(stepJson, domain, previousStep);
      previousStep = step;
      for (var path in pathJson) {
        final lat = path['lat'] as num;
        final lng = path['lng'] as num;
        stepsByIndex[points.length] = step;
        points.add(Point(lat, lng));
      }
      domainIndex++;
    }
    final polyline = PolyLine(points);
    return DirectionMapKit._internal(
        firstRoute: firstRoute,
        json: json,
        polyline: polyline,
        stepsByIndex: stepsByIndex,
        stepsCount: stepsCount);
  }
  int get distanceInMeter => firstRoute["distanceMeters"] as int;
  int get travelTimeInSec => firstRoute["durationSeconds"] as int;
  Optional<DirectionStep> stepForIndex({@required int indexOfPoint}) {
    if (stepsByIndex.containsKey(indexOfPoint)) {
      return Optional.ofNullable(stepsByIndex[indexOfPoint]);
    }
    return Optional.empty();
  }
}

//TODO dynamic
class _Configuration {
  final baseUri = "https://api.apple-mapkit.com/v1";
  final maxNbRoutes = 1;
  final String initToken =
      "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ilk4WlFVWUw5N1MifQ.eyJpc3MiOiJIUkZWUzRTWFoyIiwiaWF0IjoxNTI4Mzg1NDI0LCJleHAiOjE1NTkzNDcyMDAsIm9yaWdpbiI6Imh0dHBzOi8vZmlsZXMudm9pcmV0bWFuZ2VyLmZyIn0.m93MzVYgn7XcYaEOcUAmkeXsomm9OyufaKJgiVyP3Vbtw2YR92wSYNSrvR3Zm_MeYDoLPUN06hRAY3ScNYyvwQ";
  final origin = "https://files.voiretmanger.fr";
  final referer = "https://files.voiretmanger.fr/mapkit-macg/";
  final userAgent =
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36";
  final lang = "fr";
  final accessTokenUri =
      "https://cdn.apple-mapkit.com/ma/bootstrap?apiVersion=2&mkjsVersion=5.19.1&poi=1";
  final cdnUrl = "https://cdn1.apple-mapkit.com";
}

class NavigationServiceMapKit extends NavigationService
    with GeolocationListener {
  final HttpRequest httpRequest;
  final HttpRequest httpRequestImage;
  final _Configuration config;
  NavigationServiceMapKit._internal(
      this.httpRequest, this.httpRequestImage, this.config);
  factory NavigationServiceMapKit.init() {
    final config = _Configuration();
    final httpBootstrap = getHttpRequestWithAccessTokenAndRetry(
        logging: false,
        accessToken: () async {
          return AccessToken.fromAccessToken(
              config.initToken, Duration(days: 1).inSeconds);
        },
        defaultHeader: {
          "User-Agent": config.userAgent,
          "Referer": config.referer,
          "Origin": config.origin
        });
    final httpRequest = getHttpRequestWithAccessTokenAndRetry(
        logging: false,
        accessToken: () async {
          final json = await httpBootstrap.getJson(config.accessTokenUri);
          String accessTokenStr = json["authInfo"]["access_token"] as String;
          int expiresIn = json["authInfo"]["expires_in"] as int;
          return AccessToken.fromAccessToken(accessTokenStr, expiresIn);
        },
        defaultHeader: {
          "User-Agent": config.userAgent,
          "Referer": config.referer,
          "Origin": config.origin
        });
    final httpRequestWithoutToken = getHttpRequest(
        logging: true, defaultHeader: {"User-Agent": config.userAgent});
    return NavigationServiceMapKit._internal(
        httpRequest, httpRequestWithoutToken, config);
  }

  Future<List<Place>> searchPlaces(String search) async {
    final json = await httpRequest.getJson("${config.baseUri}/search",
        params: {"q": search, "lang": config.lang});
    final List<dynamic> results = json['results'];
    if (results != null) {
      return results.map((result) => _PlaceMapKit(result)).toList();
    }
    return [];
  }

  Future<Optional<Direction>> fetchDirection(
      {@required Point from,
      @required Point to,
      @required TransportType type}) async {
    final wp = JSON.jsonEncode([
      {
        "loc": {"lat": from.latitude, "lng": from.longitude}
      },
      {
        "loc": {"lat": to.latitude, "lng": to.longitude}
      }
    ]);
    var transport = type == TransportType.Walk ? "WALKING" : "AUTOMOBILE";
    final json =
        await httpRequest.getJson("${config.baseUri}/directions", params: {
      "wps": wp,
      "transport": transport,
      "n": "${config.maxNbRoutes}",
      "lang": config.lang
    });
    if (DirectionMapKit.isValid(json)) {
      return Optional.ofNullable(DirectionMapKit.fromRoutes(json));
    }
    return Optional.empty();
  }

  Future<Uint8List> fetchDirectionImage(DirectionStep step) async {
    String realUrl = step.getImageUrl(hexColor: "ffffff");
    final res = await httpRequestImage.getBytes(realUrl);
    return res;
  }

  Navigation createNavigation() {
    return NavigationImpl(service: this);
  }
}
