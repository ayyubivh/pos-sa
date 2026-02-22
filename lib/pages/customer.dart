import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pos_final/config.dart';
import 'package:search_choices/search_choices.dart';

import '../apis/contact.dart';
import '../helpers/AppTheme.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../models/contact_model.dart';
import '../models/sell.dart';
import '../models/sellDatabase.dart';
import 'elements.dart';

class Customer extends StatefulWidget {
  const Customer({super.key});

  @override
  _CustomerState createState() => _CustomerState();
}

class _CustomerState extends State<Customer> {
  Map? argument;
  final _formKey = GlobalKey<FormState>();

  String transactionDate = DateFormat(
    "yyyy-MM-dd HH:mm:ss",
  ).format(DateTime.now());
  List<Map<String, dynamic>> customerListMap = [];
  Map<String, dynamic> selectedCustomer = {
    'id': 0,
    'name': 'select customer',
    'mobile': ' - ',
  };
  TextEditingController prefix = TextEditingController(),
      firstName = TextEditingController(),
      middleName = TextEditingController(),
      lastName = TextEditingController(),
      mobile = TextEditingController(),
      addressLine1 = TextEditingController(),
      addressLine2 = TextEditingController(),
      city = TextEditingController(),
      state = TextEditingController(),
      country = TextEditingController(),
      zip = TextEditingController();

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  @override
  void initState() {
    super.initState();
    selectCustomer();
  }

