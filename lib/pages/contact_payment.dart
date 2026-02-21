import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:search_choices/search_choices.dart';

import '../apis/contact_payment.dart';
import '../helpers/AppTheme.dart';
import '../helpers/SizeConfig.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../models/contact_model.dart';
import '../models/system.dart';

class ContactPayment extends StatefulWidget {
  const ContactPayment({super.key});

  @override
  _ContactPaymentState createState() => _ContactPaymentState();
}

class _ContactPaymentState extends State<ContactPayment> {
  final _formKey = GlobalKey<FormState>();
  int selectedCustomerId = 0;
  bool _isSubmitting = false;
  bool _isFetchingDue = false;

  List<Map<String, dynamic>> customerListMap = [],
      paymentAccounts = [],
      paymentMethods = [],
      locationListMap = [];

  Map<String, dynamic> selectedLocation = {'id': 0, 'name': 'set location'},
      selectedCustomer = {'id': 0, 'name': 'select customer', 'mobile': ' - '};

  String due = '0.00';
  Map<String, dynamic> selectedPaymentAccount = {'id': null, 'name': "None"},
      selectedPaymentMethod = {
        'name': 'name',
        'value': 'value',
        'account_id': null,
      };

  String symbol = '';
  var payingAmount = TextEditingController();

  // Core Tokens from STYLE_MD.md
  static const Color _bgColor = Color(0xFFF8FAFC);
  static const Color _surfaceColor = Color(0xFFFFFFFF);
  static const Color _primaryTextColor = Color(0xFF0F172A);
  static const Color _mutedTextColor = Color(0xFF6B7280);
  static const Color _accentColor = Color(0xFF0F4C81);
  static const Color _outlineColor = Color(0xFFE5E7EB);

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  @override
  void initState() {
    super.initState();
    selectCustomer();
    setPaymentDetails();
    setLocationMap();
    Helper().syncCallLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(MdiIcons.chevronLeft, color: _primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).translate('contact_payment'),
          style: AppTheme.getTextStyle(
            themeData.textTheme.titleLarge,
            fontWeight: 600,
            color: _primaryTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: Spacing.symmetric(horizontal: 20, vertical: 16),
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionCard(
                    child: Column(
                      children: [
                        _buildCustomerSelector(),
                        if (selectedCustomerId != 0) ...[
                          Padding(
                            padding: Spacing.vertical(24),
                            child: _buildDueSection(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (selectedCustomerId != 0) ...[
                    SizedBox(height: 16),
                    _buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAmountInput(),
                          SizedBox(height: 20),
                          _buildLabel(
                            AppLocalizations.of(context).translate('location'),
                          ),
                          _buildLocationSelector(),
                          SizedBox(height: 16),
                          _buildLabel(
                            AppLocalizations.of(
                              context,
                            ).translate('payment_method'),
                          ),
                          _buildPaymentMethodSelector(),
                          SizedBox(height: 16),
                          _buildLabel(
                            AppLocalizations.of(
                              context,
                            ).translate('payment_account'),
                          ),
                          _buildPaymentAccountSelector(),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 32),
                  _buildSubmitButton(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: Spacing.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: Spacing.only(bottom: 8),
      child: Text(
        text,
        style: AppTheme.getTextStyle(
          themeData.textTheme.bodySmall,
          fontWeight: 600,
          color: _mutedTextColor,
        ),
      ),
    );
  }

  Widget _buildCustomerSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(AppLocalizations.of(context).translate('select_customer')),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _outlineColor),
          ),
          padding: Spacing.horizontal(12),
          child: SearchChoices.single(
            underline: SizedBox.shrink(),
            displayClearIcon: false,
            value: jsonEncode(selectedCustomer),
            items: customerListMap.map<DropdownMenuItem<String>>((Map value) {
              return DropdownMenuItem<String>(
                value: jsonEncode(value),
                child: Text(
                  "${value['name']} (${value['mobile'] ?? ' - '})",
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyMedium,
                    color: _primaryTextColor,
                  ),
                ),
              );
            }).toList(),
            icon: Icon(MdiIcons.chevronDown, color: _mutedTextColor),
            onChanged: (value) async {
              if (value == null) return;
              setState(() {
                selectedCustomer = jsonDecode(value);
              });
              var newValue = selectedCustomer['id'];
              if (newValue != 0) {
                _onCustomerChanged(newValue);
              }
            },
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  void _onCustomerChanged(int customerId) async {
    if (await Helper().checkConnectivity()) {
      setState(() => _isFetchingDue = true);
      try {
        var value = await ContactPaymentApi().getCustomerDue(customerId);
        if (value != null) {
          due = value['data'][0]['sell_due'].toString();
          setState(() {
            selectedCustomerId = customerId;
            _formKey.currentState!.reset();
          });
        }
      } finally {
        setState(() => _isFetchingDue = false);
      }
    } else {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('check_connectivity'),
      );
    }
  }

  Widget _buildDueSection() {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context).translate('due').toUpperCase(),
          style: AppTheme.getTextStyle(
            themeData.textTheme.bodySmall,
            fontWeight: 600,
            letterSpacing: 1.2,
            color: _mutedTextColor,
          ),
        ),
        SizedBox(height: 4),
        if (_isFetchingDue)
          SizedBox(
            height: 32,
            width: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _accentColor,
            ),
          )
        else
          Text(
            Helper().formatCurrency(due),
            style: AppTheme.getTextStyle(
              themeData.textTheme.headlineSmall,
              fontWeight: 600,
              color: _primaryTextColor,
            ),
          ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return TextFormField(
      controller: payingAmount,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: AppTheme.getTextStyle(
        themeData.textTheme.titleMedium,
        fontWeight: 500,
        color: _primaryTextColor,
      ),
      decoration: InputDecoration(
        prefixIcon: Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            symbol,
            style: AppTheme.getTextStyle(
              themeData.textTheme.titleMedium,
              fontWeight: 600,
              color: _accentColor,
            ),
          ),
        ),
        labelText: AppLocalizations.of(context).translate('payment_amount'),
        labelStyle: TextStyle(color: _mutedTextColor),
        hintText: '0.00',
        contentPadding: Spacing.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _accentColor, width: 2),
        ),
      ),
      validator: (newValue) {
        if (newValue == null || newValue.isEmpty) {
          return AppLocalizations.of(
            context,
          ).translate('enter_valid_payment_amount');
        }
        double? val = double.tryParse(newValue);
        if (val == null || val < 0.01) {
          return AppLocalizations.of(
            context,
          ).translate('enter_valid_payment_amount');
        }
        if (val > double.parse(due)) {
          return AppLocalizations.of(context).translate('amount_exceeds_due');
        }
        return null;
      },
    );
  }

  Widget _buildLocationSelector() {
    return _buildDropdownTrigger(
      value: selectedLocation['name'],
      onTap: () => _showLocationPopup(),
    );
  }

  void _showLocationPopup() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: Spacing.vertical(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: locationListMap.map((loc) {
              return ListTile(
                title: Text(loc['name']),
                onTap: () {
                  setState(() {
                    selectedLocation = loc;
                    _updatePaymentOptions();
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodSelector() {
    return _buildDropdownTrigger(
      value: selectedPaymentMethod['value'],
      onTap: () => _showPaymentMethodPopup(),
    );
  }

  void _showPaymentMethodPopup() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: Spacing.vertical(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: paymentMethods.map((method) {
              return ListTile(
                title: Text(method['value']),
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = method;
                    _matchPaymentAccount();
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPaymentAccountSelector() {
    return _buildDropdownTrigger(
      value: selectedPaymentAccount['name'],
      onTap: () => _showPaymentAccountPopup(),
    );
  }

  void _showPaymentAccountPopup() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: Spacing.vertical(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: paymentAccounts.map((acc) {
              return ListTile(
                title: Text(acc['name']),
                onTap: () {
                  setState(() {
                    selectedPaymentAccount = acc;
                    selectedPaymentMethod['account_id'] = acc['id'];
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDropdownTrigger({
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: Spacing.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _outlineColor),
          color: _bgColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyLarge,
                  color: _primaryTextColor,
                ),
              ),
            ),
            Icon(MdiIcons.chevronDown, color: _mutedTextColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        onPressed: _isSubmitting ? null : () => onSubmit(),
        child: _isSubmitting
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                AppLocalizations.of(context).translate('submit'),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.titleMedium,
                  color: Colors.white,
                  fontWeight: 600,
                ),
              ),
      ),
    );
  }

  void _updatePaymentOptions() async {
    await setPaymentDetails();
    if (paymentMethods.isNotEmpty) {
      selectedPaymentMethod = paymentMethods[0];
      _matchPaymentAccount();
    }
  }

  void _matchPaymentAccount() {
    selectedPaymentAccount = paymentAccounts[0];
    for (var acc in paymentAccounts) {
      if (selectedPaymentMethod['account_id'] == acc['id']) {
        selectedPaymentAccount = acc;
        break;
      }
    }
  }

  Future<void> onSubmit() async {
    if (await Helper().checkConnectivity()) {
      if (_formKey.currentState!.validate()) {
        if (selectedLocation['id'] != 0) {
          setState(() => _isSubmitting = true);
          try {
            Map<String, dynamic> paymentMap = {
              "contact_id": selectedCustomerId,
              "amount": double.parse(payingAmount.text),
              "method": selectedPaymentMethod['name'],
              "account_id": selectedPaymentMethod['account_id'],
              "paid_on": DateFormat(
                "yyyy-MM-dd hh:mm:ss",
              ).format(DateTime.now()),
            };
            await ContactPaymentApi().postContactPayment(paymentMap);
            Fluttertoast.showToast(
              backgroundColor: Colors.green,
              msg: AppLocalizations.of(context).translate('payment_successful'),
            );
            Navigator.popUntil(context, ModalRoute.withName('/layout'));
            Navigator.pushNamed(context, '/layout');
          } catch (e) {
            Fluttertoast.showToast(msg: e.toString());
          } finally {
            setState(() => _isSubmitting = false);
          }
        } else {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(
              context,
            ).translate('error_invalid_location'),
          );
        }
      }
    } else {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('check_connectivity'),
      );
    }
  }

  Future<void> selectCustomer() async {
    customerListMap = [
      {'id': 0, 'name': 'select customer', 'mobile': ' - '},
    ];
    var contacts = await Contact().get();
    for (var element in contacts) {
      setState(() {
        customerListMap.add({
          'id': element['id'],
          'name': element['name'],
          'mobile': element['mobile'],
        });
      });
    }
  }

  Future<void> setLocationMap() async {
    locationListMap = [];
    var locations = await System().get('location');
    for (var element in locations) {
      setState(() {
        locationListMap.add({'id': element['id'], 'name': element['name']});
      });
    }
    if (locationListMap.isNotEmpty && selectedLocation['id'] == 0) {
      // Optional: set first location as default if none selected
    }
  }

  Future setPaymentDetails() async {
    var details = await Helper().getFormattedBusinessDetails();
    setState(() {
      symbol = details['symbol'];
    });

    List payments = await System().get(
      'payment_method',
      selectedLocation['id'],
    );
    paymentAccounts = [
      {'id': null, 'name': "None"},
    ];

    var accs = await System().getPaymentAccounts();
    List<String> accIds = [];
    for (var element in accs) {
      for (var payment in payments) {
        if ((payment['account_id'].toString() == element['id'].toString()) &&
            !accIds.contains(element['id'].toString())) {
          accIds.add(element['id'].toString());
          paymentAccounts.add({'id': element['id'], 'name': element['name']});
        }
      }
    }

    paymentMethods = [];
    for (var element in payments) {
      setState(() {
        paymentMethods.add({
          'name': element['name'],
          'value': element['label'],
          'account_id': (element['account_id'] != null)
              ? int.parse(element['account_id'].toString())
              : null,
        });
      });
    }
  }
}
