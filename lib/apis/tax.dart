import 'dart:convert';

import 'package:pos_final/helpers/http_logger.dart';

import '../models/system.dart';
import 'api.dart';

class Tax extends Api {
  var taxes;

  Future<List> get() async {
    try {
      String url = baseUrl + apiUrl + "/tax";
      var token = await System().getToken();
      var response = await http.get(Uri.parse(url), headers: getHeader(token));
      taxes = jsonDecode(response.body);
      var taxList = taxes['data'];
      System().insert('tax', jsonEncode(taxList));
      return taxList;
    } catch (e) {
      return [];
    }
  }
}
