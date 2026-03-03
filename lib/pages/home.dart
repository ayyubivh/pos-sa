import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos_final/pages/home/widgets/greeting_widget.dart';
import 'package:pos_final/pages/home/widgets/statistics_widget.dart';
import 'package:pos_final/pages/notifications/view_model_manger/notifications_cubit.dart';
import 'package:pos_final/presentation/screens/report_screen.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../core/theme/app_theme.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../domain/models/attendance.dart';
import '../domain/models/payment_database.dart';
import '../domain/models/sell.dart';
import '../domain/models/sell_database.dart';
import '../domain/models/system.dart';
import '../domain/models/variations.dart';

part 'home/home_state.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}
