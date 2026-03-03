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

import '../data/services/field_force_service.dart';
import '../data/services/follow_up_service.dart';
import '../core/theme/app_theme.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../domain/models/contact_model.dart';

part 'forms/forms_state.dart';

class VisitForm extends StatefulWidget {
  const VisitForm({super.key, this.visit});
  final visit;

  @override
  _VisitFormState createState() => _VisitFormState();
}
