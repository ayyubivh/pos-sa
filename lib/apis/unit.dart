import 'dart:convert';
import 'dart:developer';
import '../models/system.dart';
import 'api.dart';

class UnitService extends Api {
  // ------------------ MOCK UNIT IMPLEMENTATION ------------------
  Future<List> getUnits() async {
    // try {
    //   String url = this.baseUrl + this.apiUrl + '/unit';
    //   var token = await System().getToken();
    //
    //   var response =
    //       await http.get(Uri.parse(url), headers: this.getHeader('$token'));
    //   log(" getUnits getUnits \n  === \n    " + response.body);
    //   var units = jsonDecode(response.body);
    //
    //   log(units.runtimeType.toString());
    //
    //   /* ProfitLossReportModel mydata =
    //       ProfitLossReportModel.fromJson(productStockReport['data']);*/
    //
    //   //  log("mydata${mydata.totalSellDiscount}");
    //
    //   return "mydata";
    // } catch (e) {
    //   log("ERROR ${e.toString()}");
    //   return null;
    // }

    await Future.delayed(Duration(milliseconds: 200));
    return [
      {
        'id': 1,
        'actual_name': 'Pieces',
        'short_name': 'Pc',
        'allow_decimal': 0,
      },
      {
        'id': 2,
        'actual_name': 'Kilograms',
        'short_name': 'Kg',
        'allow_decimal': 1,
      },
    ];
  }

  // -----------------------------------------------------------------
}
