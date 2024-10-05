import 'dart:typed_data';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'dart:convert' as JSON;
//export
export 'package:http/http.dart';

abstract class HttpRequest {
  Future<Uint8List> getBytes(String url, {Map<String, String> headers}) async {
    return readBytes(url, headers: headers);
  }

  Future<Response> get(String url,
      {Map<String, String> headers, Map<String, String> params}) {
    return execute(
        _HttpInnerRequest.get(url, headers: headers, params: params));
  }

  Future<Map<String, dynamic>> getJson(String url,
      {Map<String, String> headers, Map<String, String> params}) async {
    final response = await get(url, headers: headers, params: params);
    return JSON.jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getJsonArray(String url,
      {Map<String, String> headers, Map<String, String> params}) async {
    final response = await get(url, headers: headers, params: params);
    final res = JSON.jsonDecode(response.body) as List<dynamic>;
    return List.castFrom<dynamic, Map<String, dynamic>>(res);
  }

  @protected
  Future<Response> execute(_HttpInnerRequest request);
}

enum _InnerRequestMethod { Get, Post, Put, Delete }

class _HttpInnerRequest {
  final String url;
  final Map<String, String> headers;
  final Map<String, String> params;
  final _InnerRequestMethod method;
  final dynamic body;
  _HttpInnerRequest._internal(this.method, this.url,
      {this.headers, this.params, this.body});

  factory _HttpInnerRequest.get(String url,
      {Map<String, String> headers, Map<String, String> params}) {
    return _HttpInnerRequest._internal(_InnerRequestMethod.Get, url,
        headers: headers ?? {}, params: params ?? {}, body: null);
  }
  get fullUri {
    List<String> pars = [];
    for (var key in params.keys) {
      pars.add("$key=${Uri.encodeQueryComponent(params[key])}");
    }
    return "$url?${pars.join("&")}";
  }

  @override
  String toString() {
    return """
    \n#######################################
    HTTP REQUEST $method
    Url: $url
    Headers: $headers
    #######################################\n
    """;
  }
}

abstract class HttpRequestWithChild extends HttpRequest {
  final HttpRequest child;
  HttpRequestWithChild(this.child);
}

class HttpRequestDefault extends HttpRequest {
  Future<Response> execute(_HttpInnerRequest request) {
    switch (request.method) {
      case _InnerRequestMethod.Get:
        return get(request.fullUri, headers: request.headers);
      default:
        return Future.value(null);
    }
  }
}

typedef Future<bool> HttpRequestRetryWhenFunc(Response res);
typedef void HttpRequestRetryFinishedFunc(Response res);

class HttpRequestRetryWhen extends HttpRequestWithChild {
  final HttpRequestRetryWhenFunc retryWhen;
  final HttpRequestRetryFinishedFunc retryFinished;
  final int retryCount;
  HttpRequestRetryWhen(this.retryWhen,
      {@required HttpRequest child, this.retryFinished, this.retryCount = 1})
      : assert(retryCount > 0, "Should at least retry once"),
        super(child);
  Future<Response> execute(request) async {
    Response res;
    var retry = false;
    int i = 0;
    do {
      res = await child.execute(request);
      retry = await retryWhen(res);
      i++;
    } while (retry && i <= retryCount);
    if (retryFinished != null) {
      retryFinished(res);
    }
    return res;
  }
}

class HttpRequestLogger extends HttpRequestWithChild {
  HttpRequestLogger({@required HttpRequest child}) : super(child);
  Future<Response> execute(request) async {
    print("[HttpRequestLogger][before] :");
    print("$request");
    final res = await child.execute(request);
    print(
        "[HttpRequestLogger][after] response: ${res.statusCode} ${res.reasonPhrase}");
    print("#####################################");
    print("${res.body}");
    print("#####################################");
    return res;
  }
}

class HttpRequestDefaultHeader extends HttpRequestWithChild {
  final Map<String, String> headers;
  HttpRequestDefaultHeader(this.headers, {@required HttpRequest child})
      : super(child);
  Future<Response> execute(request) async {
    for (var key in headers.keys) {
      request.headers[key] = headers[key];
    }
    return child.execute(request);
  }
}

typedef Future<AccessToken> HttpRequestUsingAccessTokenFunc();

class AccessToken {
  final String accessToken;
  final int expireInSeconds;
  final DateTime from;
  final DateTime to;
  //
  bool _invalidate = false;
  //30sec
  static get biasMS => biasSec * 1000;
  static final biasSec = 30;
  AccessToken._internal(
      this.accessToken, this.from, this.to, this.expireInSeconds);
  factory AccessToken.fromAccessToken(String accessToken, int expireInSeconds) {
    DateTime from = DateTime.now();
    final ms = 1000 * expireInSeconds - AccessToken.biasMS;
    DateTime to = from.add(Duration(milliseconds: ms));
    return AccessToken._internal(accessToken, from, to, expireInSeconds);
  }
  bool get isValid => !_invalidate && isValidAt(DateTime.now());
  bool get isExpired => _invalidate || isExpiredAt(DateTime.now());
  invalidate() {
    _invalidate = true;
  }

  isValidAt(DateTime time) {
    return time.isBefore(to);
  }

  isExpiredAt(DateTime time) {
    return time.isAfter(to);
  }
}

class HttpRequestUsingAccessToken extends HttpRequestWithChild {
  final HttpRequestUsingAccessTokenFunc accessTokenFunc;
  //
  AccessToken _token;
  HttpRequestUsingAccessToken(this.accessTokenFunc,
      {@required HttpRequest child})
      : super(child);

  _addToken(Map<String, String> headers) {
    headers["Authorization"] = "Bearer ${_token?.accessToken}";
  }

  Future<Response> execute(request) async {
    if (_token?.isValid == true) {
      _addToken(request.headers);
      return child.execute(request);
    } else {
      await refetchAccessToken();
      _addToken(request.headers);
      return child.execute(request);
    }
  }

  resetAccessToken() async {
    _token = null;
  }

  refetchAccessToken() async {
    _token = await accessTokenFunc();
  }
}

HttpRequest getHttpRequestWithAccessTokenAndRetry(
    {@required HttpRequestUsingAccessTokenFunc accessToken,
    Map<String, String> defaultHeader,
    bool logging = false,
    int retryCount = 1,
    HttpRequest mock}) {
  var child4 = mock ?? HttpRequestDefault();
  var child3 = logging == true ? HttpRequestLogger(child: child4) : child4;
  var child2 = defaultHeader != null
      ? HttpRequestDefaultHeader(defaultHeader, child: child3)
      : child3;
  var child1 = HttpRequestUsingAccessToken(accessToken, child: child2);
  return HttpRequestRetryWhen(
      (res) async {
        if (res.statusCode == 401) {
          await child1.refetchAccessToken();
          return true;
        }
        return false;
      },
      child: child1,
      retryCount: retryCount,
      retryFinished: (res) {
        if (res.statusCode == 401) child1.resetAccessToken();
      });
}

HttpRequest getHttpRequest(
    {Map<String, String> defaultHeader,
    bool logging = false,
    HttpRequest mock}) {
  var child4 = mock ?? HttpRequestDefault();
  var child3 = logging == true ? HttpRequestLogger(child: child4) : child4;
  var child2 = defaultHeader != null
      ? HttpRequestDefaultHeader(defaultHeader, child: child3)
      : child3;
  return child2;
}
