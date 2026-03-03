// import 'package:call_log/call_log.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/services/api_service.dart';
// import 'package:url_launcher/url_launcher.dart';

import '../data/services/shipment_service.dart';
import '../core/theme/app_theme.dart';
import '../helpers/SizeConfig.dart';
import '../locale/MyLocalizations.dart';
import '../domain/models/contact_model.dart';
import '../domain/models/shipment.dart';
import '../domain/models/system.dart';
// import 'googleMap.dart';

part 'shipment/shipment_state.dart';

class Shipment extends StatefulWidget {
  @override
  _ShipmentState createState() => _ShipmentState();
}
