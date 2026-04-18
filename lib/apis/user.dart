import 'dart:convert';

import 'package:pos_final/helpers/http_logger.dart';
import 'package:pos_final/api_end_points.dart';

import 'api.dart';

class User extends Api {
  Future<Map> get(var token) async {
    String url = ApiEndPoints.getUser;
    var response = await http.get(Uri.parse(url), headers: getHeader(token));
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load user (${response.statusCode}): ${response.body}',
      );
    }

    final userDetails = jsonDecode(response.body);
    if (userDetails is Map && userDetails['data'] is Map) {
      return Map<String, dynamic>.from(userDetails['data']);
    }
    if (userDetails is Map) {
      return Map<String, dynamic>.from(userDetails.cast<String, dynamic>());
    }
    throw Exception('Unexpected user response format');
  }
}
