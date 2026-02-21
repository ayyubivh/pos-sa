import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos_final/pages/home/widgets/greeting_widget.dart';
import 'package:pos_final/pages/home/widgets/statistics_widget.dart';
import 'package:pos_final/pages/notifications/view_model_manger/notifications_cubit.dart';
import 'package:pos_final/pages/report.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../helpers/AppTheme.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../models/attendance.dart';
import '../models/paymentDatabase.dart';
import '../models/sell.dart';
import '../models/sellDatabase.dart';
import '../models/system.dart';
import '../models/variations.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var user,
      note = new TextEditingController(),
      clockInTime = DateTime.now(),
      selectedLanguage;
  LatLng? currentLoc;

  String businessSymbol = '',
      businessLogo = '',
      defaultImage = 'assets/images/default_product.png',
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
      attendancePermission = false,
      notPermitted = false,
      syncPressed = false;
  bool? checkedIn;

  // List sells;
  Map<String, dynamic>? paymentMethods;
  int? totalSales;
  List<Map> method = [], payments = [];

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);
  static const Color _bg = Color(0xFFF8FAFC);
  static const Color _bgSoft = Color(0xFFF1F5F9);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _primaryText = Color(0xFF0F172A);
  static const Color _mutedText = Color(0xFF6B7280);
  static const Color _accent = Color(0xFF0F4C81);
  static const Color _outline = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    getPermission();
    homepageData();
    Helper().syncCallLogs();
  }

  //function to set homepage details
  homepageData() async {
    var prefs = await SharedPreferences.getInstance();
    user = await System().get('loggedInUser');
    userName =
        ((user['surname'] != null) ? user['surname'] : "") +
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

  //permission for displaying Attendance Button
  checkIOButtonDisplay() async {
    await Attendance().getCheckInTime(Config.userId).then((value) {
      if (value != null) {
        clockInTime = DateTime.parse(value);
      }
    });
    //if someone has forget to check-in
    //check attendance status
    var activeSubscriptionDetails = await System().get('active-subscription');
    if (activeSubscriptionDetails.length > 0 &&
        activeSubscriptionDetails[0].containsKey('package_details')) {
      Map<String, dynamic> packageDetails =
          activeSubscriptionDetails[0]['package_details'];
      if (packageDetails.containsKey('essentials_module') &&
          packageDetails['essentials_module'].toString() == '1') {
        //get attendance status(check-In/check-Out)
        checkedIn = await Attendance().getAttendanceStatus(Config.userId);
        setState(() {});
      } else {
        setState(() {
          checkedIn = null;
        });
      }
    } else {
      setState(() {
        checkedIn = null;
      });
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: homePageDrawer(),
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('home'),
          style: themeData.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: _primaryText,
          ),
        ),
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu_rounded, color: _primaryText),
        ),
        actions: <Widget>[
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              return Badge.count(
                smallSize: 8,
                largeSize: 16,
                alignment: AlignmentDirectional.topEnd,
                count: NotificationsCubit.get(context).notificationsCount,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/notify');
                  },
                  icon: const Icon(Icons.notifications_none_rounded),
                  color: _primaryText,
                ),
              );
            },
          ),
          IconButton(
            onPressed: () async {
              (await Helper().checkConnectivity())
                  ? await sync()
                  : Fluttertoast.showToast(
                      msg: AppLocalizations.of(
                        context,
                      ).translate('check_connectivity'),
                    );
            },
            icon: Icon(MdiIcons.syncIcon, color: _accent),
          ),
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await SellDatabase().getNotSyncedSells().then((value) {
                if (value.isEmpty) {
                  //saving userId in disk
                  prefs.setInt('prevUserId', Config.userId!);
                  prefs.remove('userId');
                  Navigator.pushReplacementNamed(context, '/login');
                } else {
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(
                      context,
                    ).translate('sync_all_sales_before_logout'),
                  );
                }
              });
            },
            icon: const Icon(Icons.logout_rounded, color: _primaryText),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_bgSoft, _bg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: <Widget>[
                    GreetingWidget(themeData: themeData, userName: userName),
                    const SizedBox(height: 12),
                    Statistics(
                      themeData: themeData,
                      businessSymbol: businessSymbol,
                      totalDueAmount: totalDueAmount,
                      totalReceivedAmount: totalReceivedAmount,
                      totalSales: totalSales,
                      totalSalesAmount: totalSalesAmount,
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActionsCard(),
                    const SizedBox(height: 16),
                    paymentDetails(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _outline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: themeData.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: _primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Shortcuts for your most-used workflows.',
            style: themeData.textTheme.bodyMedium?.copyWith(
              color: _mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _quickActionTile(
                    width: tileWidth,
                    label: AppLocalizations.of(context).translate('language'),
                    icon: Icons.language_rounded,
                    onTap: _showLanguageDialog,
                  ),
                  if (accessExpenses)
                    _quickActionTile(
                      width: tileWidth,
                      label: AppLocalizations.of(context).translate('expenses'),
                      icon: Icons.receipt_long_rounded,
                      onTap: () => _navigateIfOnline('/expense'),
                    ),
                  _quickActionTile(
                    width: tileWidth,
                    label: AppLocalizations.of(
                      context,
                    ).translate('contact_payment'),
                    icon: Icons.payments_rounded,
                    onTap: () => _navigateIfOnline('/contactPayment'),
                  ),
                  _quickActionTile(
                    width: tileWidth,
                    label: AppLocalizations.of(context).translate('follow_ups'),
                    icon: Icons.support_agent_rounded,
                    onTap: () => _navigateIfOnline('/followUp'),
                  ),
                  _quickActionTile(
                    width: tileWidth,
                    label: AppLocalizations.of(context).translate('suppliersC'),
                    icon: Icons.groups_rounded,
                    onTap: () => _navigateIfOnline('/leads'),
                  ),
                  _quickActionTile(
                    width: tileWidth,
                    label: AppLocalizations.of(context).translate('shipment'),
                    icon: Icons.local_shipping_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, '/shipment');
                    },
                  ),
                  _quickActionTile(
                    width: tileWidth,
                    label: AppLocalizations.of(context).translate('payments'),
                    icon: Icons.request_quote_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, '/sale');
                    },
                  ),
                  _quickActionTile(
                    width: tileWidth,
                    label: AppLocalizations.of(context).translate('reports'),
                    icon: Icons.analytics_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, ReportScreen.routeName);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _quickActionTile({
    required double width,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      child: Material(
        color: const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _outline),
            ),
            child: Row(
              children: [
                Icon(icon, color: _accent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: themeData.textTheme.bodySmall?.copyWith(
                      color: _primaryText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateIfOnline(String routeName) async {
    if (await Helper().checkConnectivity()) {
      Navigator.pushNamed(context, routeName);
      return;
    }

    Fluttertoast.showToast(
      msg: AppLocalizations.of(context).translate('check_connectivity'),
    );
  }

  Future<void> _showLanguageDialog() async {
    final appLanguage = Provider.of<AppLanguage>(context, listen: false);
    final currentLanguage =
        selectedLanguage?.toString() ?? Config().defaultLanguage;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        final sheetMaxHeight =
            MediaQuery.of(bottomSheetContext).size.height * 0.55;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: sheetMaxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('language'),
                    style: themeData.textTheme.titleSmall?.copyWith(
                      color: _primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      itemCount: Config().lang.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final locale = Config().lang[index];
                        final code = locale['languageCode'] as String;
                        final isSelected = code == currentLanguage;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              appLanguage.changeLanguage(Locale(code), code);
                              setState(() {
                                selectedLanguage = code;
                              });
                              Navigator.pop(bottomSheetContext);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isSelected
                                    ? _accent.withValues(alpha: 0.08)
                                    : const Color(0xFFFAFBFD),
                                border: Border.all(
                                  color: isSelected ? _accent : _outline,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    size: 18,
                                    color: isSelected ? _accent : _mutedText,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      locale['name'] as String,
                                      style: themeData.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: _primaryText,
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //homepage drawer
  Widget homePageDrawer() {
    return Drawer(
      backgroundColor: _bg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _outline),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.menu_rounded,
                        color: _accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context).translate('home'),
                      style: themeData.textTheme.titleMedium?.copyWith(
                        color: _primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    _drawerItem(
                      icon: Icons.language_rounded,
                      title: AppLocalizations.of(context).translate('language'),
                      onTap: () {
                        Navigator.pop(context);
                        _showLanguageDialog();
                      },
                    ),
                    if (accessExpenses)
                      _drawerItem(
                        icon: Icons.receipt_long_rounded,
                        title: AppLocalizations.of(
                          context,
                        ).translate('expenses'),
                        onTap: () => _navigateFromDrawer('/expense'),
                      ),
                    _drawerItem(
                      icon: Icons.payments_rounded,
                      title: AppLocalizations.of(
                        context,
                      ).translate('contact_payment'),
                      onTap: () => _navigateFromDrawer('/contactPayment'),
                    ),
                    _drawerItem(
                      icon: Icons.support_agent_rounded,
                      title: AppLocalizations.of(
                        context,
                      ).translate('follow_ups'),
                      onTap: () => _navigateFromDrawer('/followUp'),
                    ),
                    if (Config().showFieldForce)
                      _drawerItem(
                        icon: MdiIcons.humanMale,
                        title: AppLocalizations.of(
                          context,
                        ).translate('field_force_visits'),
                        onTap: () => _navigateFromDrawer('/fieldForce'),
                      ),
                    _drawerItem(
                      icon: Icons.contacts_rounded,
                      title: AppLocalizations.of(context).translate('contacts'),
                      onTap: () => _navigateFromDrawer('/leads'),
                    ),
                    _drawerItem(
                      icon: Icons.local_shipping_rounded,
                      title: AppLocalizations.of(context).translate('shipment'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/shipment');
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  AppLocalizations.of(context).translate('version'),
                  style: themeData.textTheme.bodyMedium?.copyWith(
                    color: _mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _outline),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: _accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: themeData.textTheme.titleSmall?.copyWith(
                      color: _primaryText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: _mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateFromDrawer(String routeName) async {
    Navigator.pop(context);
    await _navigateIfOnline(routeName);
  }

  //on sync
  sync() async {
    if (!syncPressed) {
      syncPressed = true;
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text(
                    AppLocalizations.of(context).translate('sync_in_progress'),
                  ),
                ),
              ],
            ),
          );
        },
      );
      await Sell().createApiSell(syncAll: true).then((value) async {
        await Variations().refresh().then((value) {
          Navigator.pop(context);
        });
      });
    }
  }

  //widget for payment details
  Widget paymentDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _outline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).translate('payment_details'),
            style: themeData.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: _primaryText,
            ),
          ),
          const SizedBox(height: 12),
          if (method.isEmpty)
            Text(
              'No payment data available yet.',
              style: themeData.textTheme.bodyMedium?.copyWith(
                color: _mutedText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: method.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFBFD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _outline),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        method[index]['key'],
                        style: themeData.textTheme.bodyMedium?.copyWith(
                          color: _primaryText,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Text(
                      '$businessSymbol ${Helper().formatCurrency(method[index]['value'])}',
                      style: themeData.textTheme.bodyMedium?.copyWith(
                        color: _primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  //get permission
  getPermission() async {
    List<PermissionStatus> status = [
      await Permission.location.status,
      await Permission.storage.status,
      await Permission.camera.status,
      // await Permission.phone.status,
    ];
    notPermitted = status.contains(PermissionStatus.denied);
    await Helper()
        .getPermission('essentials.allow_users_for_attendance_from_api')
        .then((value) {
          if (value == true) {
            checkIOButtonDisplay();
            setState(() {
              attendancePermission = true;
            });
          } else {
            setState(() {
              checkedIn = null;
            });
          }
        });

    if (await Helper().getPermission('all_expense.access') ||
        await Helper().getPermission('view_own_expense')) {
      setState(() {
        accessExpenses = true;
      });
    }
  }

  //checkIn and checkOut button

  //load statistics
  Future<List> loadStatistics() async {
    List result = await SellDatabase().getSells();
    totalSales = result.length;
    setState(() {
      result.forEach((sell) async {
        List payment = await PaymentDatabase().get(
          sell['id'],
          allColumns: true,
        );
        var paidAmount = 0.0;
        var returnAmount = 0.0;
        payment.forEach((element) {
          if (element['is_return'] == 0) {
            paidAmount += element['amount'];
            payments.add({
              'key': element['method'],
              'value': element['amount'],
            });
          } else {
            returnAmount += element['amount'];
          }
        });
        totalSalesAmount = (totalSalesAmount + sell['invoice_amount']);
        totalReceivedAmount =
            (totalReceivedAmount + (paidAmount - returnAmount));
        totalDueAmount = (totalDueAmount + sell['pending_amount']);
      });
    });
    return result;
  }

  //load payment details
  loadPaymentDetails() async {
    var paymentMethod = [];
    //fetch different payment methods
    await System().get('payment_methods').then((value) {
      //Add all PaymentMethods into a List according to key value pair
      value.forEach((element) {
        element.forEach((k, v) {
          paymentMethod.add({'key': '$k', 'value': '$v'});
        });
      });
    });

    await loadStatistics().then((value) {
      Future.delayed(Duration(seconds: 1), () {
        payments.forEach((row) {
          if (row['key'] == 'cash') {
            byCash += row['value'];
          }

          if (row['key'] == 'card') {
            byCard += row['value'];
          }

          if (row['key'] == 'cheque') {
            byCheque += row['value'];
          }

          if (row['key'] == 'bank_transfer') {
            byBankTransfer += row['value'];
          }

          if (row['key'] == 'other') {
            byOther += row['value'];
          }

          if (row['key'] == 'custom_pay_1') {
            byCustomPayment_1 += row['value'];
          }

          if (row['key'] == 'custom_pay_2') {
            byCustomPayment_2 += row['value'];
          }
          if (row['key'] == 'custom_pay_3') {
            byCustomPayment_3 += row['value'];
          }
        });
        paymentMethod.forEach((row) {
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
        });
        if (this.mounted) {
          setState(() {});
        }
      });
    });
  }
}
