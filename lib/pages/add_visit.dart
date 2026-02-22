import 'dart:convert';

// import 'package:date_time_picker/date_time_picker.dart'; // Removed due to intl version conflict
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:search_choices/search_choices.dart';

import '../apis/field_force.dart';
import '../config.dart';
import '../helpers/AppTheme.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../models/contact_model.dart';

class NewVisitForm extends StatefulWidget {
  const NewVisitForm({super.key});

  @override
  _NewVisitFormState createState() => _NewVisitFormState();
}

class _NewVisitFormState extends State<NewVisitForm> {
  late bool isLoading = false;
  bool fromContact = false;
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> customerListMap = [];
  Map<String, dynamic> selectedCustomer = {
    'id': 0,
    'name': 'select customer',
    'mobile': ' - ',
  };
  var visitOn = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  TextEditingController nameController = TextEditingController(),
      addressController = TextEditingController(),
      visitForController = TextEditingController();

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  @override
  void initState() {
    super.initState();
    setCustomerList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('add_visit'),
          style: AppTheme.getTextStyle(
            themeData.textTheme.titleLarge,
            fontWeight: 600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: (isLoading)
            ? Helper().loadingIndicator(context)
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('Whom_you_will_be_visiting'),
                                style: AppTheme.getTextStyle(
                                  themeData.textTheme.titleMedium,
                                  fontWeight: 600,
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () =>
                                          setState(() => fromContact = true),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: fromContact
                                              ? themeData.colorScheme.primary
                                                    .withValues(alpha: 0.1)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: fromContact
                                                ? themeData.colorScheme.primary
                                                : themeData.dividerColor,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.contact_page_outlined,
                                              size: 20,
                                              color: fromContact
                                                  ? themeData
                                                        .colorScheme
                                                        .primary
                                                  : themeData.disabledColor,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              ).translate('contacts'),
                                              style: AppTheme.getTextStyle(
                                                themeData.textTheme.bodyMedium,
                                                color: fromContact
                                                    ? themeData
                                                          .colorScheme
                                                          .primary
                                                    : themeData.disabledColor,
                                                fontWeight: fromContact
                                                    ? 600
                                                    : 400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () =>
                                          setState(() => fromContact = false),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: !fromContact
                                              ? themeData.colorScheme.primary
                                                    .withValues(alpha: 0.1)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: !fromContact
                                                ? themeData.colorScheme.primary
                                                : themeData.dividerColor,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person_add_outlined,
                                              size: 20,
                                              color: !fromContact
                                                  ? themeData
                                                        .colorScheme
                                                        .primary
                                                  : themeData.disabledColor,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              ).translate('others'),
                                              style: AppTheme.getTextStyle(
                                                themeData.textTheme.bodyMedium,
                                                color: !fromContact
                                                    ? themeData
                                                          .colorScheme
                                                          .primary
                                                    : themeData.disabledColor,
                                                fontWeight: !fromContact
                                                    ? 600
                                                    : 400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (!fromContact) ...[
                                SizedBox(height: 24),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('person_or_company'),
                                  style: AppTheme.getTextStyle(
                                    themeData.textTheme.titleSmall,
                                    fontWeight: 600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: nameController,
                                  validator: (value) {
                                    if (nameController.text.trim() == "") {
                                      return AppLocalizations.of(
                                        context,
                                      ).translate(
                                        'pLease_provide_person_or_company_name',
                                      );
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(
                                      context,
                                    ).translate('person_or_company'),
                                  ),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('visit_address'),
                                  style: AppTheme.getTextStyle(
                                    themeData.textTheme.titleSmall,
                                    fontWeight: 600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: addressController,
                                  validator: (value) {
                                    if (addressController.text.trim() == "") {
                                      return AppLocalizations.of(
                                        context,
                                      ).translate('please_enter_visit_address');
                                    }
                                    return null;
                                  },
                                  minLines: 2,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(
                                      context,
                                    ).translate('visit_address'),
                                  ),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                ),
                              ] else ...[
                                SizedBox(height: 24),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('select_contact'),
                                  style: AppTheme.getTextStyle(
                                    themeData.textTheme.titleSmall,
                                    fontWeight: 600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: themeData
                                        .inputDecorationTheme
                                        .fillColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: themeData.dividerColor,
                                    ),
                                  ),
                                  child: customerList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('visit_details'),
                                style: AppTheme.getTextStyle(
                                  themeData.textTheme.titleMedium,
                                  fontWeight: 600,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('visit_on'),
                                style: AppTheme.getTextStyle(
                                  themeData.textTheme.titleSmall,
                                  fontWeight: 600,
                                ),
                              ),
                              SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final DateTime? pickedDate =
                                      await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(
                                          Duration(days: 366),
                                        ),
                                      );

                                  if (pickedDate != null) {
                                    final TimeOfDay? pickedTime =
                                        await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );

                                    if (pickedTime != null) {
                                      final DateTime combinedDateTime =
                                          DateTime(
                                            pickedDate.year,
                                            pickedDate.month,
                                            pickedDate.day,
                                            pickedTime.hour,
                                            pickedTime.minute,
                                          );

                                      setState(() {
                                        visitOn = DateFormat(
                                          'yyyy-MM-dd HH:mm:ss',
                                        ).format(combinedDateTime);
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: themeData
                                        .inputDecorationTheme
                                        .fillColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: themeData.dividerColor,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat(
                                          'yyyy-MM-dd  hh:mm a',
                                        ).format(
                                          DateFormat(
                                            'yyyy-MM-dd HH:mm:ss',
                                          ).parse(visitOn),
                                        ),
                                        style: AppTheme.getTextStyle(
                                          themeData.textTheme.bodyLarge,
                                          color: themeData.colorScheme.primary,
                                          fontWeight: 500,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        color: themeData.colorScheme.primary,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('purpose_of_visiting'),
                                style: AppTheme.getTextStyle(
                                  themeData.textTheme.titleSmall,
                                  fontWeight: 600,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: visitForController,
                                minLines: 2,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).translate('purpose_of_visiting'),
                                ),
                                textCapitalization:
                                    TextCapitalization.sentences,
                                style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyLarge,
                                  fontWeight: 500,
                                  color: themeData.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () async {
                          bool validated = true;
                          if (fromContact && selectedCustomer['id'] == 0) {
                            validated = false;
                            Fluttertoast.showToast(
                              msg: AppLocalizations.of(
                                context,
                              ).translate('please_set_contact'),
                            );
                          }

                          if (await Helper().checkConnectivity()) {
                            if (_formKey.currentState!.validate() &&
                                validated) {
                              setState(() {
                                isLoading = true;
                              });
                              Map visitDetails = {
                                if (fromContact == true)
                                  'contact_id': selectedCustomer['id'],
                                if (fromContact == false)
                                  'visit_to': nameController.text,
                                if (fromContact == false)
                                  'visit_address': addressController.text,
                                'assigned_to': Config.userId,
                                'visit_on': DateFormat(
                                  'yyyy-MM-dd HH:mm:ss',
                                ).format(DateTime.now()),
                                'visit_for': visitForController.text,
                              };
                              FieldForceApi().create(visitDetails).then((
                                value,
                              ) {
                                if (value != null) {
                                  Fluttertoast.showToast(
                                    msg: AppLocalizations.of(
                                      context,
                                    ).translate('status_updated'),
                                  );
                                }
                                Navigator.pop(context);
                              });
                            }
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context).translate('save'),
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
            style: AppTheme.getTextStyle(
              themeData.textTheme.bodyMedium,
              color: themeData.colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
      // value: customerListMap[0],
      iconEnabledColor: Colors.blue,
      iconDisabledColor: Colors.black,
      onChanged: (value) async {
        setState(() {
          selectedCustomer = jsonDecode(value);
        });
      },
      isExpanded: true,
    );
  }

  //set customer list
  Future<void> setCustomerList() async {
    customerListMap = [
      {'id': 0, 'name': 'select customer', 'mobile': ' - '},
    ];
    await Contact().get().then((value) {
      for (var element in value) {
        setState(() {
          customerListMap.add({
            'id': element['id'],
            'name': element['name'],
            'mobile': element['mobile'],
          });
        });
      }
    });
  }
}
