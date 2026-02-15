import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:pos_final/api_end_points.dart';
import 'package:pos_final/helpers/api_handler/api_helper.dart';

import '../apis/api.dart';
import '../models/system.dart';

class AttendanceApi extends Api {
  // ------------------ MOCK ATTENDANCE IMPLEMENTATION ------------------
  //check-In/Out through api
  Future<Map<String, dynamic>?> checkIO(data, bool check) async {
    // try {
    //   String url = (check) ? ApiEndPoints.checkIn : ApiEndPoints.checkOut;
    //   var token = await System().getToken();
    //   var response = await http.post(Uri.parse(url),
    //       headers: this.getHeader('$token'), body: jsonEncode(data));
    //   var info = jsonDecode(response.body);
    //   return info;
    // } catch (e) {
    //   return null;
    // }

    await Future.delayed(Duration(seconds: 1));
    return {
      'success': true,
      'msg': check ? 'Checked in successfully' : 'Checked out successfully',
      'data': {
        'id': 123,
        // Echo back data or provide dummy data
      },
    };
  }

  //get user attendance
  Future<Map<String, Object?>> getAttendanceDetails(int userId) async {
    // try {
    //   String url = '${ApiEndPoints.getAttendance}$userId';
    //   var token = await System().getToken();
    //   var response =
    //       await http.get(Uri.parse(url), headers: this.getHeader('$token'));
    //   var info = jsonDecode(response.body);
    //   var result = info['data'];
    //   return result;
    // } catch (e) {
    //   return null;
    // }

    await Future.delayed(Duration(milliseconds: 500));
    // Mocking an active attendance session (checked in, not checked out)
    return {
      'id': 101,
      'user_id': userId,
      'clock_in_time': '2023-10-27 09:00:00',
      'clock_out_time': null,
      'clock_in_note': 'Mock check-in',
      'clock_out_note': null,
      'ip_address': '127.0.0.1',
      'latitude': '0.0',
      'longitude': '0.0',
    };
  }

  // -----------------------------------------------------------------
}
