import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pos_final/config.dart';
import 'package:search_choices/search_choices.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/contact_service.dart';
import '../../domain/models/contact_model.dart';
import '../../domain/models/sell.dart';
import '../../domain/models/sell_database.dart';
import '../../helpers/otherHelpers.dart';
import '../../locale/MyLocalizations.dart';
import '../../pages/elements.dart';

part 'customer/customer_state.dart';

class Customer extends StatefulWidget {
  const Customer({super.key});

  @override
  _CustomerState createState() => _CustomerState();
}
