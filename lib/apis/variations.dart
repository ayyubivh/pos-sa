import 'dart:convert';

import '../apis/api.dart';
import '../models/system.dart';

class VariationsApi extends Api {
  //get variation list from api
  // ------------------ MOCK VARIATIONS IMPLEMENTATION ------------------
  Future<Map<String, dynamic>> get(String link) async {
    // var variations;
    // String url = link;
    // String token = await System().getToken();
    // var response =
    //     await http.get(Uri.parse(url), headers: this.getHeader(token));
    // variations = jsonDecode(response.body);
    // List variationList = [];
    // variations['data'].forEach((value) {
    //   variationList.add(value);
    // });
    // Map<String, dynamic> apiResponse = {
    //   "nextLink": variations['links']['next'],
    //   "products": variationList
    // };
    // return apiResponse;

    await Future.delayed(Duration(milliseconds: 200));
    return {
      "nextLink": null,
      "products": [
        {
          "product_id": 1,
          "variation_id": 1,
          "product_name": "Test Product",
          "product_variation_name": "Standard",
          "variation_name": "Regular",
          "sku": "TEST001",
          "sub_sku": "TEST001-1",
          "type": "single",
          "enable_stock": 1,
          "brand_id": 1,
          "unit_id": 1,
          "category_id": 1,
          "sub_category_id": null,
          "tax_id": 1,
          "default_sell_price": "100.00",
          "sell_price_inc_tax": "105.00",
          "product_image_url": "",
          "product_description": "Description of Test Product",
          "selling_price_group": [],
          "product_locations": [
            {"id": 1},
          ],
          "variation_location_details": [
            {
              "product_id": 1,
              "variation_id": 1,
              "location_id": 1,
              "qty_available": "50.0",
            },
          ],
        },
        {
          "product_id": 2,
          "variation_id": 2,
          "product_name": "Another Product",
          "product_variation_name": "Color",
          "variation_name": "Blue",
          "sku": "TEST002",
          "sub_sku": "TEST002-B",
          "type": "variable",
          "enable_stock": 1,
          "brand_id": 2,
          "unit_id": 1,
          "category_id": 2,
          "sub_category_id": null,
          "tax_id": 2,
          "default_sell_price": "200.00",
          "sell_price_inc_tax": "210.00",
          "product_image_url": "",
          "product_description": "Description of Another Product",
          "selling_price_group": [],
          "product_locations": [
            {"id": 1},
          ],
          "variation_location_details": [
            {
              "product_id": 2,
              "variation_id": 2,
              "location_id": 1,
              "qty_available": "20.0",
            },
          ],
        },
      ],
    };
  }

  // -----------------------------------------------------------------
}
