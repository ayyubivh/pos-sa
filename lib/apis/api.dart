import 'dart:convert' as convert;

import 'package:flutter/foundation.dart';
import 'package:pos_final/helpers/http_logger.dart';
import 'package:pos_final/api_end_points.dart';

import '../config.dart';

class Api {
  String baseUrl = Config.baseUrl,
      apiUrl = ApiEndPoints.apiUrl,
      clientId = Config().clientId,
      clientSecret = Config().clientSecret;

  //validate the login details
  Future<Map?> login(String username, String password) async {
    String url = ApiEndPoints.loginUrl;

    Map body = {
      'grant_type': 'password',
      'client_id': clientId,
      'client_secret': clientSecret,
      'username': username,
      'password': password,
    };
    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );
    Map<String, dynamic> jsonResponse = {};
    try {
      final decoded = convert.jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        jsonResponse = decoded;
      }
    } catch (_) {}

    if (kDebugMode) {
      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');
    }
    if (response.statusCode == 200) {
      //logged in successfully
      return {'success': true, 'access_token': jsonResponse['access_token']};
    } else if (response.statusCode == 401 ||
        (response.statusCode == 400 &&
            jsonResponse['error'] == 'invalid_grant')) {
      return {
        'success': false,
        'error': jsonResponse['error'],
        'message_key': 'invalid_credentials',
        'message': jsonResponse['message'] ?? jsonResponse['error_description'],
      };
    } else {
      return {
        'success': false,
        'error': jsonResponse['error'] ?? 'login_failed',
        'message_key': 'something_went_wrong',
        'message': jsonResponse['message'] ?? jsonResponse['error_description'],
      };
    }
  }

  Map<String, String> getHeader(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
