import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../../domain/models/product_stock_report_model.dart';
import '../../domain/models/system.dart';
import 'api_service.dart';

class ProductStockReportService extends Api {
  Future<dynamic> getProductStockReport() async {
    try {
      final String url = '$baseUrl$apiUrl/product-stock-report';
      final token = await System().getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: getHeader(token),
      );

      final Map<String, dynamic> productStockReport = jsonDecode(response.body);
      final List myListData = productStockReport['data'];
      final List<ProductStockReportModel> myData = myListData
          .map((e) => ProductStockReportModel.fromJson(e))
          .toList();

      return myData;
    } catch (e) {
      log('ERROR ${e.toString()}');
      return null;
    }
  }
}
