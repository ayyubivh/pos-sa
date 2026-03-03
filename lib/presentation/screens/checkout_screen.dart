import 'dart:async';

// import 'package:date_time_picker/date_time_picker.dart'; // Removed due to intl version conflict
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pos_final/config.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/payment_database.dart';
import '../../domain/models/sell.dart';
import '../../domain/models/sell_database.dart';
import '../../domain/models/system.dart';
import '../../helpers/SizeConfig.dart';
import '../../helpers/otherHelpers.dart';
import '../../locale/MyLocalizations.dart';
import '../widgets/simple_date_time_picker.dart';

part 'checkout/checkout_state.dart';

class CheckOut extends StatefulWidget {
  const CheckOut({super.key});

  @override
  CheckOutState createState() => CheckOutState();
}
