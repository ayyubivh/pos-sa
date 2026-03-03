import 'dart:convert';

// import 'package:date_time_picker/date_time_picker.dart'; // Removed due to intl version conflict
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:search_choices/search_choices.dart';

import '../data/services/field_force_service.dart';
import '../config.dart';
import '../core/theme/app_theme.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../domain/models/contact_model.dart';

part 'add_visit/add_visit_state.dart';

class NewVisitForm extends StatefulWidget {
  const NewVisitForm({super.key});

  @override
  _NewVisitFormState createState() => _NewVisitFormState();
}
