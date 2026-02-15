import 'dart:convert';


import '../models/system.dart';
import 'api.dart';

class Tax extends Api {
  var taxes;

  // ------------------ MOCK TAX IMPLEMENTATION ------------------
  Future<List> get() async {
    // try {
    //   String url = this.baseUrl + this.apiUrl + "/tax";
    //   var token = await System().getToken();
    //   var response =
    //       await http.get(Uri.parse(url), headers: this.getHeader('$token'));
    //   taxes = jsonDecode(response.body);
    //   var taxList = taxes['data'];
    //   System().insert('tax', jsonEncode(taxList));
    //   return taxList;
    // } catch (e) {
    //   return [];
    // }

    await Future.delayed(Duration(milliseconds: 200));
    var taxList = [
      {'id': 1, 'name': 'VAT', 'amount': 15},
      {'id': 2, 'name': 'Service Tax', 'amount': 5},
    ];
    await System().insert('tax', jsonEncode(taxList));
    return taxList;
  }

  // -----------------------------------------------------------------
}
