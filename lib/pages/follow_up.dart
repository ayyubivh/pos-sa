import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/services/api_service.dart';
import '../data/services/follow_up_service.dart';
import '../core/theme/app_theme.dart';
import '../helpers/SizeConfig.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../domain/models/contact_model.dart';
import '../domain/models/system.dart';
import 'forms.dart';

part 'follow_up/follow_up_state.dart';

class FollowUp extends StatefulWidget {
  @override
  _FollowUpState createState() => _FollowUpState();
}
