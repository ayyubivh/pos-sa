import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:pos_final/api_end_points.dart';

import '../config.dart';

class Api {
  String baseUrl = Config.baseUrl,
      apiUrl = ApiEndPoints.apiUrl,
      clientId = Config().clientId,
      clientSecret = Config().clientSecret;

  //validate the login details
  Future<Map?> login(String username, String password) async {
    // ------------------ MOCK LOGIN IMPLEMENTATION ------------------
    // try {
    //   String url = ApiEndPoints.loginUrl;
    //
    //   Map body = {
    //     'grant_type': 'password',
    //     'client_id': clientId,
    //     'client_secret': clientSecret,
    //     'username': username,
    //     'password': password,
    //   };
    //
    //   var response = await http.post(
    //     Uri.parse(url),
    //     headers: {
    //       'Accept': 'application/json',
    //       'Content-Type': 'application/x-www-form-urlencoded',
    //     },
    //     body: body,
    //   );
    //
    //   print('Response status: ${response.statusCode}');
    //   print('Response body: ${response.body}');
    //
    //   // Check if response body is not empty before parsing
    //   if (response.body.isEmpty) {
    //     print('Empty response body');
    //     return {'success': false, 'error': 'Empty response from server'};
    //   }
    //
    //   var jsonResponse = convert.jsonDecode(response.body);
    //   print('Parsed JSON: $jsonResponse');
    //
    //   if (response.statusCode == 200) {
    //     //logged in successfully
    //     if (jsonResponse['access_token'] != null) {
    //       return {
    //         'success': true,
    //         'access_token': jsonResponse['access_token'],
    //       };
    //     } else {
    //       return {'success': false, 'error': 'No access token received'};
    //     }
    //   } else if (response.statusCode == 401) {
    //     //Invalid credentials
    //     return {
    //       'success': false,
    //       'error': jsonResponse['error'] ?? 'Invalid credentials',
    //     };
    //   } else {
    //     // Handle other status codes
    //     return {
    //       'success': false,
    //       'error':
    //           jsonResponse['error'] ??
    //           jsonResponse['message'] ??
    //           'Server error: ${response.statusCode}',
    //     };
    //   }
    // } catch (e) {
    //   print('Login error: $e');
    //   return {'success': false, 'error': 'Connection error: $e'};
    // }

    // Return mock success for any login attempt
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return {'success': true, 'access_token': 'mock_access_token_12345'};
    // -----------------------------------------------------------------
  }

  Map<String, String> getHeader(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
