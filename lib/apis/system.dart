import 'dart:convert';

import '../apis/tax.dart';
import '../models/system.dart';
import 'api.dart';
import 'contact.dart';

class SystemApi {
  Future<void> store() async {
    await Business().get();
    await Permissions().get();
    await ActiveSubscription().get();
    await CustomerApi().get();
    await Brand().get();
    await Category().get();
    await Payment().get();
    await Tax().get();
    await Location().get();
    await PaymentAccounts().get();
  }
}

class Brand extends Api {
  var brands;

  // ------------------ MOCK BRAND IMPLEMENTATION ------------------
  Future<List> get() async {
    // try {
    //   String url =this.baseUrl + this.apiUrl + "/brand";
    //   var token = await System().getToken();
    //   var response =
    //       await http.get(Uri.parse(url), headers: this.getHeader('$token'));
    //   brands = jsonDecode(response.body);
    //   var brandList = brands['data'];
    //   System().insert('brand', jsonEncode(brandList));
    //   return brandList;
    // } catch (e) {
    //   return [];
    // }

    await Future.delayed(Duration(milliseconds: 200));
    var brandList = [
      {'id': 1, 'name': 'Mock Brand A', 'description': 'Description A'},
      {'id': 2, 'name': 'Mock Brand B', 'description': 'Description B'},
    ];
    await System().insert('brand', jsonEncode(brandList));
    return brandList;
  }

  // -----------------------------------------------------------------
}

class Category extends Api {
  var taxonomy;

  // ------------------ MOCK CATEGORY IMPLEMENTATION ------------------
  Future<List> get() async {
    // try {
    //   String url = this.baseUrl + this.apiUrl + "/taxonomy?type=product";
    //   var token = await System().getToken();
    //   var response =
    //   await http.get(Uri.parse(url), headers: this.getHeader('$token'));
    //   taxonomy = jsonDecode(response.body);
    //   var categoryList = taxonomy['data'];
    //   System().insert('taxonomy', jsonEncode(categoryList));
    //   taxonomy['data'].forEach((element) {
    //     if (element['sub_categories'].isNotEmpty) {
    //       element['sub_categories'].forEach((value) {
    //         System().insert(
    //             'sub_categories',
    //             jsonEncode({'id': value['id'], 'name': value['name']}),
    //             value['parent_id']);
    //       });
    //     }
    //   });
    //   return categoryList;
    // } catch (e) {
    //   return [];
    // }

    await Future.delayed(Duration(milliseconds: 200));
    var categoryList = [
      {
        'id': 1,
        'name': 'Electronics',
        'sub_categories': [
          {'id': 11, 'name': 'Phones', 'parent_id': 1},
          {'id': 12, 'name': 'Laptops', 'parent_id': 1},
        ],
      },
      {'id': 2, 'name': 'Clothing', 'sub_categories': []},
    ];
    await System().insert('taxonomy', jsonEncode(categoryList));
    for (var element in categoryList) {
      var subCategories = element['sub_categories'] as List;
      if (subCategories.isNotEmpty) {
        for (var value in subCategories) {
          System().insert(
            'sub_categories',
            jsonEncode({'id': value['id'], 'name': value['name']}),
            value['parent_id'],
          );
        }
      }
    }
    return categoryList;
  }

  // -----------------------------------------------------------------
}

class Payment extends Api {
  late Map payment;

  // ------------------ MOCK PAYMENT IMPLEMENTATION ------------------
  Future<List> get() async {
    // try {
    //   String url = this.baseUrl + this.apiUrl + "/payment-methods";
    //   var token = await System().getToken();
    //   var response =
    //       await http.get(Uri.parse(url), headers: this.getHeader('$token'));
    //   payment = jsonDecode(response.body);
    //   List paymentList = [];
    //   payment.forEach((key, value) {
    //     paymentList.add({key: value});
    //   });
    //   System().insert('payment_methods', jsonEncode(paymentList));
    //   return paymentList;
    // } catch (e) {
    //   return [];
    // }

    await Future.delayed(Duration(milliseconds: 200));
    List paymentList = [
      {'cash': 'Cash'},
      {'card': 'Card'},
      {'check': 'Cheque'},
      {'bank_transfer': 'Bank Transfer'},
    ];
    await System().insert('payment_methods', jsonEncode(paymentList));
    return paymentList;
  }

  // -----------------------------------------------------------------
}

class Permissions extends Api {
  // ------------------ MOCK PERMISSIONS IMPLEMENTATION ------------------
  Future<void> get() async {
    // try {
    //   String url = this.baseUrl + this.apiUrl + "/user/loggedin";
    //   var token = await System().getToken();
    //   var response =
    //       await http.get(Uri.parse(url), headers: this.getHeader(token));
    //   var userDetails = jsonDecode(response.body);
    //   Map userDetailsMap = userDetails['data'];
    //   if (userDetailsMap.containsKey('all_permissions')) {
    //     var userData = jsonEncode(userDetailsMap['all_permissions']);
    //     await System().insert('user_permissions', userData);
    //   }
    // } catch (e) {}

    await Future.delayed(Duration(milliseconds: 200));
    var permissions = [
      'user.view', 'user.create', 'user.update', 'user.delete',
      'product.view', 'product.create', 'product.update', 'product.delete',
      'sell.view', 'sell.create', 'sell.update', 'sell.delete',
      // Add more permissions as needed
    ];
    await System().insert('user_permissions', jsonEncode(permissions));
  }

