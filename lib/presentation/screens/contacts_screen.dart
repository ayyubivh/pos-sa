import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../constants.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/api_service.dart';
import '../../data/services/contact_service.dart';
import '../../domain/models/contact_model.dart';
import '../../domain/models/system.dart';
import '../../helpers/otherHelpers.dart';
import '../../locale/MyLocalizations.dart';
import '../../pages/forms.dart';

part 'contacts/contacts_state.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  _ContactsState createState() => _ContactsState();
}
