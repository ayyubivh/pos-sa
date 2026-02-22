import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pos_final/config.dart';
import 'package:pos_final/constants.dart';
import 'package:search_choices/search_choices.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../apis/api.dart';
import '../apis/sell.dart';
import '../helpers/AppTheme.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../models/contact_model.dart';
import '../models/paymentDatabase.dart';
import '../models/sell.dart';
import '../models/sellDatabase.dart';
import '../models/system.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  List sellList = [];
  List<String> paymentStatuses = ['all'], invoiceStatuses = ['final', 'draft'];
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false,
      synced = true,
      canViewSell = false,
      canEditSell = false,
      canDeleteSell = false,
      showFilter = false,
      changeUrl = false;
  Map<dynamic, dynamic> selectedLocation = {'id': 0, 'name': 'All'},
      selectedCustomer = {'id': 0, 'name': 'All', 'mobile': ''};
  String selectedPaymentStatus = '';
  String? startDateRange, endDateRange; // selectedInvoiceStatus = 'all';
  List<Map<dynamic, dynamic>> allSalesListMap = [],
      customerListMap = [
        {'id': 0, 'name': 'All', 'mobile': ''},
      ],
      locationListMap = [
        {'id': 0, 'name': 'All'},
      ];
  String symbol = '';
  String? nextPage = '',
      url = "${Api().baseUrl}${Api().apiUrl}/sell?order_by_date=desc";
  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  @override
  void initState() {
    super.initState();
    setCustomers();
    setLocations();
    if ((synced)) refreshSales();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setAllSalesList();
      }
    });
    Helper().syncCallLogs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> setCustomers() async {
    customerListMap.addAll(await Contact().get());
    setState(() {});
  }

  Future<void> setLocations() async {
    await System().get('location').then((value) {
      value.forEach((element) {
        setState(() {
          locationListMap.add({'id': element['id'], 'name': element['name']});
        });
      });
    });
    await System().refreshPermissionList().then((value) async {
      await getPermission().then((value) {
        changeUrl = true;
        onFilter();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: themeData.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          elevation: 0,
          centerTitle: false,
          title: Text(
            AppLocalizations.of(context).translate('sales'),
            style: AppTheme.getTextStyle(
              themeData.textTheme.titleLarge,
              fontWeight: 600,
              fontSize: 22,
              color: kPrimaryTextColor,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: _buildSyncButton(),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: kBackgroundSoftColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: kSurfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                labelColor: kDefaultColor,
                unselectedLabelColor: kMutedTextColor,
                labelStyle: AppTheme.getTextStyle(
                  themeData.textTheme.titleSmall,
                  fontWeight: 600,
                ),
                unselectedLabelStyle: AppTheme.getTextStyle(
                  themeData.textTheme.titleSmall,
                  fontWeight: 500,
                ),
                tabs: [
                  Tab(
                    text: AppLocalizations.of(
                      context,
                    ).translate('recent_sales'),
                  ),
                  Tab(
                    text: AppLocalizations.of(context).translate('all_sales'),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(children: [currentSales(), allSales()]),
      ),
    );
  }

  //Fetch permission from database
  Future<void> getPermission() async {
    var activeSubscriptionDetails = await System().get('active-subscription');
    if (activeSubscriptionDetails.length > 0) {
      if (await Helper().getPermission("sell.update")) {
        canEditSell = true;
      }
      if (await Helper().getPermission("sell.delete")) {
        canDeleteSell = true;
      }
    }
    if (await Helper().getPermission("view_paid_sells_only")) {
      paymentStatuses.add('paid');
      selectedPaymentStatus = 'paid';
    }
    if (await Helper().getPermission("view_due_sells_only")) {
      paymentStatuses.add('due');
      selectedPaymentStatus = 'due';
    }
    if (await Helper().getPermission("view_partial_sells_only")) {
      paymentStatuses.add('partial');
      selectedPaymentStatus = 'partial';
    }
    if (await Helper().getPermission("view_overdue_sells_only")) {
      paymentStatuses.add('overdue');
      selectedPaymentStatus = 'all';
    }
    //await Helper().getPermission("sell.view")
    if (await Helper().getPermission("direct_sell.view")) {
      url = "${Api().baseUrl}${Api().apiUrl}/sell?order_by_date=desc";
      if (paymentStatuses.length < 2) {
        paymentStatuses.addAll(['paid', 'due', 'partial', 'overdue']);
        selectedPaymentStatus = 'all';
      }
      setState(() {
        canViewSell = true;
      });
    } else if (await Helper().getPermission("view_own_sell_only")) {
      url =
          "${Api().baseUrl}${Api().apiUrl}/sell?order_by_date=desc&user_id=${Config.userId}";
      if (paymentStatuses.length < 2) {
        paymentStatuses.addAll(['paid', 'due', 'partial', 'overdue']);
        selectedPaymentStatus = 'all';
      }
      setState(() {
        canViewSell = true;
      });
    }
  }

  Future<void> refreshSales() async {
    if (await Helper().checkConnectivity()) {
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
                    AppLocalizations.of(context).translate('loading'),
                  ),
                ),
              ],
            ),
          );
        },
      );
      //update sells from api
      // await updateSellsFromApi().then((value) {
      sells();
      Navigator.pop(context);
      // });
    } else {
      sells();
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('check_connectivity'),
      );
    }
  }

  //fetch current sales from database
  Future<void> sells() async {
    sellList = [];
    await SellDatabase().getSells(all: true).then((value) {
      value.forEach((element) async {
        if (element['is_synced'] == 0) synced = false;
        var customerDetail = await Contact().getCustomerDetailById(
          element['contact_id'],
        );
        var locationName = await Helper().getLocationNameById(
          element['location_id'],
        );
        setState(() {
          sellList.add({
            'id': element['id'],
            'transaction_date': element['transaction_date'],
            'invoice_no': element['invoice_no'],
            'customer_name': customerDetail['name'],
            'mobile': customerDetail['mobile'],
            'contact_id': element['contact_id'],
            'location_id': element['location_id'],
            'location_name': locationName,
            'status': element['status'],
            'tax_rate_id': element['tax_rate_id'],
            'discount_amount': element['discount_amount'],
            'discount_type': element['discount_type'],
            'sale_note': element['sale_note'],
            'staff_note': element['staff_note'],
            'invoice_amount': element['invoice_amount'],
            'pending_amount': element['pending_amount'],
            'is_synced': element['is_synced'],
            'is_quotation': element['is_quotation'],
            'invoice_url': element['invoice_url'],
            'transaction_id': element['transaction_id'],
          });
        });
      });
    });
    await Helper().getFormattedBusinessDetails().then((value) {
      symbol = value['symbol'];
    });
  }

  //refresh sales list
  Future<void> updateSellsFromApi() async {
    //get synced sells transactionId
    List transactionIds = await SellDatabase().getTransactionIds();

    if (transactionIds.isNotEmpty) {
      //fetch specified sells by transactionId from api
      List specificSales = await SellApi().getSpecifiedSells(transactionIds);

      specificSales.forEach((element) async {
        //fetch sell from database with respective transactionId
        List sell = await SellDatabase().getSellByTransactionId(element['id']);

        if (sell.isNotEmpty) {
          //Updating latest data in sell_payments
          //delete payment lines with reference to its sellId
          await PaymentDatabase().delete(sell[0]['id']);
          element['payment_lines'].forEach((value) async {
            //store payment lines from response
            await PaymentDatabase().store({
              'sell_id': sell[0]['id'],
              'method': value['method'],
              'amount': value['amount'],
              'note': value['note'],
              'payment_id': value['id'],
              'is_return': value['is_return'],
              'account_id': value['account_id'],
            });
          });

          //Updating latest data in sell_lines
          //delete sell_lines with reference to its sellId
          await SellDatabase().deleteSellLineBySellId(sell[0]['id']);

          element['sell_lines'].forEach((value) async {
            //   //store sell lines from response
            await SellDatabase().store({
              'sell_id': sell[0]['id'],
              'product_id': value['product_id'],
              'variation_id': value['variation_id'],
              'quantity': value['quantity'],
              'unit_price': value['unit_price_before_discount'],
              'tax_rate_id': value['tax_id'],
              'discount_amount': value['line_discount_amount'],
              'discount_type': value['line_discount_type'],
              'note': value['sell_line_note'],
              'is_completed': 1,
            });
          });
          //update latest sells details
          updateSells(element);
        }
      });
    }
  }

  //update sells
  Future<void> updateSells(sells) async {
    var changeReturn = 0.0;
    var pendingAmount = 0.0;
    var totalAmount = 0.0;
    List sell = await SellDatabase().getSellByTransactionId(sells['id']);
    await PaymentDatabase().get(sell[0]['id'], allColumns: true).then((value) {
      for (var element in value) {
        if (element['is_return'] == 1) {
          changeReturn += element['amount'];
        } else {
          totalAmount += element['amount'];
        }
      }
    });
    if (double.parse(sells['final_total']) > totalAmount) {
      pendingAmount = double.parse(sells['final_total']) - totalAmount;
    }
    Map<String, dynamic> sellMap = Sell().createSellMap(
      sells,
      changeReturn,
      pendingAmount,
    );
    await SellDatabase().updateSells(sell[0]['id'], sellMap);
  }

  void onFilter() {
    nextPage = url;
    if (selectedLocation['id'] != 0) {
      nextPage = "${nextPage!}&location_id=${selectedLocation['id']}";
    }
    if (selectedCustomer['id'] != 0) {
      nextPage = "${nextPage!}&contact_id=${selectedCustomer['id']}";
    }
    if (selectedPaymentStatus != 'all') {
      nextPage = "${nextPage!}&payment_status=$selectedPaymentStatus";
    } else if (selectedPaymentStatus == 'all') {
      List<String> status = List.from(paymentStatuses);
      status.remove('all');
      String statuses = status.join(',');
      nextPage = "${nextPage!}&payment_status=$statuses";
    }
    if (startDateRange != null && endDateRange != null) {
      nextPage =
          "${nextPage!}&start_date=$startDateRange&end_date=$endDateRange";
    }
    changeUrl = true;
    setAllSalesList();
  }

  //Retrieve sales list from api
  void setAllSalesList() async {
    setState(() {
      if (changeUrl) {
        allSalesListMap = [];
        changeUrl = false;
        showFilter = false;
      }
      isLoading = false;
    });
    final dio = Dio();
    var token = await System().getToken();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["Authorization"] = "Bearer $token";
    final response = await dio.get(nextPage!);
    List sales = response.data['data'];
    Map links = response.data['links'];
    nextPage = links['next'];
    sales.forEach((sell) async {
      String paidAmount;
      List payments = sell['payment_lines'];
      double totalPaid = 0.00;
      Map<String, dynamic>? customer =
          //sell['contact'];
          await Contact().getCustomerDetailById(sell['contact_id']);
      var location = await Helper().getLocationNameById(sell['location_id']);
      for (var element in payments) {
        totalPaid += double.parse(element['amount']);
      }
      (totalPaid <= double.parse(sell['final_total']))
          ? paidAmount = Helper().formatCurrency(totalPaid)
          : paidAmount = Helper().formatCurrency(sell['final_total']);
      allSalesListMap.add({
        'id': sell['id'],
        'location_name': location,
        'contact_name': (customer != null)
            ? ("${(customer['name'] != null) ? customer['name'] : ''} "
                  "${(customer['supplier_business_name'] != null) ? customer['supplier_business_name'] : ''}")
            : null,
        'mobile': (customer != null) ? customer['mobile'] : null,
        'invoice_no': sell['invoice_no'],
        'invoice_url': sell['invoice_url'],
        'date_time': sell['transaction_date'],
        'invoice_amount': sell['final_total'],
        'status': sell['payment_status'] ?? sell['status'],
        'paid_amount': paidAmount,
        'is_quotation': sell['is_quotation'].toString(),
      });
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
    });
  }

  //progress indicator
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: FutureBuilder<bool>(
          future: Helper().checkConnectivity(),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data == false) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(
                      context,
                    ).translate('check_connectivity'),
                    style: AppTheme.getTextStyle(
                      themeData.textTheme.titleMedium,
                      fontWeight: 700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Icon(
                    Icons.error_outline,
                    color: themeData.colorScheme.onSurface,
                  ),
                ],
              );
            } else {
              return CircularProgressIndicator(color: kDefaultColor);
            }
          },
        ),
      ),
    );
  }

  //widget for listing sales from database
  Widget currentSales() {
    return (sellList.isNotEmpty)
        ? ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10),
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: sellList.length,
            itemBuilder: (context, index) {
              return saleCard(
                price: Helper().formatCurrency(
                  sellList[index]['invoice_amount'],
                ),
                number: sellList[index]['invoice_no'],
                status: checkStatus(
                  double.parse(sellList[index]['invoice_amount'].toString()),
                  double.parse(sellList[index]['pending_amount'].toString()),
                ),
                time: sellList[index]['transaction_date'],
                paid: Helper().formatCurrency(
                  sellList[index]['invoice_amount'] -
                      sellList[index]['pending_amount'],
                ),
                isSynced: sellList[index]['is_synced'],
                customerName: sellList[index]['customer_name'],
                locationName: sellList[index]['location_name'],
                isQuotation: sellList[index]['is_quotation'],
                index: index,
                isLocal: true,
              );
            },
          )
        : Helper().noDataWidget(context);
  }

  //widget for listing sales from api
  Widget allSales() {
    return (canViewSell)
        ? Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    showFilter = !showFilter;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kSurfaceColor,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 28,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                MdiIcons.filterVariant,
                                color: kDefaultColor,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('filter'),
                                style: AppTheme.getTextStyle(
                                  themeData.textTheme.titleMedium,
                                  color: kPrimaryTextColor,
                                  fontWeight: 600,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            (showFilter)
                                ? MdiIcons.chevronUp
                                : MdiIcons.chevronDown,
                            color: kMutedTextColor,
                            size: 20,
                          ),
                        ],
                      ),
                      if (showFilter) ...[
                        SizedBox(height: 20),
                        Divider(height: 1, color: kOutlineColor),
                        SizedBox(height: 20),
                        _buildFilterRow(
                          label: AppLocalizations.of(
                            context,
                          ).translate('location'),
                          child: locations(),
                        ),
                        SizedBox(height: 16),
                        _buildFilterRow(
                          label: AppLocalizations.of(
                            context,
                          ).translate('customer'),
                          child: customers(),
                        ),
                        SizedBox(height: 16),
                        _buildFilterRow(
                          label: AppLocalizations.of(
                            context,
                          ).translate('date_range'),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<Null>(
                                  builder: (BuildContext context) {
                                    return dateRangePicker();
                                  },
                                  fullscreenDialog: true,
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: kBackgroundSoftColor,
                                border: Border.all(color: kOutlineColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    MdiIcons.calendarRange,
                                    size: 18,
                                    color: kMutedTextColor,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    (startDateRange != null &&
                                            endDateRange != null)
                                        ? "$startDateRange - $endDateRange"
                                        : AppLocalizations.of(
                                            context,
                                          ).translate('select_range'),
                                    style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyMedium,
                                      color: kPrimaryTextColor,
                                      fontWeight: 500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        if (paymentStatuses.isNotEmpty)
                          _buildFilterRow(
                            label: AppLocalizations.of(
                              context,
                            ).translate('payment_status'),
                            child: paymentStatus(),
                          ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedLocation = locationListMap[0];
                                    selectedCustomer = customerListMap[0];
                                    startDateRange = null;
                                    endDateRange = null;
                                    selectedPaymentStatus = paymentStatuses[0];
                                  });
                                  onFilter();
                                },
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('reset'),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  onFilter();
                                },
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('apply'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(
                child: (allSalesListMap.isNotEmpty)
                    ? ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemCount: allSalesListMap.length,
                        itemBuilder: (context, index) {
                          if (index == allSalesListMap.length) {
                            return (isLoading)
                                ? _buildProgressIndicator()
                                : Container();
                          } else {
                            return saleCard(
                              index: index,
                              price: allSalesListMap[index]['invoice_amount'],
                              number: allSalesListMap[index]['invoice_no'],
                              time: allSalesListMap[index]['date_time'],
                              status: allSalesListMap[index]['status'],
                              paid: allSalesListMap[index]['paid_amount'],
                              customerName:
                                  allSalesListMap[index]['contact_name'],
                              locationName:
                                  allSalesListMap[index]['location_name'],
                              isQuotation: int.parse(
                                allSalesListMap[index]['is_quotation']
                                    .toString(),
                              ),
                              isLocal: false,
                            );
                          }
                        },
                      )
                    : Helper().noDataWidget(context),
              ),
            ],
          )
        : Center(
            child: Text(
              AppLocalizations.of(context).translate('unauthorised'),
              style: TextStyle(color: Colors.black),
            ),
          );
  }

  Widget _buildSyncButton() {
    return Container(
      decoration: BoxDecoration(
        color: synced
            ? kDefaultColor.withValues(alpha: .1)
            : Colors.orange.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: _handleSync,
        icon: Icon(
          synced ? Icons.sync : Icons.sync_problem,
          size: 22,
          color: synced ? kDefaultColor : Colors.orange,
        ),
        tooltip: AppLocalizations.of(context).translate('sync'),
      ),
    );
  }

  Future<void> _handleSync() async {
    if (await Helper().checkConnectivity()) {
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: kDefaultColor,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).translate('sync_in_progress'),
                      style: AppTheme.getTextStyle(
                        themeData.textTheme.bodyMedium,
                        fontWeight: 500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      await Sell().createApiSell(syncAll: true).then((value) {
        Navigator.pop(context);
        setState(() {
          synced = true;
          sells();
        });
      });
    } else {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('check_connectivity'),
      );
    }
  }

  Widget dateRangePicker() {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('select_range')),
        elevation: 0,
        backgroundColor: kBackgroundColor,
        iconTheme: IconThemeData(color: kPrimaryTextColor),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: kSurfaceColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: SfDateRangePicker(
                  view: DateRangePickerView.month,
                  selectionMode: DateRangePickerSelectionMode.range,
                  headerStyle: DateRangePickerHeaderStyle(
                    textStyle: AppTheme.getTextStyle(
                      themeData.textTheme.titleMedium,
                      fontWeight: 600,
                    ),
                  ),
                  monthViewSettings: DateRangePickerMonthViewSettings(
                    firstDayOfWeek: 1,
                  ),
                  selectionColor: kDefaultColor,
                  startRangeSelectionColor: kDefaultColor.withValues(alpha: .8),
                  endRangeSelectionColor: kDefaultColor.withValues(alpha: .8),
                  rangeSelectionColor: kDefaultColor.withValues(alpha: .15),
                  todayHighlightColor: kDefaultColor,
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                        if (args.value.startDate != null) {
                          setState(() {
                            startDateRange = DateFormat(
                              'yyyy-MM-dd',
                            ).format(args.value.startDate!).toString();
                          });
                        }
                        if (args.value.endDate != null) {
                          setState(() {
                            endDateRange = DateFormat(
                              'yyyy-MM-dd',
                            ).format(args.value.endDate!).toString();
                          });
                        }
                      },
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: kSurfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        startDateRange = null;
                        endDateRange = null;
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalizations.of(context).translate('reset'),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context).translate('ok')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getTextStyle(
            themeData.textTheme.labelSmall,
            fontWeight: 600,
            color: kMutedTextColor,
          ),
        ),
        SizedBox(height: 8),
        child,
      ],
    );
  }

  // Unified Sale Card Widget
  Widget saleCard({
    required String number,
    required String time,
    required String status,
    required String price,
    required String paid,
    String? customerName,
    String? locationName,
    required int isQuotation,
    int? isSynced,
    int? index,
    bool isLocal = false,
  }) {
    bool isPaid =
        status.toLowerCase() ==
            AppLocalizations.of(context).translate('paid') ||
        status.toLowerCase() == 'paid';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
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
          // Header Section
          Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (isQuotation == 0)
                            ? "${AppLocalizations.of(context).translate('invoice_no')} $number"
                            : "${AppLocalizations.of(context).translate('ref_no')} $number",
                        style: AppTheme.getTextStyle(
                          themeData.textTheme.titleMedium,
                          fontWeight: 600,
                          color: kPrimaryTextColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        time,
                        style: AppTheme.getTextStyle(
                          themeData.textTheme.bodySmall,
                          color: kMutedTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(status, isQuotation),
              ],
            ),
          ),

          Divider(height: 1, color: kOutlineColor, indent: 24, endIndent: 24),

          // Content Section
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              children: [
                _infoRow(
                  AppLocalizations.of(context).translate('customer'),
                  customerName ?? '-',
                  MdiIcons.accountOutline,
                ),
                SizedBox(height: 12),
                _infoRow(
                  AppLocalizations.of(context).translate('location'),
                  locationName ?? '-',
                  MdiIcons.mapMarkerOutline,
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kBackgroundSoftColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate('total'),
                            style: AppTheme.getTextStyle(
                              themeData.textTheme.labelSmall,
                              color: kMutedTextColor,
                            ),
                          ),
                          Text(
                            "$symbol$price",
                            style: AppTheme.getTextStyle(
                              themeData.textTheme.titleMedium,
                              fontWeight: 600,
                              color: kPrimaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      if (isQuotation == 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppLocalizations.of(context).translate('paid'),
                              style: AppTheme.getTextStyle(
                                themeData.textTheme.labelSmall,
                                color: kMutedTextColor,
                              ),
                            ),
                            Text(
                              "$symbol$paid",
                              style: AppTheme.getTextStyle(
                                themeData.textTheme.titleMedium,
                                fontWeight: 600,
                                color: isPaid
                                    ? Colors.green[700]
                                    : kPrimaryTextColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Actions Section
          if (index != null || !isLocal)
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  // Delete Action
                  if (!isLocal || canDeleteSell)
                    _actionIcon(
                      icon: MdiIcons.trashCanOutline,
                      color: Colors.red[400]!,
                      onPressed: () => _confirmDelete(index, isLocal),
                    ),

                  // Printer Action
                  _actionIcon(
                    icon: MdiIcons.printerOutline,
                    color: Colors.deepPurple[400]!,
                    onPressed: () => _printInvoice(index, isLocal),
                  ),

                  // Share Action
                  _actionIcon(
                    icon: MdiIcons.shareVariantOutline,
                    color: Colors.blue[600]!,
                    onPressed: () => _shareInvoice(index, isLocal),
                  ),

                  // Payment Action (only for local due sells)
                  if (index != null &&
                      isLocal &&
                      sellList[index]['pending_amount'] > 0 &&
                      canEditSell)
                    _actionIcon(
                      icon: MdiIcons.cardAccountDetailsOutline,
                      color: Colors.teal[600]!,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/checkout',
                          arguments: Helper().argument(
                            invoiceAmount:
                                sellList[index]['invoice_amount'] ?? 0.0,
                            customerId: sellList[index]['contact_id'] ?? 0,
                            locId: sellList[index]['location_id'] ?? 0,
                            discountAmount:
                                double.tryParse(
                                  sellList[index]['discount_amount'].toString(),
                                ) ??
                                0.0,
                            discountType:
                                sellList[index]['discount_type'] ?? '',
                            isQuotation: sellList[index]['is_quotation'] ?? 0,
                            taxId: sellList[index]['tax_rate_id'] ?? 0,
                            sellId: sellList[index]['id'] ?? 0,
                          ),
                        );
                      },
                    ),

                  if (isLocal && isSynced == 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        MdiIcons.syncAlert,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status, int isQuotation) {
    bool isQuote = isQuotation != 0;
    Color color = isQuote ? Colors.orange : checkStatusColor(status);
    String label = isQuote ? 'QUOTATION' : status.toUpperCase();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTheme.getTextStyle(
          themeData.textTheme.labelSmall,
          color: color,
          fontWeight: 700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kMutedTextColor),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.getTextStyle(
                  themeData.textTheme.labelSmall,
                  color: kMutedTextColor,
                ),
              ),
              Text(
                value,
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyMedium,
                  color: kPrimaryTextColor,
                  fontWeight: 500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  void _confirmDelete(int? index, bool isLocal) {
    if (index == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context).translate('are_you_sure')),
        content: Text(
          AppLocalizations.of(context).translate('delete_confirmation_msg'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              if (isLocal) {
                await SellDatabase().deleteSell(sellList[index]['id']);
                await SellApi().delete(sellList[index]['transaction_id']);
                sells();
              } else {
                await SellApi().delete(allSalesListMap[index]['id']).then((
                  value,
                ) {
                  if (value != null) {
                    setState(() {
                      allSalesListMap.removeAt(index);
                    });
                    Fluttertoast.showToast(msg: '${value['msg']}');
                  }
                });
              }
            },
            child: Text(AppLocalizations.of(context).translate('delete')),
          ),
        ],
      ),
    );
  }

  Future<void> _printInvoice(int? index, bool isLocal) async {
    if (index == null) return;
    var item = isLocal ? sellList[index] : allSalesListMap[index];
    if (await Helper().checkConnectivity() && item['invoice_url'] != null) {
      final response = await http.Client().get(Uri.parse(item['invoice_url']));
      if (response.statusCode == 200) {
        await Helper().printDocument(
          item['id'] ?? 0,
          item['tax_rate_id'] ?? 0,
          context,
          invoice: response.body,
        );
      } else {
        await Helper().printDocument(
          item['id'] ?? 0,
          item['tax_rate_id'] ?? 0,
          context,
        );
      }
    } else {
      await Helper().printDocument(
        item['id'] ?? 0,
        item['tax_rate_id'] ?? 0,
        context,
      );
    }
  }

  Future<void> _shareInvoice(int? index, bool isLocal) async {
    if (index == null) return;
    var item = isLocal ? sellList[index] : allSalesListMap[index];
    if (await Helper().checkConnectivity() && item['invoice_url'] != null) {
      final response = await http.Client().get(Uri.parse(item['invoice_url']));
      if (response.statusCode == 200) {
        await Helper().savePdf(
          item['id'] ?? 0,
          item['tax_rate_id'] ?? 0,
          context,
          item['invoice_no'],
          invoice: response.body,
        );
      } else {
        await Helper().savePdf(
          item['id'] ?? 0,
          item['tax_rate_id'] ?? 0,
          context,
          item['invoice_no'],
        );
      }
    } else {
      await Helper().savePdf(
        item['id'] ?? 0,
        item['tax_rate_id'] ?? 0,
        context,
        item['invoice_no'],
      );
    }
  }

  Widget customers() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kBackgroundSoftColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kOutlineColor),
      ),
      child: SearchChoices.single(
        underline: SizedBox(),
        displayClearIcon: false,
        value: jsonEncode(selectedCustomer),
        items: customerListMap.map<DropdownMenuItem<String>>((Map value) {
          return DropdownMenuItem<String>(
            value: jsonEncode(value),
            child: Text(
              "${value['name']} (${value['mobile'] ?? ' - '})",
              style: AppTheme.getTextStyle(
                themeData.textTheme.bodyMedium,
                color: kPrimaryTextColor,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              selectedCustomer = jsonDecode(value);
            });
          }
        },
        isExpanded: true,
        hint: Text(
          AppLocalizations.of(context).translate('select_customer'),
          style: AppTheme.getTextStyle(
            themeData.textTheme.bodyMedium,
            color: kMutedTextColor,
          ),
        ),
      ),
    );
  }

  Widget locations() {
    return _buildThemedPicker(
      value: selectedLocation['name'],
      onTap: () {}, // Handled by PopupMenuButton
      child: PopupMenuButton<Map>(
        onSelected: (Map item) {
          setState(() {
            selectedLocation = item;
          });
        },
        itemBuilder: (BuildContext context) {
          return locationListMap.map((Map value) {
            return PopupMenuItem(
              value: value,
              child: Text(
                value['name'],
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyMedium,
                  color: kPrimaryTextColor,
                ),
              ),
            );
          }).toList();
        },
        offset: Offset(0, 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedLocation['name'],
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyMedium,
                  color: kPrimaryTextColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(MdiIcons.chevronDown, size: 20, color: kMutedTextColor),
          ],
        ),
      ),
    );
  }

  Widget paymentStatus() {
    return _buildThemedPicker(
      value: selectedPaymentStatus,
      onTap: () {},
      child: PopupMenuButton<String>(
        onSelected: (String item) {
          setState(() {
            selectedPaymentStatus = item;
          });
        },
        itemBuilder: (BuildContext context) {
          return paymentStatuses.map((String value) {
            return PopupMenuItem(
              value: value,
              child: Text(
                AppLocalizations.of(context).translate(value).toUpperCase(),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyMedium,
                  color: kPrimaryTextColor,
                ),
              ),
            );
          }).toList();
        },
        offset: Offset(0, 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(
                  context,
                ).translate(selectedPaymentStatus).toUpperCase(),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyMedium,
                  color: kPrimaryTextColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(MdiIcons.chevronDown, size: 20, color: kMutedTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildThemedPicker({
    required String value,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kBackgroundSoftColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kOutlineColor),
      ),
      child: child,
    );
  }

  //status color
  Color checkStatusColor(String? status) {
    if (status != null) {
      String s = status.toLowerCase();
      if (s == AppLocalizations.of(context).translate('paid').toLowerCase() ||
          s == 'paid')
        return Colors.green;
      if (s == 'due') return Colors.red;
      if (s == 'partial' ||
          s == AppLocalizations.of(context).translate('partial').toLowerCase())
        return Colors.orange;
      return Colors.blueGrey;
    }
    return Colors.black12;
  }

  //status status of recent sales
  String checkStatus(double invoiceAmount, double pendingAmount) {
    if (pendingAmount == invoiceAmount) return 'due';
    if (pendingAmount >= 0.01)
      return AppLocalizations.of(context).translate('partial');
    return AppLocalizations.of(context).translate('paid');
  }
}
