import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../../domain/models/profit_loss_report_model.dart';
import '../../domain/models/system.dart';
import 'api_service.dart';

class ProfitLossReportService extends Api {
  Future<dynamic> getProfitLossReport() async {
    try {
      final String url = '$baseUrl$apiUrl/profit-loss-report';
      final token = await System().getToken();

      final response = await http.get(
        Uri.parse(url),
        headers: getHeader(token),
      );

      final profitLossReport = jsonDecode(response.body);

      log(profitLossReport.runtimeType.toString());
      final ProfitLossReportModel myData = ProfitLossReportModel.fromJson(
        profitLossReport['data'],
      );

      return myData;
    } catch (e) {
      log('ERROR ${e.toString()}');
      return null;
    }
  }
}
