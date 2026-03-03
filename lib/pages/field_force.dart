import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/services/api_service.dart';
import '../config.dart';
import '../core/theme/app_theme.dart';
import '../helpers/SizeConfig.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../domain/models/field_force.dart';
import '../domain/models/system.dart';
import 'add_visit.dart';
import 'forms.dart';

part 'field_force/field_force_state.dart';

class FieldForce extends StatefulWidget {
  @override
  _FieldForceState createState() => _FieldForceState();
}
