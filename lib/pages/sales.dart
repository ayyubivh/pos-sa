import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pos_final/config.dart';
import 'package:pos_final/constants.dart';
import 'package:search_choices/search_choices.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../data/services/api_service.dart';
import '../data/services/sell_service.dart';
import '../core/theme/app_theme.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../domain/models/contact_model.dart';
import '../domain/models/payment_database.dart';
import '../domain/models/sell.dart';
import '../domain/models/sell_database.dart';
import '../domain/models/system.dart';

part 'sales/sales_state.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  _SalesState createState() => _SalesState();
}
