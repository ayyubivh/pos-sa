import 'package:http/http.dart' as http_base;
import 'package:flutter/foundation.dart';

class http {
  static Future<http_base.Response> get(Uri url, {Map<String, String>? headers}) async {
    _logRequest('GET', url, headers, null);
    var response = await http_base.get(url, headers: headers);
    _logResponse(response);
    return response;
  }

  static Future<http_base.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    _logRequest('POST', url, headers, body);
    var response = await http_base.post(url, headers: headers, body: body);
    _logResponse(response);
    return response;
  }
  
  static Future<http_base.Response> put(Uri url, {Map<String, String>? headers, Object? body}) async {
    _logRequest('PUT', url, headers, body);
    var response = await http_base.put(url, headers: headers, body: body);
    _logResponse(response);
    return response;
  }
  
  static Future<http_base.Response> delete(Uri url, {Map<String, String>? headers, Object? body}) async {
    _logRequest('DELETE', url, headers, body);
    var response = await http_base.delete(url, headers: headers, body: body);
    _logResponse(response);
    return response;
  }

  static Future<http_base.Response> patch(Uri url, {Map<String, String>? headers, Object? body}) async {
    _logRequest('PATCH', url, headers, body);
    var response = await http_base.patch(url, headers: headers, body: body);
    _logResponse(response);
    return response;
  }

  static void _logRequest(String method, Uri url, Map<String, String>? headers, Object? body) {
    if (kDebugMode) {
      print('*** HTTP LOG REQUEST ***');
      print('--> $method $url');
      if (headers != null) print('Headers: $headers');
      if (body != null) print('Body: $body');
    }
  }

  static void _logResponse(http_base.Response response) {
    if (kDebugMode) {
      print('*** HTTP LOG RESPONSE ***');
      print('<-- ${response.statusCode} ${response.request?.url}');
      if (response.statusCode >= 400 || response.statusCode == 200) {
        // print full body length or content
        String b = response.body;
        if (b.length > 500) {
          print('Body: ${b.substring(0, 500)}... (truncated)');
        } else {
          print('Body: $b');
        }
      }
    }
  }
}
