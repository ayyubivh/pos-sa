import 'dart:convert';


import '../models/system.dart';
import 'api.dart';

class FollowUpApi extends Api {
  // ------------------ MOCK FOLLOW UP IMPLEMENTATION ------------------
  //get specific follow up detail
  Future<Map> getSpecifiedFollowUp(id) async {
    // try {
    //   var followUps;
    //   String url = this.baseUrl + this.apiUrl + "/crm/follow-ups/$id";
    //   var token = await System().getToken();
    //   var response =
    //       await http.get(Uri.parse(url), headers: this.getHeader('$token'));
    //
    //   followUps = jsonDecode(response.body);
    //   var followUpList = followUps['data'][0];
    //   return followUpList;
    // } catch (e) {
    //   return {};
    // }

    await Future.delayed(Duration(milliseconds: 500));
    return {
      'id': id,
      'title': 'Mock Follow Up',
      'description': 'This is a mock follow up description',
      'contact_id': 1,
      'status': 'Pending',
      'schedule_type': 'call',
      'start_datetime': DateTime.now().toIso8601String(),
      'end_datetime': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
      'followup_category': {'id': 1, 'name': ' General'},
    };
  }

  //add follow up
  Future<int> addFollowUp(Map followUp) async {
    // try {
    //   String url = this.baseUrl + this.apiUrl + "/crm/follow-ups";
    //   var body = json.encode(followUp);
    //   var token = await System().getToken();
    //   var response = await http.post(Uri.parse(url),
    //       headers: this.getHeader('$token'), body: body);
    //   return response.statusCode;
    // } catch (e) {}

    await Future.delayed(Duration(milliseconds: 500));
    return 200;
  }

  //update follow up
  Future<int> update(Map followUp, id) async {
    // try {
    //   String url = this.baseUrl + this.apiUrl + "/crm/follow-ups/$id";
    //   var body = json.encode(followUp);
    //   var token = await System().getToken();
    //   var response = await http.put(Uri.parse(url),
    //       headers: this.getHeader('$token'), body: body);
    //   return response.statusCode;
    // } catch (e) {}

    await Future.delayed(Duration(milliseconds: 500));
    return 200;
  }

  //post call_logs to api
  Future<bool> syncCallLog(Map callLogs) async {
    // try {
    //   String url = this.baseUrl + this.apiUrl + "/crm/call-logs";
    //   var body = json.encode(callLogs);
    //   var token = await System().getToken();
    //   var response = await http.post(Uri.parse(url),
    //       headers: this.getHeader('$token'), body: body);
    //
    //   if (response.statusCode == 200) {
    //     return true;
    //   } else {
    //     return false;
    //   }
    // } catch (e) {
    //   return false;
    // }

    await Future.delayed(Duration(milliseconds: 500));
    return true;
  }

  //get follow up categories
  //get specific follow up detail
  Future<List<dynamic>> getFollowUpCategories() async {
    // try {
    //   var followUpCategories;
    //   String url = this.baseUrl + this.apiUrl + "/taxonomy?type=followup_category";
    //   var token = await System().getToken();
    //   var response =
    //       await http.get(Uri.parse(url), headers: this.getHeader('$token'));
    //
    //   followUpCategories = jsonDecode(response.body);
    //   List<dynamic> followUpCategoryList = followUpCategories['data'];
    //   return followUpCategoryList;
    // } catch (e) {
    //   return [];
    // }

    await Future.delayed(Duration(milliseconds: 500));
    return [
      {'id': 1, 'name': 'General'},
      {'id': 2, 'name': 'Sales'},
      {'id': 3, 'name': 'Support'},
    ];
  }

  // -----------------------------------------------------------------
}