  // -----------------------------------------------------------------
}

class Location extends Api {
  var locations;

  // ------------------ MOCK LOCATION IMPLEMENTATION ------------------
  Future<List?> get() async {
    // try {
    //   String url =this.baseUrl + this.apiUrl + "/business-location";
    //   var token = await System().getToken();
    //   var response =
    //       await http.get(Uri.parse(url), headers: this.getHeader('$token'));
    //   locations = jsonDecode(response.body);
    //
    //   List? locationList = locations['data'];
    //   System().insert('location', jsonEncode(locationList));
    //   if (locationList != null) {
    //     locationList.forEach((element) {
    //       System().insert('payment_method',
    //           jsonEncode(element['payment_methods']), element['id']);
    //     });
    //   }
    //   return locationList;
    // } catch (e) {
    //   return [];
    // }

    await Future.delayed(Duration(milliseconds: 200));
    var locationList = [
      {
        'id': 1,
        'name': 'Main Store',
        'payment_methods': [
          {'name': 'cash', 'label': 'Cash'},
          {'name': 'card', 'label': 'Card'},
        ],
      },
      {
        'id': 2,
        'name': 'Branch Store',
        'payment_methods': [
          {'name': 'cash', 'label': 'Cash'},
        ],
      },
    ];
    await System().insert('location', jsonEncode(locationList));
    for (var element in locationList) {
      System().insert(
        'payment_method',
        jsonEncode(element['payment_methods']),
        element['id'],
      );
    }
    return locationList;
  }

  // -----------------------------------------------------------------
}

class Business extends Api {
  var business;

  // ------------------ MOCK BUSINESS IMPLEMENTATION ------------------
  Future<List> get() async {
    // try {
    //   String url =this.baseUrl + this.apiUrl + "/business-details";
    //   var token = await System().getToken();
    //   var response =
    //       await http.get(Uri.parse(url), headers: this.getHeader('$token'));
    //   business = jsonDecode(response.body);
    //   List businessDetails = [business['data']];
    //   System().insert('business', jsonEncode(businessDetails));
    //   return businessDetails;
    // } catch (e) {
    //   return [];
    // }

    await Future.delayed(Duration(milliseconds: 200));
    var businessDetails = [
      {
        'id': 1,
        'name': 'Mock Business',
        'currency': {'symbol': '\$', 'code': 'USD'},
        'logo': null,
        'currency_precision': 2,
        'quantity_precision': 2,
        'tax_label_1': 'Tax',
        'tax_number_1': '123456',
      },
    ];
    await System().insert('business', jsonEncode(businessDetails));
    return businessDetails;
  }

  // -----------------------------------------------------------------
}

class ActiveSubscription extends Api {
  var activeSubscription;

  // ------------------ MOCK SUBSCRIPTION IMPLEMENTATION ------------------
  Future<List> get() async {
    // try {
    //   String url = this.baseUrl + this.apiUrl + "/active-subscription";
    //   var token = await System().getToken();
    //   var response =
    //       await http.get(Uri.parse(url), headers: this.getHeader('$token'));
    //   activeSubscription = jsonDecode(response.body);
    //   List activeSubscriptionDetails = (activeSubscription['data'].isNotEmpty)
    //       ? [activeSubscription['data']]
    //       : [];
    //   System()
    //       .insert('active-subscription', jsonEncode(activeSubscriptionDetails));
    //   return activeSubscriptionDetails;
    // } catch (e) {
    //   return [];
    // }

    await Future.delayed(Duration(milliseconds: 200));
    var activeSubscriptionDetails = [
      {
        'id': 1,
        'package_name': 'Pro Plan',
        'start_date': '2023-01-01',
        'end_date': '2025-01-01',
      },
    ];
    await System().insert(
      'active-subscription',
      jsonEncode(activeSubscriptionDetails),
    );
    return activeSubscriptionDetails;
  }

  // -----------------------------------------------------------------
}

class PaymentAccounts extends Api {
  // ------------------ MOCK ACCOUNTS IMPLEMENTATION ------------------
  Future<List> get() async {
    // try {
    //   var accounts;
    //   String url =this.baseUrl + this.apiUrl + "/payment-accounts";
    //   var token = await System().getToken();
    //   var response =
    //       await http.get(Uri.parse(url), headers: this.getHeader('$token'));
    //   accounts = jsonDecode(response.body);
    //   List paymentAccounts = accounts['data'];
    //   System().insert('payment_accounts', jsonEncode(paymentAccounts));
    //   return paymentAccounts;
    // } catch (e) {
    //   return [];
    // }

    await Future.delayed(Duration(milliseconds: 200));
    var paymentAccounts = [
      {'id': 1, 'name': 'Bank Account 1'},
      {'id': 2, 'name': 'Petty Cash'},
    ];
    await System().insert('payment_accounts', jsonEncode(paymentAccounts));
    return paymentAccounts;
  }

  // -----------------------------------------------------------------
}
