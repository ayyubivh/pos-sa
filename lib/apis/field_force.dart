import 'dart:convert';


import '../models/system.dart';
import 'api.dart';

class FieldForceApi extends Api {
  // ------------------ MOCK FIELD FORCE IMPLEMENTATION ------------------
  //add new visit
  Future<int> create(Map visitDetails) async {
    // try {
    //   String url =this.baseUrl + this.apiUrl + "/field-force/create";
    //   var body = json.encode(visitDetails);
    //   var token = await System().getToken();
    //   var response = await http.post(Uri.parse(url),
    //       headers: this.getHeader('$token'), body: body);
    //   return response.statusCode;
    // } catch (e) {}

    await Future.delayed(Duration(seconds: 1));
    return 200;
  }

  //update visit status
  Future<int> update(Map visitDetails, id) async {
    // try {
    //   String url = this.baseUrl + this.apiUrl + "/field-force/update-visit-status/$id";
    //   var body = json.encode(visitDetails);
    //   var token = await System().getToken();
    //   var response = await http.post(Uri.parse(url),
    //       headers: this.getHeader('$token'), body: body);
    //   return response.statusCode;
    // } catch (e) {
    //   return null;
    // }

    await Future.delayed(Duration(seconds: 1));
    return 200;
  }

  // -----------------------------------------------------------------
}
