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
import '../helpers/SizeConfig.dart';
import '../helpers/icons.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../models/attendance.dart';
import '../models/paymentDatabase.dart';
import '../models/sell.dart';
import '../models/sellDatabase.dart';
import '../models/system.dart';
import '../models/variations.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var user,
      note = TextEditingController(),
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

  @override
  void initState() {
    super.initState();
    getPermission();
    homepageData();
    Helper().syncCallLogs();
  }

  //function to set homepage details
  Future<void> homepageData() async {
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
  Future<void> checkIOButtonDisplay() async {
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: homePageDrawer(),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('home'),
          style: AppTheme.getTextStyle(
            themeData.textTheme.titleLarge,
            fontWeight: 600,
          ),
        ),
        actions: <Widget>[
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
            icon: Icon(MdiIcons.syncIcon, color: Colors.orange),
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
            icon: Icon(IconBroken.Logout),
          ),
        ],
        leading: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                child: Icon(Icons.list),
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ),
            SizedBox(width: 10),
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                return Badge.count(
                  smallSize: 10,
                  largeSize: 15,
                  alignment: AlignmentDirectional.topEnd,
                  count: NotificationsCubit.get(context).notificationsCount,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/notify');
                    },
                    child: Icon(
                      IconBroken.Notification,
                      color: Color(0xff4c53a5),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        leadingWidth: 75,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            GreetingWidget(themeData: themeData, userName: userName),
            Statistics(
              themeData: themeData,
              businessSymbol: businessSymbol,
              totalDueAmount: totalDueAmount,
              totalReceivedAmount: totalReceivedAmount,
              totalSales: totalSales,
              totalSalesAmount: totalSalesAmount,
            ),
            SizedBox(height: MySize.size20 ?? 20.0),
            _buildQuickActionsGrid(context),
            paymentDetails(),
          ],
        ),
      ),
    );
  }

  // Build modern quick actions grid
  Widget _buildQuickActionsGrid(BuildContext context) {
    final isDark = themeData.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xff2C2F33) : Colors.white;

    final actions = [
      {
        'icon': Icons.language_rounded,
        'label': 'language',
        'gradientColors': [const Color(0xff00B894), const Color(0xff55D4B4)],
        'onTap': () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeData.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.language_rounded,
                      color: themeData.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context).translate('language'),
                    style: AppTheme.getTextStyle(
                      themeData.textTheme.titleMedium,
                      fontWeight: 700,
                    ),
                  ),
                ],
              ),
              content: changeAppLanguage(),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: themeData.primaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: themeData.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      },
      {
        'icon': IconBroken.Wallet,
        'label': 'expenses',
        'gradientColors': [const Color(0xffFF7675), const Color(0xffFF9A9A)],
        'onTap': () async {
          if (await Helper().checkConnectivity()) {
            Navigator.pushNamed(context, '/expense');
          } else {
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context).translate('check_connectivity'),
            );
          }
        },
      },
      {
        'icon': Icons.payment_rounded,
        'label': 'contact_payment',
        'gradientColors': [const Color(0xff6C5CE7), const Color(0xff8B7FE8)],
        'onTap': () async {
          if (await Helper().checkConnectivity()) {
            Navigator.pushNamed(context, '/contactPayment');
          } else {
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context).translate('check_connectivity'),
            );
          }
        },
      },
      {
        'icon': Icons.follow_the_signs_rounded,
        'label': 'follow_ups',
        'gradientColors': [const Color(0xff0984E3), const Color(0xff4DA8F0)],
        'onTap': () async {
          if (await Helper().checkConnectivity()) {
            Navigator.pushNamed(context, '/leads');
          } else {
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context).translate('check_connectivity'),
            );
          }
        },
      },
      {
        'icon': Icons.people_rounded,
        'label': 'suppliersC',
        'gradientColors': [const Color(0xffF39C12), const Color(0xffF8C471)],
        'onTap': () async {
          if (await Helper().checkConnectivity()) {
            Navigator.pushNamed(context, '/leads');
          } else {
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context).translate('check_connectivity'),
            );
          }
        },
      },
      {
        'icon': Icons.local_shipping_rounded,
        'label': 'shipment',
        'gradientColors': [const Color(0xff16A085), const Color(0xff48C9B0)],
        'onTap': () {
          Navigator.pushNamed(context, '/shipment');
        },
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'label': 'payments',
        'gradientColors': [const Color(0xff8E44AD), const Color(0xffA569BD)],
        'onTap': () {
          Navigator.pushNamed(context, '/sale');
        },
      },
      {
        'icon': Icons.assessment_rounded,
        'label': 'reports',
        'gradientColors': [const Color(0xffE74C3C), const Color(0xffEC7063)],
        'onTap': () {
          Navigator.pushNamed(context, ReportScreen.routeName);
        },
      },
      {
        'icon': Icons.settings_rounded,
        'label': 'settings',
        'gradientColors': [const Color(0xff34495E), const Color(0xff5D6D7E)],
        'onTap': () {
          // Settings action
        },
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MySize.size20 ?? 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Actions',
                style: AppTheme.getTextStyle(
                  themeData.textTheme.titleMedium,
                  fontWeight: 700,
                  letterSpacing: -0.3,
                  fontSize: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: themeData.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${actions.length}',
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodySmall,
                    fontWeight: 700,
                    color: themeData.primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.size16 ?? 16.0),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: MySize.size12 ?? 12.0,
              mainAxisSpacing: MySize.size12 ?? 12.0,
              childAspectRatio: 0.95,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _ModernActionCard(
                themeData: themeData,
                icon: action['icon'] as IconData,
                label: action['label'] as String,
                gradientColors: action['gradientColors'] as List<Color>,
                onTap: action['onTap'] as VoidCallback,
              );
            },
          ),
          SizedBox(height: MySize.size20 ?? 20.0),
        ],
      ),
    );
  }

  //homepage drawer
  Widget homePageDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(height: (MySize.scaleFactorHeight ?? 1.0) * 70),
            Expanded(
              flex: 9,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      Icons.language,
                      color: themeData.colorScheme.onSurface,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'),
                            ),
                          ],
                          title: Text(
                            AppLocalizations.of(context).translate('language'),
                          ),
                          content: changeAppLanguage(),
                        ),
                      );
                    },
                    title: Text(
                      AppLocalizations.of(context).translate('language'),
                    ),
                  ),
                  Visibility(
                    visible: accessExpenses,
                    child: ListTile(
                      leading: Image.asset(
                        'assets/images/money.png',
                        color: Color(0xff42855B),
                        width: 30,
                      ),
                      onTap: () async {
                        if (await Helper().checkConnectivity()) {
                          Navigator.pushNamed(context, '/expense');
                        } else {
                          Fluttertoast.showToast(
                            msg: AppLocalizations.of(
                              context,
                            ).translate('check_connectivity'),
                          );
                        }
                      },
                      title: Text(
                        AppLocalizations.of(context).translate('expenses'),
                        style: AppTheme.getTextStyle(
                          themeData.textTheme.titleSmall,
                          fontWeight: 600,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/payed_money.png',
                      color: Color(0xff820000),
                      width: 30,
                    ),
                    title: Text(
                      AppLocalizations.of(context).translate('contact_payment'),
                      style: AppTheme.getTextStyle(
                        themeData.textTheme.titleSmall,
                        fontWeight: 600,
                      ),
                    ),
                    onTap: () async {
                      if (await Helper().checkConnectivity()) {
                        Navigator.pushNamed(context, '/contactPayment');
                      } else {
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(
                            context,
                          ).translate('check_connectivity'),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/support.png',
                      color: Color(0xff301E67),
                      width: 30,
                    ),
                    title: Text(
                      AppLocalizations.of(context).translate('follow_ups'),
                      style: AppTheme.getTextStyle(
                        themeData.textTheme.titleSmall,
                        fontWeight: 600,
                      ),
                    ),
                    onTap: () async {
                      if (await Helper().checkConnectivity()) {
                        Navigator.pushNamed(context, '/followUp');
                        // await CallLog.get().then((value) =>
                        //     Navigator.push(context, '/followUp'));
                      } else {
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(
                            context,
                          ).translate('check_connectivity'),
                        );
                      }
                    },
                  ),
                  Visibility(
                    visible: Config().showFieldForce,
                    child: ListTile(
                      leading: Icon(
                        MdiIcons.humanMale,
                        color: themeData.colorScheme.onSurface,
                      ),
                      onTap: () async {
                        if (await Helper().checkConnectivity()) {
                          Navigator.pushNamed(context, '/fieldForce');
                        } else {
                          Fluttertoast.showToast(
                            msg: AppLocalizations.of(
                              context,
                            ).translate('check_connectivity'),
                          );
                        }
                      },
                      title: Text(
                        AppLocalizations.of(
                          context,
                        ).translate('field_force_visits'),
                        style: AppTheme.getTextStyle(
                          themeData.textTheme.titleSmall,
                          fontWeight: 600,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/contact.png',
                      color: Color(0xff0064e5),
                      width: 30,
                    ),
                    title: Text(
                      AppLocalizations.of(context).translate('contacts'),
                      style: AppTheme.getTextStyle(
                        themeData.textTheme.titleSmall,
                        fontWeight: 600,
                      ),
                    ),
                    onTap: () async {
                      if (await Helper().checkConnectivity()) {
                        Navigator.pushNamed(context, '/leads');
                        // await CallLog.get().then(
                        //         (value) =>
                        //         Navigator.push(context, '/leads'));
                      } else {
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(
                            context,
                          ).translate('check_connectivity'),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/delivery.png',
                      color: Color(0xffF2921D),
                      width: 30,
                    ),
                    title: Text(
                      AppLocalizations.of(context).translate('shipment'),
                      style: AppTheme.getTextStyle(
                        themeData.textTheme.titleSmall,
                        fontWeight: 600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/shipment');
                    },
                  ),
                  /*ListTile(
                    leading: Image.asset(
                      'assets/images/money.png',
                      color: Color(0xff42855B),
                      width: 30,
                    ),
                    onTap: () async {
                      if (await Helper().checkConnectivity()) {
                        Navigator.pushNamed(context, '/purchases');
                      } else {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)
                                .translate('check_connectivity'));
                      }
                    },
                    title: Text(
                      AppLocalizations.of(context).translate('purchases'),
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.titleSmall,
                          fontWeight: 600),
                    ),
                  )*/
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.all(10),
                child: Text(AppLocalizations.of(context).translate('version')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //multi language option
  Widget changeAppLanguage() {
    var appLanguage = Provider.of<AppLanguage>(context);
    return Container(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: themeData.colorScheme.onPrimary,
          onChanged: (String? newValue) {
            appLanguage.changeLanguage(Locale(newValue!), newValue);
            selectedLanguage = newValue;
            Navigator.pop(context);
          },
          value: selectedLanguage,
          items: Config().lang.map<DropdownMenuItem<String>>((Map locale) {
            return DropdownMenuItem<String>(
              value: locale['languageCode'],
              child: Text(
                locale['name'],
                style: AppTheme.getTextStyle(
                  themeData.textTheme.titleSmall,
                  fontWeight: 600,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  //on sync
  Future<void> sync() async {
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
      padding: EdgeInsets.all(MySize.size8 ?? 8.0),
      margin: EdgeInsets.all(MySize.size16 ?? 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(MySize.size8 ?? 8.0)),
        color: customAppTheme.bgLayer1,
        border: Border.all(color: customAppTheme.bgLayer4, width: 1.2),
      ),
      child: Column(
        children: <Widget>[
          Text(
            AppLocalizations.of(context).translate('payment_details'),
            style: AppTheme.getTextStyle(
              themeData.textTheme.titleMedium,
              fontWeight: 700,
            ),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(10),
            itemCount: method.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              height: 30,
                              width: 2,
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4.0),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                            ),
                            Text(method[index]['key']),
                          ],
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '$businessSymbol ${Helper().formatCurrency(method[index]['value'])}',
                        ),
                      ],
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
  Future<void> getPermission() async {
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
        for (var element in payment) {
          if (element['is_return'] == 0) {
            paidAmount += element['amount'];
            payments.add({
              'key': element['method'],
              'value': element['amount'],
            });
          } else {
            returnAmount += element['amount'];
          }
        }
        totalSalesAmount = (totalSalesAmount + sell['invoice_amount']);
        totalReceivedAmount =
            (totalReceivedAmount + (paidAmount - returnAmount));
        totalDueAmount = (totalDueAmount + sell['pending_amount']);
      });
    });
    return result;
  }

  //load payment details
  Future<void> loadPaymentDetails() async {
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
        for (var row in payments) {
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
        if (mounted) {
          setState(() {});
        }
      });
    });
  }
}

// Modern Action Card Widget
class _ModernActionCard extends StatefulWidget {
  const _ModernActionCard({
    required this.themeData,
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onTap,
  });

  final ThemeData themeData;
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  @override
  State<_ModernActionCard> createState() => _ModernActionCardState();
}

class _ModernActionCardState extends State<_ModernActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeData.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xff2C2F33) : Colors.white;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? widget.gradientColors[0].withOpacity(0.2)
                    : (isDark ? Colors.black38 : Colors.grey.withOpacity(0.1)),
                blurRadius: _isPressed ? 8 : 20,
                offset: Offset(0, _isPressed ? 2 : 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gradient overlay at the top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: widget.gradientColors),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: widget.gradientColors[0].withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          AppLocalizations.of(context).translate(widget.label),
                          textAlign: TextAlign.center,
                          style: AppTheme.getTextStyle(
                            widget.themeData.textTheme.bodySmall,
                            fontWeight: 700,
                            fontSize: 10,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