  @override
  void didChangeDependencies() {
    argument = ModalRoute.of(context)!.settings.arguments as Map?;

    if (argument!['customerId'] != null) {
      Future.delayed(Duration(milliseconds: 400), () async {
        await Contact().getCustomerDetailById(argument!['customerId']).then((
          value,
        ) {
          if (mounted) {
            setState(() {
              selectedCustomer = {
                'id': argument!['customerId'],
                'name': value['name'],
                'mobile': value['mobile'],
              };
            });
          }
        });
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).translate('customer'),
          style: AppTheme.getTextStyle(
            themeData.textTheme.titleLarge,
            fontWeight: 600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return newCustomer();
              },
              fullscreenDialog: true,
            ),
          );
        },
        elevation: 2,
        child: Icon(MdiIcons.accountPlus),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: customerList(),
                ),
              ),
            ),
            Center(
              child: Visibility(
                visible: (selectedCustomer['id'] == 0),
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).translate('please_select_a_customer_for_checkout_option'),
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Visibility(
        visible: (selectedCustomer['id'] != 0),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            mainAxisAlignment: (argument!['is_quotation'] == null)
                ? MainAxisAlignment.spaceAround
                : MainAxisAlignment.center,
            children: [
              if (argument!['is_quotation'] == null)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: OutlinedButton.icon(
                      onPressed: addQuotation,
                      icon: Icon(Icons.add),
                      label: Text(
                        AppLocalizations.of(context).translate('add_quotation'),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: cartBottomBar(
                  '/checkout',
                  AppLocalizations.of(context).translate('pay_&_checkout'),
                  context,
                  Helper().argument(
                    locId: argument!['locationId'],
                    taxId: argument!['taxId'],
                    discountType: argument!['discountType'],
                    discountAmount: argument!['discountAmount'],
                    invoiceAmount: argument!['invoiceAmount'],
                    customerId: selectedCustomer['id'],
                    sellId: argument!['sellId'],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //add quotation
  Future<void> addQuotation() async {
    Map sell = await Sell().createSell(
      changeReturn: 0.00,
      transactionDate: transactionDate,
      pending: argument!['invoiceAmount'],
      shippingCharges: 0.00,
      shippingDetails: '',
      invoiceNo:
          "${Config.userId}_${DateFormat('yMdHm').format(DateTime.now())}",
      contactId: selectedCustomer['id'],
      discountAmount: argument!['discountAmount'],
      discountType: argument!['discountType'],
      invoiceAmount: argument!['invoiceAmount'],
      locId: argument!['locationId'],
      saleStatus: 'draft',
      sellId: argument!['sellId'],
      taxId: argument!['taxId'],
      isQuotation: 1,
    );
    confirmDialog(sell);
  }

  //confirmation dialogBox
  void confirmDialog(sell) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: customAppTheme.bgLayer1,
          title: Text(
            AppLocalizations.of(context).translate('quotation'),
            style: AppTheme.getTextStyle(
              themeData.textTheme.titleLarge,
              color: themeData.colorScheme.onSurface,
              fontWeight: 700,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeData.colorScheme.primary,
              ),
              onPressed: () async {
                if (argument!['sellId'] != null) {
                  //update sell
                } else {
                  await SellDatabase().storeSell(sell).then((value) async {
                    SellDatabase().updateSellLine({
                      'sell_id': value,
                      'is_completed': 1,
                    });
                    if (await Helper().checkConnectivity()) {
                      await Sell().createApiSell(sellId: value);
                    }
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/products',
                      ModalRoute.withName('/home'),
                    );
                  });
                }
              },
              child: Text(AppLocalizations.of(context).translate('save')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeData.colorScheme.primary,
              ),
              onPressed: () async {
                await SellDatabase().storeSell(sell).then((value) async {
                  SellDatabase().updateSellLine({
                    'sell_id': value,
                    'is_completed': 1,
                  });
                  if (await Helper().checkConnectivity()) {
                    await Sell().createApiSell(sellId: value);
                  }
                  Helper()
                      .printDocument(value, argument!['taxId'], context)
                      .then((value) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/products',
                          ModalRoute.withName('/home'),
                        );
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(
                            context,
                          ).translate('quotation_added'),
                        );
                      });
                });
              },
              child: Text(
                AppLocalizations.of(context).translate('save_n_print'),
              ),
            ),
          ],
        );
      },
    );
  }

  //show add customer alert box
  Widget newCustomer() {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('create_contact')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: prefix,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          ).translate('prefix'),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: firstName,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return AppLocalizations.of(
                              context,
                            ).translate('please_enter_your_name');
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          ).translate('first_name'),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: middleName,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          ).translate('middle_name'),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: lastName,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          ).translate('last_name'),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: mobile,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.of(
                        context,
                      ).translate('please_enter_mobile_no');
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(
                      context,
                    ).translate('mobile_no'),
                    prefixIcon: Icon(MdiIcons.phoneOutline),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context).translate('address'),
                  style: themeData.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: addressLine1,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(
                      context,
                    ).translate('address_line_1'),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: addressLine2,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(
                      context,
                    ).translate('address_line_2'),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: city,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          ).translate('city'),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: state,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          ).translate('state'),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: country,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          ).translate('country'),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: zip,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          ).translate('zip_code'),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (await Helper().checkConnectivity()) {
                      if (_formKey.currentState!.validate()) {
                        Map newCustomerMap = {
                          'type': 'customer',
                          'prefix': prefix.text,
                          'first_name': firstName.text,
                          'middle_name': middleName.text,
                          'last_name': lastName.text,
                          'mobile': mobile.text,
                          'address_line_1': addressLine1.text,
                          'address_line_2': addressLine2.text,
                          'city': city.text,
                          'state': state.text,
                          'country': country.text,
                          'zip_code': zip.text,
                        };
                        await CustomerApi().add(newCustomerMap).then((value) {
                          if (value['data'] != null) {
                            Contact()
                                .insertContact(
                                  Contact().contactModel(value['data']),
                                )
                                .then((value) {
                                  selectCustomer();
                                  Navigator.pop(context);
                                  _formKey.currentState!.reset();
                                });
                          }
                        });
                      }
                    } else {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(
                          context,
                        ).translate('check_connectivity'),
                      );
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context).translate('add_to_contact'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //dropdown widget for selecting customer
  Widget customerList() {
    return SearchChoices.single(
      underline: Visibility(visible: false, child: Container()),
      displayClearIcon: false,
      value: jsonEncode(selectedCustomer),
      items: customerListMap.map<DropdownMenuItem<String>>((Map value) {
        return DropdownMenuItem<String>(
          value: jsonEncode(value),
          child: Text(
            "${value['name']} (${value['mobile'] ?? ' - '})",
            softWrap: true,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: themeData.textTheme.bodyMedium,
          ),
        );
      }).toList(),
      iconEnabledColor: themeData.colorScheme.primary,
      iconDisabledColor: themeData.disabledColor,
      onChanged: (newValue) {
        setState(() {
          selectedCustomer = jsonDecode(newValue);
        });
      },
      isExpanded: true,
    );
  }

  Future<void> selectCustomer() async {
    customerListMap = [
      {'id': 0, 'name': 'select customer', 'mobile': ' - '},
    ];
    List customers = await Contact().get();

    for (var value in customers) {
      setState(() {
        customerListMap.add({
          'id': value['id'],
          'name': value['name'],
          'mobile': value['mobile'],
        });
      });
      if (value['name'] == 'Walk-In Customer') {
        selectedCustomer = {
          'id': value['id'],
          'name': value['name'],
          'mobile': value['mobile'],
        };
      }
    }
  }
}
