import 'dart:convert';

import 'package:pos_final/helpers/http_logger.dart';

import '../models/system.dart';
import 'api.dart';

class FieldForceApi extends Api {
  //add new visit
  Future<int> create(Map visitDetails) async {
    try {
      String url = baseUrl + apiUrl + "/field-force/create";
      var body = json.encode(visitDetails);
      var token = await System().getToken();
      var response = await http.post(
        Uri.parse(url),
        headers: getHeader(token),
        body: body,
      );
      return response.statusCode;
    } catch (e) {}
  }

  //update visit status
  Future<int?>? update(Map visitDetails, id) async {
    try {
      String url = baseUrl + apiUrl + "/field-force/update-visit-status/$id";
      var body = json.encode(visitDetails);
      var token = await System().getToken();
      var response = await http.post(
        Uri.parse(url),
        headers: getHeader(token),
        body: body,
      );
      return response.statusCode;
    } catch (e) {
      return null;
    }
  }
}
