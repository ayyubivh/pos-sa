import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos_final/core/theme/app_theme.dart';
import 'package:pos_final/domain/models/payment_database.dart';
import 'package:pos_final/domain/models/sell_database.dart';
import 'package:pos_final/domain/models/system.dart';
import 'package:pos_final/helpers/desktop/keyboard_shortcuts.dart';
import 'package:pos_final/helpers/platform_helper.dart';
import 'package:pos_final/presentation/desktop/layout/desktop_shell.dart';
import 'package:pos_final/presentation/screens/category_screen.dart';
import 'package:pos_final/presentation/screens/home_screen.dart';
import 'package:pos_final/presentation/screens/sales_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import '../config.dart';
import '../locale/MyLocalizations.dart';
import 'SizeConfig.dart';
import 'otherHelpers.dart';

// Mobile-only imports — guarded at usage sites for desktop compatibility
// geolocator, google_maps_flutter, permission_handler are NOT imported here;
// their usage is kept inside pages/home.dart which already has guards.

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> with WindowListener {
  // ---- Desktop: returns the DesktopShell immediately ----
  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return DesktopShortcuts(
        onNewSale: () => Navigator.pushNamed(context, '/cart'),
        onCustomerSearch: () => Navigator.pushNamed(context, '/customer'),
        onProductSearch: () => Navigator.pushNamed(context, '/products'),
        onCheckout: () => Navigator.pushNamed(context, '/checkout'),
        onReport: () => Navigator.pushNamed(context, '/Reports'),
        onFullscreen: () async {
          final isMax = await windowManager.isMaximized();
          isMax
              ? await windowManager.unmaximize()
              : await windowManager.maximize();
        },
        child: const DesktopShell(),
      );
    }
    return _MobileLayout();
  }
}

// ---- Mobile layout (unchanged behaviour) ----
class _MobileLayout extends StatefulWidget {
  @override
  State<_MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<_MobileLayout> {
  var user,
      selectedLanguage;

  String businessSymbol = '',
      businessLogo = '',
      businessName = '',
      userName = '';

  double totalSalesAmount = 0.00,
      totalReceivedAmount = 0.00,
      totalDueAmount = 0.00,
      byCash = 0.00,
      byCard = 0.00,
      byCheque = 0.00,
      byBankTransfer = 0.00,
      byOther = 0.00,
      byCustomPayment_1 = 0.00,
      byCustomPayment_2 = 0.00,
      byCustomPayment_3 = 0.00;

  bool accessExpenses = false,
      syncPressed = false;

  Map<String, dynamic>? paymentMethods;
  int? totalSales;
  List<Map> method = [], payments = [];

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  int _selectedIndex = 0;
  List<Widget> pages_index = <Widget>[Home(), CategoryScreen(), Sales()];

  @override
  void initState() {
    super.initState();
    homepageData();
    Helper().syncCallLogs();
  }

  Future<void> homepageData() async {
    var prefs = await SharedPreferences.getInstance();
    user = await System().get('loggedInUser');
    userName =
        ((user['surname'] != null) ? user['surname'] : '') +
        ' ' +
        user['first_name'];
    await loadPaymentDetails();
    await Helper().getFormattedBusinessDetails().then((value) {
      businessSymbol = value['symbol'];
      businessLogo = value['logo'] ?? Config().defaultBusinessImage;
      businessName = value['name'];
      Config.quantityPrecision = value['quantityPrecision'] ?? 2;
      Config.currencyPrecision = value['currencyPrecision'] ?? 2;
    });
    selectedLanguage =
        prefs.getString('language_code') ?? Config().defaultLanguage;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages_index.elementAt(_selectedIndex),
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _selectedIndex,
        showElevation: true,
        onItemSelected: (value) => setState(() => _selectedIndex = value),
        items: [
          FlashyTabBarItem(
            icon: const Icon(Icons.home_rounded),
            title: Text(AppLocalizations.of(context).translate('home')),
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.category_rounded),
            title: Text(AppLocalizations.of(context).translate('Categories')),
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.bar_chart_rounded),
            title: Text(AppLocalizations.of(context).translate('sales')),
          ),
        ],
      ),
    );
  }

  // ---- Statistics & payment helpers (mobile only) ----

  Future<List> loadStatistics() async {
    List result = await SellDatabase().getSells();
    totalSales = result.length;
    setState(() {
      for (var sell in result) {
        _accumulatePayments(sell);
      }
    });
    return result;
  }

  Future<void> _accumulatePayments(sell) async {
    List payment =
        await PaymentDatabase().get(sell['id'], allColumns: true);
    var paidAmount = 0.0;
    var returnAmount = 0.0;
    for (var element in payment) {
      if (element['is_return'] == 0) {
        paidAmount += element['amount'];
        payments.add({'key': element['method'], 'value': element['amount']});
      } else {
        returnAmount += element['amount'];
      }
    }
    totalSalesAmount += sell['invoice_amount'];
    totalReceivedAmount += (paidAmount - returnAmount);
    totalDueAmount += sell['pending_amount'];
  }

  Future<void> loadPaymentDetails() async {
    var paymentMethod = [];
    await System().get('payment_methods').then((value) {
      value.forEach((element) {
        element.forEach((k, v) {
          paymentMethod.add({'key': '$k', 'value': '$v'});
        });
      });
    });

    await loadStatistics().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        for (var row in payments) {
          switch (row['key']) {
            case 'cash':
              byCash += row['value'];
            case 'card':
              byCard += row['value'];
            case 'cheque':
              byCheque += row['value'];
            case 'bank_transfer':
              byBankTransfer += row['value'];
            case 'other':
              byOther += row['value'];
            case 'custom_pay_1':
              byCustomPayment_1 += row['value'];
            case 'custom_pay_2':
              byCustomPayment_2 += row['value'];
            case 'custom_pay_3':
              byCustomPayment_3 += row['value'];
          }
        }
        for (var row in paymentMethod) {
          if (byCash > 0 && row['key'] == 'cash')
            method.add({'key': row['value'], 'value': byCash});
          if (byCard > 0 && row['key'] == 'card')
            method.add({'key': row['value'], 'value': byCard});
          if (byCheque > 0 && row['key'] == 'cheque')
            method.add({'key': row['value'], 'value': byCheque});
          if (byBankTransfer > 0 && row['key'] == 'bank_transfer')
            method.add({'key': row['value'], 'value': byBankTransfer});
          if (byOther > 0 && row['key'] == 'other')
            method.add({'key': row['value'], 'value': byOther});
          if (byCustomPayment_1 > 0 && row['key'] == 'custom_pay_1')
            method.add({'key': row['value'], 'value': byCustomPayment_1});
          if (byCustomPayment_2 > 0 && row['key'] == 'custom_pay_2')
            method.add({'key': row['value'], 'value': byCustomPayment_2});
          if (byCustomPayment_3 > 0 && row['key'] == 'custom_pay_3')
            method.add({'key': row['value'], 'value': byCustomPayment_3});
        }
        if (mounted) setState(() {});
      });
    });
  }
}
