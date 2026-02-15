import 'dart:convert';
import 'dart:developer';
import '../models/profit_loss_report_model.dart';
import '../models/system.dart';
import 'api.dart';

class ProfitLossReportService extends Api {
  Future<dynamic> getProfitLossReport() async {
    // ------------------ MOCK PROFIT LOSS REPORT IMPLEMENTATION ------------------
    // try {
    //   String url =this.baseUrl + this.apiUrl + '/profit-loss-report';
    //   var token = await System().getToken();
    //
    //   var response =
    //       await http.get(Uri.parse(url), headers: this.getHeader('$token'));
    //
    //   var profitLossReport = jsonDecode(response.body);
    //
    //   log(profitLossReport.runtimeType.toString());
    //   ProfitLossReportModel myData =
    //       ProfitLossReportModel.fromJson(profitLossReport['data']);
    //
    //   return myData;
    // } catch (e) {
    //   log("ERROR ${e.toString()}");
    //   return null;
    // }

    await Future.delayed(Duration(milliseconds: 500));
    return ProfitLossReportModel(
      totalPurchaseShippingCharge: '10.00',
      totalSellShippingCharge: '15.00',
      totalPurchaseAdditionalExpense: '5.00',
      totalSellAdditionalExpense: '2.00',
      totalTransferShippingCharges: '0.00',
      openingStock: '1000.00',
      closingStock: '1200.00',
      totalPurchase: '500.00',
      totalPurchaseDiscount: '50.00',
      totalPurchaseReturn: '0.00',
      totalSell: '2000.00',
      totalSellDiscount: '100.00',
      totalSellReturn: '50.00',
      totalSellRoundOff: '0.50',
      totalExpense: 300,
      totalAdjustment: '0.00',
      totalRecovered: '0.00',
      totalRewardAmount: '0.00',
      netProfit: 1200.00,
      grossProfit: '1500.00',
    );
    // -----------------------------------------------------------------
  }
}
