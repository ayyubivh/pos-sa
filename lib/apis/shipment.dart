import 'dart:convert';


import '../apis/api.dart';
import '../models/system.dart';

class ShipmentApi extends Api {
  // ------------------ MOCK SHIPMENT IMPLEMENTATION ------------------
  //get sell by shipment status
  Future<List<Map<String, Object>>> getSellByShipmentStatus(
    String status,
    String date,
  ) async {
    // String url = this.baseUrl + this.apiUrl + "/sell/?start_date=$date&shipping_status=$status";
    // var token = await System().getToken();
    // var response = [];
    // await http
    //     .get(Uri.parse(url), headers: this.getHeader('$token'))
    //     .then((value) {
    //   response = jsonDecode(value.body)['data'];
    // });
    // return response;

    await Future.delayed(Duration(seconds: 1));
    return [
      {
        'id': 1,
        'shipping_status': status,
        'transaction_date': date,
        // ... mock fields
      },
    ];
  }

  //update shipment status in api
  Future<Map<String, bool>> updateShipmentStatus(data) async {
    // String url = this.baseUrl + this.apiUrl + "/update-shipping-status";
    // var token = await System().getToken();
    // var body = jsonEncode(data);
    // var response;
    // await http
    //     .post(Uri.parse(url), headers: this.getHeader('$token'), body: body)
    //     .then((value) {
    //   response = jsonDecode(value.body);
    // });
    // return response;

    await Future.delayed(Duration(seconds: 1));
    return {'success': true};
  }

  // -----------------------------------------------------------------
}
