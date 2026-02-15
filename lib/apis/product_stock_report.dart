import 'dart:convert';
import 'dart:developer';
import '../models/product_stock_report_model.dart';
import '../models/system.dart';
import 'api.dart';

class ProductStockReportService extends Api {
  Future<dynamic> getProductStockReport() async {
    // ------------------ MOCK PRODUCT STOCK REPORT IMPLEMENTATION ------------------
    // try {
    //   String url = this.baseUrl + this.apiUrl + '/product-stock-report';
    //   var token = await System().getToken();
    //   var response =
    //       await http.get(Uri.parse(url), headers: this.getHeader('$token'));
    //
    //   Map<String, dynamic> productStockReport = jsonDecode(response.body);
    //   List myListData = productStockReport['data'];
    //   List<ProductStockReportModel> myData =
    //       myListData.map((e) => ProductStockReportModel.fromJson(e)).toList();
    //
    //   return myData;
    // } catch (e) {
    //   log("ERROR ${e.toString()}");
    //   return null;
    // }

    await Future.delayed(Duration(milliseconds: 500));
    return [
      ProductStockReportModel(
        totalSold: '10.00',
        stockPrice: '100.00',
        stock: '50.00',
        product: 'Mock Product A',
        sku: 'SKU123',
        type: 'Single',
        locationName: 'Main Store',
        alertQuantity: '5.00',
        categoryName: 'Electronics',
        productId: 1,
        unit: 'Pc',
        enableStock: 1,
        unitPrice: '200.00',
      ),
      ProductStockReportModel(
        totalSold: '5.00',
        stockPrice: '50.00',
        stock: '20.00',
        product: 'Mock Product B',
        sku: 'SKU456',
        type: 'Single',
        locationName: 'Main Store',
        alertQuantity: '2.00',
        categoryName: 'Electronics',
        productId: 2,
        unit: 'Pc',
        enableStock: 1,
        unitPrice: '150.00',
      ),
    ];
    // -----------------------------------------------------------------
  }
}
