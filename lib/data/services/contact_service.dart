import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../api_end_points.dart';
import '../../domain/models/contact_model.dart';
import '../../domain/models/system.dart';
import 'api_service.dart';

class CustomerApi extends Api {
  dynamic customers;

  Future<dynamic> get() async {
    String? url = ApiEndPoints.getContact;
    var token = await System().getToken();
    do {
      try {
        var response = await http.get(
          Uri.parse(url!),
          headers: getHeader(token),
        );
        url = jsonDecode(response.body)['links']['next'];
        jsonDecode(response.body)['data'].forEach((element) {
          Contact().insertContact(Contact().contactModel(element));
        });
      } catch (e) {
        return null;
      }
    } while (url != null);
  }

  Future<dynamic> add(Map customer) async {
    try {
      String url = ApiEndPoints.addContact;
      var body = json.encode(customer);
      var token = await System().getToken();
      var response = await http.post(
        Uri.parse(url),
        headers: getHeader(token),
        body: body,
      );
      var result = await jsonDecode(response.body);
      return result;
    } catch (e) {
      return null;
    }
  }
}
