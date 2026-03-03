import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../api_end_points.dart';
import '../../domain/models/system.dart';
import 'api_service.dart';

class ContactPaymentApi extends Api {
  Future<dynamic> getCustomerDue(int customerId) async {
    try {
      dynamic customer;
      String url = '${ApiEndPoints.customerDue}$customerId';
      var token = await System().getToken();
      var response = await http.get(Uri.parse(url), headers: getHeader(token));
      customer = jsonDecode(response.body);
      return customer;
    } catch (e) {
      return null;
    }
  }

  Future<int?> postContactPayment(Map payment) async {
    try {
      String url = ApiEndPoints.addContactPayment;
      var token = await System().getToken();
      Map data = payment;
      var response = await http.post(
        Uri.parse(url),
        headers: getHeader(token),
        body: jsonEncode(data),
      );
      return response.statusCode;
    } catch (e) {
      return null;
    }
  }
}
