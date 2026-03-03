import 'package:flutter/material.dart';
import 'package:pos_final/presentation/screens/login_screen.dart';

import '../helpers/bottomNav.dart';
import '../presentation/screens/brands_screen.dart';
import '../presentation/screens/cart_screen.dart';
import '../presentation/screens/category_screen.dart';
import '../presentation/screens/checkout_screen.dart';
import '../presentation/screens/contact_payment_screen.dart';
import '../presentation/screens/contacts_screen.dart';
import '../presentation/screens/customer_screen.dart';
import '../presentation/screens/expenses_screen.dart';
import '../presentation/screens/field_force_screen.dart';
import '../presentation/screens/follow_up_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/notification_screen.dart';
import '../presentation/screens/on_boarding_screen.dart';
import '../presentation/screens/product_stock_report_screen.dart';
import '../presentation/screens/products_screen.dart';
import '../presentation/screens/profit_loss_report_screen.dart';
import '../presentation/screens/purchases_screen.dart';
import '../presentation/screens/report_screen.dart';
import '../presentation/screens/sales_screen.dart';
import '../presentation/screens/shipment_screen.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/units_screen.dart';

class Routes {
  static Map<String, WidgetBuilder> generateRoute() {
    return {
      '/splash': (context) => Splash(),
      '/onBoarding': (context) => OnBoardingScreen(),
      // '/login': (context) => Login(),
      '/login': (context) => LoginScreen(),
      '/home': (context) => Home(),
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
