import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../apis/expenses.dart';
import '../helpers/AppTheme.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../models/expenses.dart';
import '../models/system.dart';

class Expense extends StatefulWidget {
  const Expense({super.key});

  @override
  State<Expense> createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> expenseCategories = [];
  final List<Map<String, dynamic>> expenseSubCategories = [];
  List<Map<String, dynamic>> paymentMethods = [];
  List<Map<String, dynamic>> paymentAccounts = [];

  final List<Map<String, dynamic>> locationListMap = [
    {'id': 0, 'name': 'set location'},
  ];
  final List<Map<String, dynamic>> taxListMap = [
    {'id': 0, 'name': 'Tax rate', 'amount': 0},
  ];

  Map<String, dynamic> selectedLocation = {'id': 0, 'name': 'set location'};
  Map<String, dynamic> selectedTax = {'id': 0, 'name': 'Tax rate', 'amount': 0};
  Map<String, dynamic> selectedExpenseCategoryId = {'id': 0, 'name': 'Select'};
  Map<String, dynamic> selectedExpenseSubCategoryId = {
    'id': 0,
    'name': 'Select',
  };
  Map<String, dynamic> selectedPaymentAccount = {'id': null, 'name': 'None'};
  Map<String, dynamic> selectedPaymentMethod = {
    'name': 'name',
    'value': 'value',
    'account_id': null,
  };

  final TextEditingController expenseAmount = TextEditingController();
  final TextEditingController expenseNote = TextEditingController();
  final TextEditingController payingAmount = TextEditingController();

  bool _isSubmitting = false;
  String symbol = '';

