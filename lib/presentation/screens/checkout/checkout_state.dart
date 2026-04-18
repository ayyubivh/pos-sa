part of 'package:pos_final/presentation/screens/checkout_screen.dart';

class CheckOutState extends State<CheckOut> {
  List<Map> paymentMethods = [];
  int? sellId;
  double totalPaying = 0.0;
  String symbol = '',
      invoiceType = "Mobile",
      transactionDate = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now());
  Map? argument;
  List<Map> payments = [],
      paymentAccounts = [
        {'id': null, 'name': "None"},
      ];
  List<int> deletedPaymentId = [];
  late Map<String, dynamic> paymentLine;
  List sellDetail = [];
  double invoiceAmount = 0.00, pendingAmount = 0.00, changeReturn = 0.00;
  TextEditingController dateController = TextEditingController(),
      saleNote = TextEditingController(),
      staffNote = TextEditingController(),
      shippingDetails = TextEditingController(),
      shippingCharges = TextEditingController();
  bool _printInvoice = true,
      printWebInvoice = false,
      saleCreated = false,
      isLoading = false;
  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  @override
  void initState() {
    super.initState();
    getInitDetails();
  }

  Future<void> getInitDetails() async {
    setState(() {
      isLoading = true;
    });
    await Helper().getFormattedBusinessDetails().then((value) {
      symbol = value['symbol'];
    });
  }

  Future<void> setPaymentAccounts() async {
    List payments = await System().get(
      'payment_method',
      argument!['locationId'],
    );
    await System().getPaymentAccounts().then((value) {
      for (var element in value) {
        List<String> accIds = [];
        //check if payment account is assigned to any payment method
        // of selected location.
        for (var paymentMethod in payments) {
          if ((paymentMethod['account_id'].toString() ==
                  element['id'].toString()) &&
              !accIds.contains(element['id'].toString())) {
            setState(() {
              paymentAccounts.add({
                'id': element['id'],
                'name': element['name'],
              });
            });
          }
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    argument = ModalRoute.of(context)!.settings.arguments as Map?;
    invoiceAmount = argument!['invoiceAmount'];
    _initCheckout();
    super.didChangeDependencies();
  }

  Future<void> _initCheckout() async {
    await setPaymentAccounts();
    await setPaymentDetails();
    if (argument!['sellId'] == null) {
      payments.add({
        'amount': invoiceAmount,
        'method': paymentMethods[0]['name'],
        'note': '',
        'account_id': paymentMethods[0]['account_id'],
      });
      calculateMultiPayment();
    } else {
      await onEdit(argument!['sellId']);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    staffNote.dispose();
    saleNote.dispose();
    super.dispose();
  }

  Future<void> onEdit(sellId) async {
    sellDetail = await SellDatabase().getSellBySellId(sellId);
    this.sellId = argument!['sellId'];
    await SellDatabase().getSellBySellId(sellId).then((value) {
      shippingCharges.text = value[0]['shipping_charges'].toString();
      shippingDetails.text = value[0]['shipping_details'] ?? '';
      saleNote.text = value[0]['sale_note'] ?? '';
      staffNote.text = value[0]['staff_note'] ?? '';
      invoiceAmount =
          argument!['invoiceAmount'] + double.parse(shippingCharges.text);
    });
    payments = [];
    List paymentLines = await PaymentDatabase().get(sellId, allColumns: true);
    for (var element in paymentLines) {
      if (element['is_return'] == 0) {
        payments.add({
          'id': element['id'],
          'amount': element['amount'],
          'method': element['method'],
          'note': element['note'],
          'account_id': element['account_id'],
        });
      }
    }
    calculateMultiPayment();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).translate('checkout'),
          style: AppTheme.getTextStyle(
            themeData.textTheme.titleLarge,
            fontWeight: 600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: (isLoading) ? Helper().loadingIndicator(context) : paymentBox(),
      ),
    );
  }

  //payment widget
  Widget paymentBox() {
    return Container(
      margin: EdgeInsets.all(MySize.size3!),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: MySize.size16!,
              vertical: MySize.size8!,
            ),
            child: SimpleDateTimePicker(
              initialValue: transactionDate,
              type: DateTimePickerType.dateTime,
              firstDate: DateTime.now()
                  .subtract(Duration(days: 366))
                  .toIso8601String(),
              lastDate: DateTime.now().toIso8601String(),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('date'),
                prefixIcon: Icon(MdiIcons.calendarExportOutline, size: 20),
                isDense: true,
                filled: true,
                fillColor: themeData.colorScheme.onSurface.withOpacity(0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MySize.size12!),
                  borderSide: BorderSide.none,
                ),
                labelStyle: TextStyle(
                  color: themeData.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  transactionDate = val;
                });
              },
            ),
          ),
          ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: payments.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: MySize.size16!,
                  vertical: MySize.size8!,
                ),
                decoration: BoxDecoration(
                  color: customAppTheme.bgLayer1,
                  borderRadius: BorderRadius.circular(MySize.size16!),
                  border: Border.all(color: kOutlineColor, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(MySize.size16!),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  context,
                                ).translate('amount'),
                                suffixText: symbol,
                                isDense: true,
                                filled: true,
                                fillColor: themeData.colorScheme.onSurface
                                    .withOpacity(0.03),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    MySize.size10!,
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(fontWeight: FontWeight.w700),
                              textAlign: TextAlign.end,
                              initialValue: payments[index]['amount']
                                  .toStringAsFixed(2),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^(\d+)?\.?\d{0,2}'),
                                ),
                              ],
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                payments[index]['amount'] = Helper()
                                    .validateInput(value);
                                calculateMultiPayment();
                              },
                            ),
                          ),
                          if (index > 0)
                            IconButton(
                              onPressed: () => alertConfirm(context, index),
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red[400],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: MySize.size16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('payment_method'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: themeData.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    isExpanded: true,
                                    dropdownColor: customAppTheme.bgLayer1,
                                    value: payments[index]['method'],
                                    items: paymentMethods
                                        .map<DropdownMenuItem<String>>((
                                          Map value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value['name'],
                                            child: Text(
                                              value['value'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),
                                    onChanged: (newValue) {
                                      for (var element in paymentMethods) {
                                        if (element['name'] == newValue) {
                                          setState(() {
                                            payments[index]['method'] =
                                                newValue;
                                            payments[index]['account_id'] =
                                                element['account_id'];
                                          });
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: MySize.size16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('payment_account'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: themeData.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    isExpanded: true,
                                    dropdownColor: customAppTheme.bgLayer1,
                                    value: payments[index]['account_id'],
                                    items: paymentAccounts
                                        .map<DropdownMenuItem<int>>((
                                          Map value,
                                        ) {
                                          return DropdownMenuItem<int>(
                                            value: value['id'],
                                            child: Text(
                                              value['name'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        payments[index]['account_id'] =
                                            newValue;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MySize.size12),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          ).translate('payment_note'),
                          isDense: true,
                          filled: true,
                          fillColor: themeData.colorScheme.onSurface
                              .withOpacity(0.03),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(MySize.size8!),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          payments[index]['note'] = value;
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: MySize.size16!),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: MySize.size12!),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: MySize.size24!,
                        vertical: MySize.size12!,
                      ),
                      side: BorderSide(color: themeData.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MySize.size12!),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        payments.add({
                          'amount': pendingAmount,
                          'method': paymentMethods[0]['name'],
                          'note': '',
                          'account_id': paymentMethods[0]['account_id'],
                        });
                        calculateMultiPayment();
                      });
                    },
                    icon: Icon(Icons.add_circle_outline, size: 20),
                    label: Text(
                      AppLocalizations.of(context).translate('add_payment'),
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: MySize.size8!),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: shippingCharges,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            ).translate('shipping_charges'),
                            suffixText: symbol,
                            isDense: true,
                            filled: true,
                            fillColor: themeData.colorScheme.onSurface
                                .withOpacity(0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                MySize.size10!,
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          textAlign: TextAlign.end,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^(\d+)?\.?\d{0,2}'),
                            ),
                          ],
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            invoiceAmount =
                                argument!['invoiceAmount'] +
                                Helper().validateInput(value);
                            calculateMultiPayment();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  controller: shippingDetails,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(
                      context,
                    ).translate('shipping_details'),
                    isDense: true,
                    filled: true,
                    fillColor: themeData.colorScheme.onSurface.withOpacity(
                      0.04,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(MySize.size10!),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: MySize.size24),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: MySize.size12!,
                  crossAxisSpacing: MySize.size12!,
                  childAspectRatio: 2.5,
                  children: <Widget>[
                    block(
                      amount: Helper().formatCurrency(invoiceAmount),
                      subject: AppLocalizations.of(
                        context,
                      ).translate('total_payble'),
                      backgroundColor: Color(0xFF2563EB),
                      textColor: Colors.white,
                    ),
                    block(
                      amount: Helper().formatCurrency(totalPaying),
                      subject: AppLocalizations.of(
                        context,
                      ).translate('total_paying'),
                      backgroundColor: Color(0xFF4F46E5),
                      textColor: Colors.white,
                    ),
                    block(
                      amount: Helper().formatCurrency(changeReturn),
                      subject: AppLocalizations.of(
                        context,
                      ).translate('change_return'),
                      backgroundColor: Color(0xFF059669),
                      textColor: Colors.white,
                    ),
                    block(
                      amount: Helper().formatCurrency(pendingAmount),
                      subject: AppLocalizations.of(
                        context,
                      ).translate('balance'),
                      backgroundColor: (pendingAmount >= 0.01)
                          ? Color(0xFFDC2626)
                          : Color(0xFFD97706),
                      textColor: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: MySize.size24),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: saleNote,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          ).translate('sell_note'),
                          isDense: true,
                          filled: true,
                          fillColor: themeData.colorScheme.onSurface
                              .withOpacity(0.04),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(MySize.size10!),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(width: MySize.size12),
                    Expanded(
                      child: TextFormField(
                        controller: staffNote,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          ).translate('staff_note'),
                          isDense: true,
                          filled: true,
                          fillColor: themeData.colorScheme.onSurface
                              .withOpacity(0.04),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(MySize.size10!),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MySize.size16),
                Container(
                  padding: EdgeInsets.symmetric(vertical: MySize.size8!),
                  decoration: BoxDecoration(
                    color: themeData.colorScheme.onSurface.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(MySize.size12!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            ).translate('mobile_layout'),
                          ),
                          value: "Mobile",
                          groupValue: invoiceType,
                          onChanged: (value) => setState(() {
                            invoiceType = value.toString();
                            printWebInvoice = false;
                          }),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            ).translate('web_layout'),
                          ),
                          value: "Web",
                          groupValue: invoiceType,
                          onChanged: (value) async {
                            if (await Helper().checkConnectivity()) {
                              setState(() {
                                invoiceType = value.toString();
                                printWebInvoice = true;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MySize.size24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customAppTheme.bgLayer1,
                          foregroundColor: themeData.colorScheme.primary,
                          padding: EdgeInsets.symmetric(
                            vertical: MySize.size16!,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(MySize.size12!),
                            side: BorderSide(
                              color: themeData.colorScheme.primary,
                            ),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          _printInvoice = false;
                          if (pendingAmount >= 0.01) {
                            alertPending(context);
                          } else if (!saleCreated)
                            onSubmit();
                        },
                        child: Text(
                          AppLocalizations.of(
                            context,
                          ).translate('finalize_n_share'),
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    SizedBox(width: MySize.size12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeData.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: MySize.size16!,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(MySize.size12!),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          _printInvoice = true;
                          if (pendingAmount >= 0.01) {
                            alertPending(context);
                          } else if (!saleCreated)
                            onSubmit();
                        },
                        child: Text(
                          AppLocalizations.of(
                            context,
                          ).translate('finalize_n_print'),
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MySize.size32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget block({
    required Color backgroundColor,
    required String subject,
    required dynamic amount,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(MySize.size14!),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withAlpha(50),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: MySize.size14!,
        vertical: MySize.size10!,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            subject,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withAlpha(200),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "$amount $symbol",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //calculate multiple payment
  void calculateMultiPayment() {
    totalPaying = 0.0;
    for (var element in payments) {
      totalPaying += element['amount'];
    }
    if (totalPaying > invoiceAmount) {
      changeReturn = totalPaying - invoiceAmount;
      pendingAmount = 0.0;
    } else if (invoiceAmount > totalPaying) {
      pendingAmount = invoiceAmount - totalPaying;
      changeReturn = 0.0;
    } else {
      pendingAmount = 0.0;
      changeReturn = 0.0;
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> setPaymentDetails() async {
    List payments = await System().get(
      'payment_method',
      argument!['locationId'],
    );
    for (var element in payments) {
      if (mounted) {
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

  //on submit
  Future<void> onSubmit() async {
    setState(() {
      isLoading = true;
      saleCreated = true;
    });
    //value for sell table

    //TODO: remove change return from here and add it to payments
    Map<String, dynamic> sell = await Sell().createSell(
      invoiceNo:
          "${Config.userId}_${DateFormat('yMdHm').format(DateTime.now())}",
      transactionDate: transactionDate,
      changeReturn: changeReturn,
      contactId: argument!['customerId'],
      discountAmount: argument!['discountAmount'],
      discountType: argument!['discountType'],
      invoiceAmount: invoiceAmount,
      locId: argument!['locationId'],
      pending: pendingAmount,
      saleNote: saleNote.text,
      saleStatus: 'final',
      sellId: sellId,
      shippingCharges: (shippingCharges.text != '')
          ? double.parse(shippingCharges.text)
          : 0.00,
      shippingDetails: shippingDetails.text,
      staffNote: staffNote.text,
      taxId: argument!['taxId'],
      isQuotation: 0,
    );

    int? response;
    if (sellId != null) {
      //update sell
      response = sellId;
      await SellDatabase().updateSells(sellId, sell);
      //create payment line
      for (var element in payments) {
        if (element['id'] != null) {
          paymentLine = {
            'amount': element['amount'],
            'method': element['method'],
            'note': element['note'],
            'account_id': element['account_id'],
          };
          await PaymentDatabase().updateEditedPaymentLine(
            element['id'],
            paymentLine,
          );
        } else {
          paymentLine = {
            'sell_id': sellId,
            'method': element['method'],
            'amount': element['amount'],
            'note': element['note'],
            'account_id': element['account_id'],
          };
          await PaymentDatabase().store(paymentLine);
        }
      }
      if (deletedPaymentId.isNotEmpty) {
        await PaymentDatabase().deletePaymentLineByIds(deletedPaymentId);
      }
      //check internet connection and create api sell
      if (await Helper().checkConnectivity()) {
        await Sell().createApiSell(sellId: sellId);
      }
    } else {
      //save sell in database
      response = await SellDatabase().storeSell(sell);
      //save payments in sell_payments
      await Sell().makePayment(payments, response);
      await SellDatabase().updateSellLine({
        'sell_id': response,
        'is_completed': 1,
      });
      if (await Helper().checkConnectivity()) {
        await Sell().createApiSell(sellId: response);
      }
    }
    //print option
    await printOption(response);
  }

  //print option
  Future<void> printOption(sellId) async {
    try {
      List sellDetail = await SellDatabase().getSellBySellId(sellId);
      String? invoice = sellDetail[0]['invoice_url'];
      String invoiceNo = sellDetail[0]['invoice_no'];

      String? webInvoiceHtml;
      if (printWebInvoice && invoice != null) {
        try {
          final response = await http.Client().get(Uri.parse(invoice));
          if (response.statusCode == 200) {
            webInvoiceHtml = response.body;
          }
        } catch (_) {}
      }

      if (!mounted) return;

      if (_printInvoice) {
        await Helper().printDocument(
          sellId,
          argument!['taxId'],
          context,
          invoice: webInvoiceHtml,
        );
      } else {
        await Helper().savePdf(
          sellId,
          argument!['taxId'],
          context,
          invoiceNo,
          invoice: webInvoiceHtml,
        );
      }
    } catch (e) {
      debugPrint('Print error: $e');
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    Navigator.pushNamedAndRemoveUntil(
      context,
      (argument!['sellId'] == null) ? '/layout' : '/sale',
      ModalRoute.withName('/home'),
    );
  }

  //alert dialog for amount pending
  void alertPending(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Text(
        AppLocalizations.of(context).translate('pending_message'),
        style: AppTheme.getTextStyle(
          themeData.textTheme.bodyMedium,
          color: themeData.colorScheme.onSurface,
          fontWeight: 500,
          muted: true,
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: themeData.colorScheme.onPrimary,
            backgroundColor: themeData.colorScheme.primary,
          ),
          onPressed: () {
            Navigator.pop(context);
            if (!saleCreated) {
              onSubmit();
            }
          },
          child: Text(AppLocalizations.of(context).translate('ok')),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: themeData.colorScheme.primary,
            backgroundColor: themeData.colorScheme.onPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context).translate('cancel')),
        ),
      ],
    );
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //alert dialog for confirmation
  void alertConfirm(BuildContext context, index) {
    AlertDialog alert = AlertDialog(
      title: Icon(MdiIcons.alert, color: Colors.red, size: MySize.size50),
      content: Text(
        AppLocalizations.of(context).translate('are_you_sure'),
        textAlign: TextAlign.center,
        style: AppTheme.getTextStyle(
          themeData.textTheme.bodyLarge,
          color: themeData.colorScheme.onSurface,
          fontWeight: 600,
          muted: true,
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: themeData.colorScheme.primary,
            backgroundColor: themeData.colorScheme.onPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context).translate('cancel')),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: themeData.colorScheme.onError,
          ),
          onPressed: () {
            Navigator.pop(context);
            if (sellId != null && payments[index]['id'] != null) {
              deletedPaymentId.add(payments[index]['id']);
            }
            payments.removeAt(index);
            calculateMultiPayment();
          },
          child: Text(AppLocalizations.of(context).translate('ok')),
        ),
      ],
    );
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
