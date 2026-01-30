import 'package:flutter/material.dart';
import 'package:pos_final/pages/login/login_screen.dart';

import '../helpers/bottomNav.dart';
import '../pages/brands/brands.dart';
import '../pages/cart.dart';
import '../pages/category_screen.dart';
import '../pages/checkout.dart';
import '../pages/contact_payment.dart';
import '../pages/contacts.dart';
import '../pages/customer.dart';
import '../pages/expenses.dart';
import '../pages/field_force.dart';
import '../pages/follow_up.dart';
import '../pages/home/home_screen.dart';

import '../pages/notifications/notify.dart';
import '../pages/on_boarding/on_boarding.dart';
import '../pages/product_stock_report.dart';
import '../pages/products.dart';
import '../pages/profit_loss_report.dart';
import '../pages/purchases/view/purchases_screen.dart';
import '../pages/report.dart';
import '../pages/sales.dart';
import '../pages/shipment.dart';
import '../pages/splash.dart';
import '../pages/units.dart';

class Routes {
  static Map<String, WidgetBuilder> generateRoute() {
    return {
      '/splash': (context) => Splash(),
      '/onBoarding': (context) => OnBoardingScreen(),
      // '/login': (context) => Login(),
      '/login': (context) => LoginScreen(),
      //'/home': (context) => Home(),
      '/home': (context) => HomeScreen(),
      '/products': (context) => Products(),
      '/layout': (context) => Layout(),
      '/Categories': (context) => CategoryScreen(),
      '/BrandsScreen': (context) => BrandsScreen(),
      '/notify': (context) => NotificationScreen(),
      '/sale': (context) => Sales(),
      '/cart': (context) => Cart(),
      '/customer': (context) => Customer(),
      '/checkout': (context) => CheckOut(),
      '/expense': (context) => Expense(),
      '/contactPayment': (context) => ContactPayment(),
      '/shipment': (context) => Shipment(),
      '/leads': (context) => Contacts(),
      '/followUp': (context) => FollowUp(),
      '/fieldForce': (context) => FieldForce(),
      '/purchases': (context) => PurchasesScreen(),
      ReportScreen.routeName: (context) => ReportScreen(),
      ProfitLossReportScreen.routeName: (context) => ProfitLossReportScreen(),
      ProductStockReportScreen.routeName: (context) =>
          ProductStockReportScreen(),
      UnitsScreen.routeName: (context) => UnitsScreen(),
    };
  }
}
