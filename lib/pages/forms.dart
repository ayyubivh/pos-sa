// import 'package:call_log/call_log.dart';

import 'dart:convert';
import 'dart:io';

// import 'package:date_time_picker/date_time_picker.dart'; // Removed due to intl version conflict
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../constants.dart';

import '../apis/field_force.dart';
import '../apis/follow_up.dart';
import '../helpers/AppTheme.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../models/contact_model.dart';

class VisitForm extends StatefulWidget {
  const VisitForm({super.key, this.visit});
  final visit;

  @override
  _VisitFormState createState() => _VisitFormState();
}

class _VisitFormState extends State<VisitForm> {
  String visitStatus = '', location = '';
  XFile? _image;
  bool isLoading = false, showMeet2 = false, showMeet3 = false;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  LatLng? currentLoc;

  TextEditingController reasonController = TextEditingController(),
      meetWith = TextEditingController(),
      meetMobile = TextEditingController(),
      meetDesignation = TextEditingController(),
      meetWith2 = TextEditingController(),
      meetMobile2 = TextEditingController(),
      meetDesignation2 = TextEditingController(),
      meetWith3 = TextEditingController(),
      meetMobile3 = TextEditingController(),
      meetDesignation3 = TextEditingController(),
      discussionController = TextEditingController();

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  @override
  void initState() {
    super.initState();
    visitStatus = widget.visit['status'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "${widget.visit['visit_id']}",
          style: AppTheme.getTextStyle(
            themeData.textTheme.titleMedium,
            fontWeight: 600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: (isLoading)
            ? Helper().loadingIndicator(context)
            : Form(
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
                              ).translate('Did_you_meet_with_the_contact'),
                              style: AppTheme.getTextStyle(
                                themeData.textTheme.titleMedium,
                                fontWeight: 600,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(
                                      () => visitStatus = 'met_contact',
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: visitStatus == 'met_contact'
                                            ? themeData.colorScheme.primary
                                                  .withValues(alpha: 0.1)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: visitStatus == 'met_contact'
                                              ? themeData.colorScheme.primary
                                              : kOutlineColor,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).translate('yes'),
                                          style: AppTheme.getTextStyle(
                                            themeData.textTheme.bodyMedium,
                                            fontWeight:
                                                visitStatus == 'met_contact'
                                                ? 600
                                                : 400,
                                            color: visitStatus == 'met_contact'
                                                ? themeData.colorScheme.primary
                                                : kPrimaryTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(
                                      () =>
                                          visitStatus = 'did_not_meet_contact',
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            visitStatus ==
                                                'did_not_meet_contact'
                                            ? themeData.colorScheme.primary
                                                  .withValues(alpha: 0.1)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color:
                                              visitStatus ==
                                                  'did_not_meet_contact'
                                              ? themeData.colorScheme.primary
                                              : kOutlineColor,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).translate('no'),
                                          style: AppTheme.getTextStyle(
                                            themeData.textTheme.bodyMedium,
                                            fontWeight:
                                                visitStatus ==
                                                    'did_not_meet_contact'
                                                ? 600
                                                : 400,
                                            color:
                                                visitStatus ==
                                                    'did_not_meet_contact'
                                                ? themeData.colorScheme.primary
                                                : kPrimaryTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (visitStatus == 'did_not_meet_contact') ...[
                              SizedBox(height: 16),
                              TextFormField(
                                controller: reasonController,
                                validator: (value) {
                                  if (visitStatus == "did_not_meet_contact" &&
                                      reasonController.text.trim() == "") {
                                    return AppLocalizations.of(
                                      context,
                                    ).translate('please_provide_reason');
                                  }
                                  return null;
                                },
                                minLines: 2,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).translate('reason'),
                                  labelText: AppLocalizations.of(
                                    context,
                                  ).translate('reason'),
                                ),
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                              ).translate('visit_photo'),
                              style: AppTheme.getTextStyle(
                                themeData.textTheme.titleMedium,
                                fontWeight: 600,
                              ),
                            ),
                            SizedBox(height: 16),
                            InkWell(
                              onTap: _imgFromCamera,
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: kOutlineColor),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      color: kMutedTextColor,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _image != null
                                            ? _image!.name
                                            : AppLocalizations.of(
                                                context,
                                              ).translate(
                                                'take_photo_of_the_contact_or_visited_place',
                                              ),
                                        style: AppTheme.getTextStyle(
                                          themeData.textTheme.bodyMedium,
                                          color: _image != null
                                              ? kPrimaryTextColor
                                              : kMutedTextColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (_image != null)
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ),
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
                              ).translate('meet_with'),
                              style: AppTheme.getTextStyle(
                                themeData.textTheme.titleMedium,
                                fontWeight: 600,
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: meetWith,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  context,
                                ).translate('name'),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  size: 20,
                                ),
                              ),
                              validator: (value) {
                                if (meetWith.text.trim() == "") {
                                  return AppLocalizations.of(
                                    context,
                                  ).translate('please_provide_meet_with');
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: meetMobile,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  context,
                                ).translate('mobile_no'),
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                  size: 20,
                                ),
                              ),
                              validator: (value) {
                                if (meetMobile.text.trim() == "") {
                                  return AppLocalizations.of(context).translate(
                                    'please_provide_meet_with_mobile_no',
                                  );
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: meetDesignation,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  context,
                                ).translate('designation'),
                                prefixIcon: Icon(Icons.work_outline, size: 20),
                              ),
                              validator: (value) {
                                if (meetDesignation.text.trim() == "") {
                                  return AppLocalizations.of(
                                    context,
                                  ).translate('please_provide_designation');
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.sentences,
                            ),
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
                              ).translate('location'),
                              style: AppTheme.getTextStyle(
                                themeData.textTheme.titleMedium,
                                fontWeight: 600,
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  await Geolocator.getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.high,
                                  ).then((Position position) {
                                    currentLoc = LatLng(
                                      position.latitude,
                                      position.longitude,
                                    );
                                    if (currentLoc != null) {
                                      setState(() {
                                        location =
                                            "Lat: ${currentLoc!.latitude.toStringAsFixed(6)}, Lng: ${currentLoc!.longitude.toStringAsFixed(6)}";
                                      });
                                    }
                                  });
                                } catch (e) {}
                              },
                              icon: Icon(Icons.my_location, size: 20),
                              label: Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('get_current_location'),
                              ),
                            ),
                            if (location.isNotEmpty) ...[
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: kBackgroundSoftColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  location,
                                  style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyMedium,
                                    fontWeight: 500,
                                  ),
                                ),
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
                              ).translate('discussions_with_the_contact'),
                              style: AppTheme.getTextStyle(
                                themeData.textTheme.titleMedium,
                                fontWeight: 600,
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: discussionController,
                              minLines: 3,
                              maxLines: 6,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(
                                  context,
                                ).translate('write_summarize_discussion'),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        bool validated = true;
                        String? placeImage;
                        if (await Helper().checkConnectivity()) {
                          if (visitStatus == "assigned") {
                            validated = false;
                            Fluttertoast.showToast(
                              msg: AppLocalizations.of(
                                context,
                              ).translate('please_enter_visit_status'),
                            );
                          }

                          if (_image == null) {
                            validated = false;
                            Fluttertoast.showToast(
                              msg: AppLocalizations.of(context).translate(
                                'please_upload_image_of_visited_place',
                              ),
                            );
                          } else {
                            File imageFile = File(_image!.path);
                            List<int> imageBytes = imageFile.readAsBytesSync();
                            placeImage = base64Encode(imageBytes);
                          }

                          if (currentLoc == null) {
                            validated = false;
                            Fluttertoast.showToast(
                              msg: AppLocalizations.of(
                                context,
                              ).translate('please_add_current_location'),
                            );
                          }

                          if (_formKey.currentState!.validate() && validated) {
                            setState(() {
                              isLoading = true;
                            });
                            Map visitDetails = {
                              'status': visitStatus,
                              if (visitStatus == "did_not_meet_contact")
                                'reason_to_not_meet_contact':
                                    reasonController.text,
                              'visited_on': DateFormat(
                                'yyyy-MM-dd HH:mm:ss',
                              ).format(DateTime.now()),
                              'meet_with': meetWith.text,
                              'meet_with_mobileno': meetMobile.text,
                              'meet_with_designation': meetDesignation.text,
                              'latitude': currentLoc!.latitude.toString(),
                              'longitude': currentLoc!.longitude.toString(),
                              'comments': discussionController.text,
                              'photo': placeImage,
                            };
                            FieldForceApi()
                                .update(visitDetails, widget.visit['id'])
                                .then((value) {
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
                        AppLocalizations.of(context).translate('update'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  //image from camera
  Future<void> _imgFromCamera() async {
    XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
    ); //, imageQuality: 50);
    setState(() {
      _image = image;
    });
  }
}

class FollowUpForm extends StatefulWidget {
  final Map<String, dynamic> customerDetails;
  final bool? edit;

  const FollowUpForm(this.customerDetails, {super.key, this.edit});

  @override
  _FollowUpFormState createState() => _FollowUpFormState();
}

class _FollowUpFormState extends State<FollowUpForm> {
  List<String> statusList = ['scheduled', 'open', 'cancelled', 'completed'],
      followUpTypeList = ['call', 'sms', 'meeting', 'email'];
  List<Map<String, dynamic>> followUpCategory = [
    {'id': 0, 'name': 'Please select'},
  ];
  String? selectedStatus = 'completed',
      selectedFollowUpType = 'call',
      duration = '';
  Map<String, dynamic>? selectedFollowUpCategory;

  bool showError = false;

  TextEditingController titleController = TextEditingController(),
      startDateController = TextEditingController(),
      endDateController = TextEditingController(),
      descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  @override
  void initState() {
    super.initState();
    getFollowUpCategories();
  }

  Future<void> onEditFollowUp() async {
    if (widget.edit == true) {
      setState(() {
        titleController.text = widget.customerDetails['title'];
        selectedStatus = widget.customerDetails['status'] ?? 'scheduled';
        selectedFollowUpType = widget.customerDetails['schedule_type'];
        startDateController.text = widget.customerDetails['start_datetime'];
        endDateController.text = widget.customerDetails['end_datetime'];
        descriptionController.text = widget.customerDetails['description'];
      });
      for (var element in followUpCategory) {
        if (widget.customerDetails['followup_category'] != null &&
            element['id'] ==
                widget.customerDetails['followup_category']['id']) {
          setState(() {
            selectedFollowUpCategory = element;
          });
        }
      }
    }
  }

  Future<void> getFollowUpCategories() async {
    await FollowUpApi().getFollowUpCategories().then((value) async {
      for (var element in value) {
        followUpCategory.add({
          'id': int.parse(element['id'].toString()),
          'name': element['name'],
        });
        setState(() {});
      }
      await onEditFollowUp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          (widget.edit == true)
              ? AppLocalizations.of(context).translate('edit_follow_up')
              : AppLocalizations.of(context).translate('add_follow_up'),
        ),
      ),
      body: SingleChildScrollView(
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
                        AppLocalizations.of(context).translate('customer_name'),
                        style: AppTheme.getTextStyle(
                          themeData.textTheme.bodySmall,
                          fontWeight: 600,
                          color: kMutedTextColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.customerDetails['name'],
                        style: AppTheme.getTextStyle(
                          themeData.textTheme.titleMedium,
                          fontWeight: 600,
                        ),
                      ),
                      Divider(height: 32),
                      TextFormField(
                        onEditingComplete: () {
                          FocusScope.of(context).unfocus();
                        },
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return "${AppLocalizations.of(context).translate('title')} "
                                "${AppLocalizations.of(context).translate('required')}";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          ).translate('title'),
                          labelText: AppLocalizations.of(
                            context,
                          ).translate('title'),
                        ),
                        controller: titleController,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedStatus,
                              isExpanded: true,
                              icon: Icon(
                                Icons.expand_more_rounded,
                                color: kMutedTextColor,
                                size: 20,
                              ),
                              items: statusList.map<DropdownMenuItem<String>>((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value.toUpperCase(),
                                    style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyMedium,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedStatus = newValue;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  context,
                                ).translate('status'),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return AppLocalizations.of(
                                    context,
                                  ).translate('required');
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedFollowUpType,
                              isExpanded: true,
                              icon: Icon(
                                Icons.expand_more_rounded,
                                color: kMutedTextColor,
                                size: 20,
                              ),
                              items: followUpTypeList
                                  .map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value.toUpperCase(),
                                        style: AppTheme.getTextStyle(
                                          themeData.textTheme.bodyMedium,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedFollowUpType = newValue;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  context,
                                ).translate('type'),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return AppLocalizations.of(
                                    context,
                                  ).translate('required');
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        initialValue: selectedFollowUpCategory,
                        isExpanded: true,
                        icon: Icon(
                          Icons.expand_more_rounded,
                          color: kMutedTextColor,
                          size: 20,
                        ),
                        hint: Text(
                          AppLocalizations.of(context).translate('select'),
                          style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyMedium,
                            color: kMutedTextColor,
                          ),
                        ),
                        items: followUpCategory
                            .where((cat) => cat['id'] != 0)
                            .map<DropdownMenuItem<Map<String, dynamic>>>((
                              var value,
                            ) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: value,
                                child: Text(
                                  value['name'],
                                  style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyMedium,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            })
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedFollowUpCategory = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          ).translate('follow_up_category'),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return AppLocalizations.of(
                              context,
                            ).translate('required');
                          }
                          return null;
                        },
                      ),
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
                        AppLocalizations.of(context).translate('scheduling'),
                        style: AppTheme.getTextStyle(
                          themeData.textTheme.titleMedium,
                          fontWeight: 600,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: startDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          ).translate('start_datetime'),
                          suffixIcon: Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                          ),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              Duration(days: 366),
                            ),
                            lastDate: DateTime.now().add(Duration(days: 180)),
                          );
                          if (pickedDate != null) {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              final DateTime fullDateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              setState(() {
                                startDateController.text = DateFormat(
                                  'yyyy-MM-dd    hh:mm a',
                                ).format(fullDateTime);
                              });
                            }
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return AppLocalizations.of(
                              context,
                            ).translate('required');
                          else
                            return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: endDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          ).translate('end_datetime'),
                          suffixIcon: Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                          ),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              Duration(days: 366),
                            ),
                            lastDate: DateTime.now().add(Duration(days: 180)),
                          );
                          if (pickedDate != null) {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              final DateTime fullDateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              setState(() {
                                endDateController.text = DateFormat(
                                  'yyyy-MM-dd    hh:mm a',
                                ).format(fullDateTime);
                              });
                            }
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return AppLocalizations.of(
                              context,
                            ).translate('required');
                          else
                            return null;
                        },
                      ),
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
                        ).translate('additional_details'),
                        style: AppTheme.getTextStyle(
                          themeData.textTheme.titleMedium,
                          fontWeight: 600,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        minLines: 3,
                        maxLines: 6,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          hintText: AppLocalizations.of(
                            context,
                          ).translate('description'),
                          labelText: AppLocalizations.of(
                            context,
                          ).translate('description'),
                        ),
                        controller: descriptionController,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      if (showError) ...[
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: themeData.colorScheme.error.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: themeData.colorScheme.error,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('call_log_not_found'),
                                  style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodySmall,
                                    color: themeData.colorScheme.error,
                                  ),
                                ),
                              ),
                              Helper().callDropdown(
                                context,
                                widget.customerDetails,
                                [
                                  widget.customerDetails['mobile'],
                                  widget.customerDetails['landline'],
                                  widget.customerDetails['alternate_number'],
                                ],
                                type: 'call',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (selectedFollowUpType == 'call' &&
                      selectedStatus == 'completed') {
                    onSubmit();
                  } else {
                    onSubmit();
                  }
                },
                child: Text(AppLocalizations.of(context).translate('submit')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //get call logs from mobile
  //   getCallLogDetails() async {
  //     List<CallLogEntry> logs = [
  //       await FollowUpModel().getLogs(widget.customerDetails['mobile']),
  //       await FollowUpModel().getLogs(widget.customerDetails['landline']),
  //       await FollowUpModel().getLogs(widget.customerDetails['alternate_number'])
  //     ];
  // //sort callLogs with respective of highest timestamp(last dialed number)
  //     logs.sort((a, b) =>
  //         ((a != null) ? a.timestamp : 0)
  //             .compareTo((b != null) ? b.timestamp : 0));
  //     CallLogEntry lastLog = logs.last;
  //
  //     if (lastLog != null) {
  //       // get last call duration of selected customer
  //       setState(() {
  //         startDateController.text =
  //             DateTime.fromMillisecondsSinceEpoch(lastLog.timestamp)
  //                 .subtract(Duration(seconds: lastLog.duration))
  //                 .toString();
  //         endDateController.text =
  //             DateTime.fromMillisecondsSinceEpoch(lastLog.timestamp).toString();
  //         showError = false;
  //       });
  //       duration =
  //       '${Duration(seconds: lastLog.duration).toString().substring(2, 7)}';
  //     } else {
  //       setState(() {
  //         showError = true;
  //       });
  //     }
  //   }

  //on submit
  Future<void> onSubmit() async {
    if (_formKey.currentState!.validate() && showError == false) {
      Map followUp = FollowUpModel().submitFollowUp(
        title: titleController.text,
        description: descriptionController.text,
        contactId: widget.customerDetails['id'],
        followUpCategoryId: selectedFollowUpCategory?['id'],
        endDate: endDateController.text,
        startDate: startDateController.text,
        duration: (duration != '') ? duration : null,
        scheduleType: selectedFollowUpType,
        status: selectedStatus,
      );
      int response = (widget.edit == true)
          ? await FollowUpApi().update(
              followUp,
              widget.customerDetails['followUpId'],
            )
          : await FollowUpApi().addFollowUp(followUp);
      if (response == 201 || response == 200) {
        Navigator.pop(context);
        (widget.edit == true)
            ? Navigator.pushReplacementNamed(context, '/followUp')
            : Navigator.pushReplacementNamed(context, '/leads');
      } else {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('something_went_wrong'),
        );
      }
    }
  }
}