  static const int themeType = 1;
  final ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);

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
    _initializeScreenData();
    Helper().syncCallLogs();
  }

  Future<void> _initializeScreenData() async {
    await Future.wait<dynamic>([
      setLocationMap(),
      setTaxMap(),
      setPaymentDetails(selectedLocation['id'] as int),
    ]);
  }

  @override
  void dispose() {
    expenseAmount.dispose();
    expenseNote.dispose();
    payingAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        title: Text(
          AppLocalizations.of(context).translate('expenses'),
          style: AppTheme.getTextStyle(
            themeData.textTheme.titleLarge,
            color: _primaryText,
            fontWeight: 600,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[_bgSoft, _bg],
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: _formKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 28,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(
                            context,
                          ).translate('please_enter_expense_amount'),
                          style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyMedium,
                            color: _mutedText,
                            fontWeight: 400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          label: AppLocalizations.of(
                            context,
                          ).translate('location'),
                          value: selectedLocation['name'] as String,
                          items: locationListMap,
                          onSelected: _onLocationSelected,
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField(
                          label: AppLocalizations.of(context).translate('tax'),
                          value: selectedTax['name'] as String,
                          items: taxListMap,
                          onSelected: (Map<String, dynamic> item) {
                            setState(() => selectedTax = item);
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField(
                          label: AppLocalizations.of(
                            context,
                          ).translate('expense_categories'),
                          value: selectedExpenseCategoryId['name'] as String,
                          items: expenseCategories,
                          onSelected: _onCategorySelected,
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField(
                          label: AppLocalizations.of(
                            context,
                          ).translate('sub_categories'),
                          value: selectedExpenseSubCategoryId['name'] as String,
                          items: expenseSubCategories,
                          onSelected: (Map<String, dynamic> item) {
                            setState(() => selectedExpenseSubCategoryId = item);
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: expenseAmount,
                          label: AppLocalizations.of(
                            context,
                          ).translate('expense_amount'),
                          prefixText: symbol,
                          validator: (String? value) {
                            if ((value ?? '').trim().isEmpty) {
                              return AppLocalizations.of(
                                context,
                              ).translate('please_enter_expense_amount');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: expenseNote,
                          label: AppLocalizations.of(
                            context,
                          ).translate('expense_note'),
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: payingAmount,
                          label: AppLocalizations.of(
                            context,
                          ).translate('payment_amount'),
                          prefixText: symbol,
                          validator: _validatePaymentAmount,
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField(
                          label: AppLocalizations.of(
                            context,
                          ).translate('payment_method'),
                          value: selectedPaymentMethod['value'] as String,
                          items: paymentMethods,
                          itemLabelKey: 'value',
                          onSelected: _onPaymentMethodSelected,
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField(
                          label: AppLocalizations.of(
                            context,
                          ).translate('payment_account'),
                          value: selectedPaymentAccount['name'] as String,
                          items: paymentAccounts,
                          onSelected: (Map<String, dynamic> item) {
                            setState(() {
                              selectedPaymentAccount = item;
                              selectedPaymentMethod['account_id'] = item['id'];
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(
                                      context,
                                    ).translate('submit'),
                                    style: AppTheme.getTextStyle(
                                      themeData.textTheme.titleMedium,
                                      color: Colors.white,
                                      fontWeight: 500,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String prefixText = '',
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textAlign: keyboardType == TextInputType.number
          ? TextAlign.end
          : TextAlign.start,
      inputFormatters: keyboardType == TextInputType.number
          ? <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ]
          : null,
      style: AppTheme.getTextStyle(
        themeData.textTheme.bodyLarge,
        color: _primaryText,
        fontWeight: 400,
      ),
      decoration: InputDecoration(
        prefixText: prefixText.isEmpty ? null : '$prefixText ',
        labelText: label,
        labelStyle: AppTheme.getTextStyle(
          themeData.textTheme.bodyMedium,
          color: _mutedText,
          fontWeight: 400,
        ),
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<Map<String, dynamic>> items,
    required void Function(Map<String, dynamic>) onSelected,
    String itemLabelKey = 'name',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AppTheme.getTextStyle(
            themeData.textTheme.bodyMedium,
            color: _mutedText,
            fontWeight: 400,
          ),
        ),
        const SizedBox(height: 8),
        PopupMenuButton<Map<String, dynamic>>(
          onSelected: onSelected,
          itemBuilder: (BuildContext context) {
            return items.map((Map<String, dynamic> item) {
              final String itemText = (item[itemLabelKey] ?? '').toString();
              return PopupMenuItem<Map<String, dynamic>>(
                value: item,
                child: Text(
                  itemText,
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyMedium,
                    color: _primaryText,
                    fontWeight: 400,
                  ),
                ),
              );
            }).toList();
          },
          color: _surface,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _outline),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.getTextStyle(
                      themeData.textTheme.bodyLarge,
                      color: _primaryText,
                      fontWeight: 400,
                    ),
                  ),
                ),
                Icon(MdiIcons.chevronDown, color: _mutedText, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final bool hasConnectivity = await Helper().checkConnectivity();
    if (!hasConnectivity) {
      _showMessage(
        AppLocalizations.of(context).translate('check_connectivity'),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    await onSubmit();
  }

  String? _validatePaymentAmount(String? value) {
    final double paid = double.tryParse((value ?? '0').trim()) ?? 0;
    final double total = double.tryParse(expenseAmount.text.trim()) ?? 0;
    if (paid > total) {
      return AppLocalizations.of(
        context,
      ).translate('enter_valid_payment_amount');
    }
    return null;
  }

  Future<void> setLocationMap() async {
    locationListMap.clear();
    final List locations = await System().get('location');
    for (final dynamic element in locations) {
      locationListMap.add({'id': element['id'], 'name': element['name']});
    }

    if (mounted) {
      setState(() {
        if (locationListMap.isNotEmpty && selectedLocation['id'] == 0) {
          selectedLocation = locationListMap.first;
        }
      });
    }

    await setExpenseCategories();
    await setPaymentDetails(selectedLocation['id'] as int);
  }

  Future<void> setTaxMap() async {
    final List taxes = await System().get('tax');
    taxListMap.removeWhere((Map<String, dynamic> item) => item['id'] != 0);
    for (final dynamic element in taxes) {
      taxListMap.add({
        'id': element['id'],
        'name': element['name'],
        'amount': element['amount'],
      });
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> setExpenseCategories() async {
    expenseCategories.clear();
    expenseSubCategories.clear();

    final List data = await ExpenseApi().get();
    for (final dynamic element in data) {
      expenseCategories.add({
        'id': element['id'],
        'name': element['name'],
        'sub_categories': element['sub_categories'],
      });
    }

    if (mounted) {
      setState(() {
        selectedExpenseCategoryId = {'id': 0, 'name': 'Select'};
        selectedExpenseSubCategoryId = {'id': 0, 'name': 'Select'};
      });
    }
  }

  Future<void> setPaymentDetails(int locId) async {
    final Map<String, dynamic> businessDetails = await Helper()
        .getFormattedBusinessDetails();
    final List<dynamic> payments = await System().get('payment_method', locId);
    final List<dynamic> accounts = await System().getPaymentAccounts();

    final List<Map<String, dynamic>> methods = <Map<String, dynamic>>[];
    for (final dynamic element in payments) {
      methods.add({
        'name': element['name'],
        'value': element['label'],
        'account_id': element['account_id'] == null
            ? null
            : int.parse(element['account_id'].toString()),
      });
    }

    final List<Map<String, dynamic>> accountsForLocation =
        <Map<String, dynamic>>[
          {'id': null, 'name': 'None'},
        ];

    final Set<String> accountIds = <String>{};
    for (final dynamic account in accounts) {
      for (final dynamic payment in payments) {
        final String? paymentAccountId = payment['account_id']?.toString();
        if (paymentAccountId != null &&
            paymentAccountId == account['id'].toString() &&
            !accountIds.contains(account['id'].toString())) {
          accountIds.add(account['id'].toString());
          accountsForLocation.add({
            'id': account['id'],
            'name': account['name'],
          });
        }
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      symbol = (businessDetails['symbol'] ?? '').toString();
      paymentMethods = methods;
      paymentAccounts = accountsForLocation;

      if (paymentMethods.isNotEmpty) {
        selectedPaymentMethod = paymentMethods.first;
      }

      selectedPaymentAccount = paymentAccounts.first;
      for (final Map<String, dynamic> account in paymentAccounts) {
        if (selectedPaymentMethod['account_id'] == account['id']) {
          selectedPaymentAccount = account;
          break;
        }
      }
    });
  }

  Future<void> _onLocationSelected(Map<String, dynamic> item) async {
    setState(() {
      selectedLocation = item;
    });
    await setExpenseCategories();
    await setPaymentDetails(selectedLocation['id'] as int);
  }

  void _onCategorySelected(Map<String, dynamic> item) {
    final List<Map<String, dynamic>> subCategoryItems =
        <Map<String, dynamic>>[];
    if (item['sub_categories'] is List) {
      for (final dynamic element in item['sub_categories']) {
        subCategoryItems.add({'id': element['id'], 'name': element['name']});
      }
    }

    setState(() {
      selectedExpenseCategoryId = item;
      expenseSubCategories
        ..clear()
        ..addAll(subCategoryItems);
      selectedExpenseSubCategoryId = {'id': 0, 'name': 'Select'};
    });
  }

  void _onPaymentMethodSelected(Map<String, dynamic> item) {
    setState(() {
      selectedPaymentMethod = item;
      selectedPaymentAccount = paymentAccounts.first;
      for (final Map<String, dynamic> account in paymentAccounts) {
        if (selectedPaymentMethod['account_id'] == account['id']) {
          selectedPaymentAccount = account;
          break;
        }
      }
    });
  }

  Future<void> onSubmit() async {
    if (selectedLocation['id'] == 0) {
      _showMessage(
        AppLocalizations.of(context).translate('error_invalid_location'),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final double finalTotal =
          double.tryParse(
            expenseAmount.text.trim().isEmpty ? '0' : expenseAmount.text.trim(),
          ) ??
          0;
      final double amount =
          double.tryParse(
            payingAmount.text.trim().isEmpty ? '0' : payingAmount.text.trim(),
          ) ??
          0;

      final Map<String, dynamic> expenseMap = ExpenseManagement().createExpense(
        locId: selectedLocation['id'] as int,
        finalTotal: finalTotal,
        amount: amount,
        method: selectedPaymentMethod['name'] as String,
        accountId: selectedPaymentAccount['id'],
        expenseCategoryId: selectedExpenseCategoryId['id'] as int,
        expenseSubCategoryId: selectedExpenseSubCategoryId['id'] as int,
        taxId: selectedTax['id'] != 0 ? selectedTax['id'] as int : null,
        note: expenseNote.text,
      );

      await ExpenseApi().create(expenseMap);
      if (!mounted) {
        return;
      }

      Navigator.pop(context);
      _showMessage(
        AppLocalizations.of(context).translate('expense_added_successfully'),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
