import 'dart:convert';

import 'package:pos_final/helpers/http_logger.dart';

import '../models/system.dart';
import 'api.dart';

class FollowUpApi extends Api {
  //get specific follow up detail
  Future<Map> getSpecifiedFollowUp(id) async {
    try {
      var followUps;
      String url = baseUrl + apiUrl + "/crm/follow-ups/$id";
      var token = await System().getToken();
      var response = await http.get(Uri.parse(url), headers: getHeader(token));

      followUps = jsonDecode(response.body);
      var followUpList = followUps['data'][0];
      return followUpList;
    } catch (e) {
      return {};
    }
  }

  //add follow up
  Future<int> addFollowUp(Map followUp) async {
    try {
      String url = baseUrl + apiUrl + "/crm/follow-ups";
      var body = json.encode(followUp);
      var token = await System().getToken();
      var response = await http.post(
        Uri.parse(url),
        headers: getHeader(token),
        body: body,
      );
      return response.statusCode;
    } catch (e) {
      return 0;
    }
  }

  //update follow up
  Future<int> update(Map followUp, id) async {
    try {
      String url = baseUrl + apiUrl + "/crm/follow-ups/$id";
      var body = json.encode(followUp);
      var token = await System().getToken();
      var response = await http.put(
        Uri.parse(url),
        headers: getHeader(token),
        body: body,
      );
      return response.statusCode;
    } catch (e) {
      return 0;
    }
  }

  //post call_logs to api
  Future<bool> syncCallLog(Map callLogs) async {
    try {
      String url = baseUrl + apiUrl + "/crm/call-logs";
      var body = json.encode(callLogs);
      var token = await System().getToken();
      var response = await http.post(
        Uri.parse(url),
        headers: getHeader(token),
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  //get follow up categories
  //get specific follow up detail
  Future<List<dynamic>> getFollowUpCategories() async {
    try {
      var followUpCategories;
      String url = baseUrl + apiUrl + "/taxonomy?type=followup_category";
      var token = await System().getToken();
      var response = await http.get(Uri.parse(url), headers: getHeader(token));

      followUpCategories = jsonDecode(response.body);
      List<dynamic> followUpCategoryList = followUpCategories['data'];
      return followUpCategoryList;
    } catch (e) {
      return [];
    }
  }
}
