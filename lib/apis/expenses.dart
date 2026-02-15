import 'dart:convert';


import '../models/system.dart';
import 'api.dart';

class ExpenseApi extends Api {
  // ------------------ MOCK EXPENSE IMPLEMENTATION ------------------
  //create an expense in api
  Future<Map<String, dynamic>?> create(data) async {
    // try {
    //   String url =this.baseUrl + this.apiUrl + "/expense";
    //   var token = await System().getToken();
    //   var response = await http.post(Uri.parse(url),
    //       headers: this.getHeader('$token'), body: jsonEncode(data));
    //   var info = jsonDecode(response.body);
    //   return info;
    // } catch (e) {
    //   return null;
    // }

    await Future.delayed(Duration(milliseconds: 500));
    return {'success': true, 'msg': 'Expense created (Mock)'};
  }

  //create an expense in api
  Future<List> get() async {
    // try {
    //   String url = this.baseUrl + this.apiUrl + "/expense-categories";
    //   var token = await System().getToken();
    //   var response =
    //       await http.get(Uri.parse(url), headers: this.getHeader('$token'));
    //   Map<String, dynamic>? result = jsonDecode(response.body);
    //   List expenseCategories = (result != null) ? result['data'] : [];
    //   return expenseCategories;
    // } catch (e) {
    //   return [];
    // }

    await Future.delayed(Duration(milliseconds: 500));
    return [
      {'id': 1, 'name': 'Travel', 'code': 'TRV'},
      {'id': 2, 'name': 'Food', 'code': 'FD'},
      {'id': 3, 'name': 'Office Supplies', 'code': 'OS'},
    ];
  }

  // -----------------------------------------------------------------
}
