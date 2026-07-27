import 'dart:convert';

import 'package:pos_final/helpers/http_logger.dart';

import '../apis/api.dart';
import '../models/system.dart';

class VariationsApi extends Api {
//get variation list from api
  Future<Map<String, dynamic>> get(String link) async {
    dynamic variations;
    String url = link;
    String token = await System().getToken();
    var response =
        await http.get(Uri.parse(Uri.encodeFull(url)), headers: getHeader(token));
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        variations = jsonDecode(response.body);
      } else {
        variations = {'data': [], 'links': {}};
      }
    } else {
      variations = {'data': [], 'links': {}};
    }
    
    List variationList = [];
    if (variations != null && variations['data'] != null) {
      variations['data'].forEach((value) {
        variationList.add(value);
      });
    }
    Map<String, dynamic> apiResponse = {
      "nextLink": variations != null && variations['links'] != null ? variations['links']['next'] : null,
      "products": variationList
    };
    return apiResponse;
  }
}
