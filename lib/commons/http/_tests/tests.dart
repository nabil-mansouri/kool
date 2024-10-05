import 'dart:convert' as JSON;
import 'package:flutter_test/flutter_test.dart';
import '../http.dart';

class _HttpMock extends HttpRequest {
  List<Response> responses = [];
  String lastUri;
  Map<String, String> lastHeaders = {};
  Future<Response> execute(request) async {
    lastHeaders = request.headers;
    lastUri = request.fullUri;
    return responses.removeAt(0);
  }
}

AccessToken _token;
int nbCreation = 0;
Future<AccessToken> _cbAccessToken() async {
  nbCreation++;
  return _token;
}

unitTestHttp() {
  final mock = _HttpMock();
  final http = getHttpRequestWithAccessTokenAndRetry(
      accessToken: _cbAccessToken,
      mock: mock,
      retryCount: 2,
      defaultHeader: {"Origin": "yes"},
      logging: false);
  group("[Http]", () {
    test('should create access token successfully', () async {
      nbCreation = 0;
      mock.responses = [Response("", 200)];
      _token = AccessToken.fromAccessToken("accessToken", 100);
      final res = await http.get("success");
      expect(res.statusCode, equals(200));
      expect(nbCreation, equals(1));
    });
    test('should reuse access token successfully', () async {
      nbCreation = 0;
      mock.responses = [Response("", 200)];
      final res = await http.get("success");
      expect(res.statusCode, equals(200));
      expect(nbCreation, equals(0));
    });
    test('should reuse anew access token successfully', () async {
      nbCreation = 0;
      mock.responses = [Response("", 200)];
      final res = await http.get("success");
      expect(res.statusCode, equals(200));
      expect(nbCreation, equals(0));
    });
    test('should have right headers', () async {
      nbCreation = 0;
      mock.responses = [Response("", 200)];
      final res = await http.get("success");
      expect(res.statusCode, equals(200));
      expect(nbCreation, equals(0));
      expect("yes", equals(mock.lastHeaders["Origin"]));
      expect("Bearer accessToken", equals(mock.lastHeaders["Authorization"]));
    });
    test('should  encode uri params', () async {
      nbCreation = 0;
      final wp = JSON.jsonEncode([
        {
          "loc": {"lat": 46.8, "lng": 4.4333}
        },
        {
          "loc": {"lat": 46.6667, "lng": 4.3667}
        }
      ]);
      mock.responses = [Response("", 200)];
      final res = await http.get("https://api.apple-mapkit.com/v1/directions",
          params: {
            "wps": wp,
            "transport": "AUTOMOBILE",
            "n": "3",
            "lang": "fr"
          });
      expect(res.statusCode, equals(200));
      expect(nbCreation, equals(0));
      expect(
          mock.lastUri,
          equals(
              "https://api.apple-mapkit.com/v1/directions?wps=%5B%7B%22loc%22%3A%7B%22lat%22%3A46.8%2C%22lng%22%3A4.4333%7D%7D%2C%7B%22loc%22%3A%7B%22lat%22%3A46.6667%2C%22lng%22%3A4.3667%7D%7D%5D&transport=AUTOMOBILE&n=3&lang=fr"));
    });
    test('should parse json', () async {
      nbCreation = 0;
      final wp = {
        "loc": {"lat": 46.8, "lng": 4.4333}
      };
      mock.responses = [Response("${JSON.jsonEncode(wp)}", 200)];
      final res = await http.getJson("https://apiirections");
      expect(res["loc"]["lat"], equals(wp["loc"]["lat"]));
      expect(res["loc"]["lng"], equals(wp["loc"]["lng"]));
      expect(nbCreation, equals(0));
    });
    test('should parse json array', () async {
      nbCreation = 0;
      final wp = [
        {
          "loc": {"lat": 46.8, "lng": 4.4333}
        }
      ];
      mock.responses = [Response("${JSON.jsonEncode(wp)}", 200)];
      final res = await http.getJsonArray("https://ns");
      expect(res[0]["loc"]["lat"], equals(wp[0]["loc"]["lat"]));
      expect(res[0]["loc"]["lng"], equals(wp[0]["loc"]["lng"]));
      expect(nbCreation, equals(0));
    });
    test('should recreate access token successfully on 401', () async {
      nbCreation = 0;
      mock.responses = [Response("", 401), Response("", 200)];
      final res = await http.get("success");
      expect(res.statusCode, equals(200));
      expect(nbCreation, equals(1));
    });
    test('should recreate access token at most twice successfully on 401',
        () async {
      nbCreation = 0;
      mock.responses = [
        Response("", 401),
        Response("", 401),
        Response("", 200)
      ];
      final res = await http.get("success");
      expect(res.statusCode, equals(200));
      expect(nbCreation, equals(2));
    });
    test('should not recreate access token more than twice on 401', () async {
      nbCreation = 0;
      mock.responses = [
        Response("", 401),
        Response("", 401),
        Response("", 401),
        Response("", 401)
      ];
      final res = await http.get("success");
      expect(res.statusCode, equals(401));
      expect(nbCreation, equals(3));
    });
    test('should recreate access token after fail', () async {
      nbCreation = 0;
      mock.responses = [Response("", 200)];
      final res = await http.get("success");
      expect(res.statusCode, equals(200));
      expect(nbCreation, equals(1));
    });
    test('should refetch using same token', () async {
      nbCreation = 0;
      mock.responses = [Response("", 200)];
      final res = await http.get("success");
      expect(res.statusCode, equals(200));
      expect(nbCreation, equals(0));
    });
    test('should token be expired and recreate', () async {
      nbCreation = 0;
      _token.invalidate();
      mock.responses = [Response("", 200)];
      final res = await http.get("success");
      expect(res.statusCode, equals(200));
      expect(nbCreation, equals(1));
    });
    test('should access token be valid', () async {
      final token = AccessToken.fromAccessToken("accessToken", 100);
      //now
      expect(token.isValid, isTrue);
      expect(token.isExpired, isFalse);
      //before date
      final beforeDate =
          DateTime.now().add(Duration(seconds: 100 - AccessToken.biasSec - 5));
      expect(token.isValidAt(beforeDate), isTrue);
      expect(token.isExpiredAt(beforeDate), isFalse);
      //after date
      final afterDate =
          DateTime.now().add(Duration(seconds: 100 - AccessToken.biasSec + 5));
      expect(token.isValidAt(afterDate), isFalse);
      expect(token.isExpiredAt(afterDate), isTrue);
      //invalidate
      token.invalidate();
      expect(token.isValid, isFalse);
      expect(token.isExpired, isTrue);
    });
  });
}
