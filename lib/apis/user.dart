import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pos_final/api_end_points.dart';

import 'api.dart';

class User extends Api {
  Future<Map> get(var token) async {
    // ------------------ MOCK USER GET IMPLEMENTATION ------------------
    // String url = ApiEndPoints.getUser;
    // var response =
    //     await http.get(Uri.parse(url), headers: this.getHeader(token));
    // var userDetails = jsonDecode(response.body);
    // Map userDetailsMap = userDetails['data'];
    // return userDetailsMap;

    await Future.delayed(Duration(milliseconds: 500));
    return {
      'id': 1,
      'first_name': 'Demo',
      'last_name': 'User',
      'username': 'demouser',
      'email': 'demo@example.com',
    };
    // -----------------------------------------------------------------
  }
}
