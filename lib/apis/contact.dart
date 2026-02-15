import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pos_final/api_end_points.dart';

import '../models/contact_model.dart';
import '../models/system.dart';
import 'api.dart';

class CustomerApi extends Api {
  var customers;

  // ------------------ MOCK CONTACT IMPLEMENTATION ------------------
  Future<void> get() async {
    // String? url = ApiEndPoints.getContact;
    // var token = await System().getToken();
    // do {
    //   try {
    //     var response =
    //         await http.get(Uri.parse(url!), headers: this.getHeader('$token'));
    //     url = jsonDecode(response.body)['links']['next'];
    //     jsonDecode(response.body)['data'].forEach((element) {
    //       Contact().insertContact(Contact().contactModel(element));
    //     });
    //   } catch (e) {
    //     return null;
    //   }
    // } while (url != null);

    await Future.delayed(Duration(seconds: 1));
    var mockData = [
      {
        'id': 1,
        'name': 'Mock Customer 1',
        'city': 'Mock City',
        'state': 'Mock State',
        'country': 'Mock Country',
        'address_line_1': '123 Mock St',
        'address_line_2': '',
        'zip_code': '00000',
        'mobile': '1234567890',
      },
      {
        'id': 2,
        'name': 'Mock Customer 2',
        'supplier_business_name': 'Business 2',
        'city': 'Mock City 2',
        'state': 'Mock State 2',
        'country': 'Mock Country 2',
        'address_line_1': '456 Mock Ave',
        'address_line_2': '',
        'zip_code': '00001',
        'mobile': '0987654321',
      },
    ];

    // Insert mock data usually done by loop
    /* 
       Note: Since we are mocking, we cannot easily insert into the real SQLite DB 
       if the DB schema expects specific constraints or if the DB is not initialized here.
       However, the original code creates a new Contact() instance which seemingly handles DB connection.
       So we can try to insert.
    */
    for (var element in mockData) {
      await Contact().insertContact(Contact().contactModel(element));
    }
  }

  Future<dynamic> add(Map customer) async {
    // try {
    //   String url = ApiEndPoints.addContact;
    //   var body = json.encode(customer);
    //   var token = await System().getToken();
    //   var response = await http.post(Uri.parse(url),
    //       headers: this.getHeader('$token'), body: body);
    //   var result = await jsonDecode(response.body);
    //   return result;
    // } catch (e) {
    //   return null;
    // }

    await Future.delayed(Duration(milliseconds: 500));
    return {
      'success': true,
      'msg': 'Contact added successfully (Mock)',
      'data': customer,
    };
  }

  // -----------------------------------------------------------------
}
