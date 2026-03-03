import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:search_choices/search_choices.dart';

import '../../constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/contact_payment_service.dart';
import '../../domain/models/contact_model.dart';
import '../../domain/models/system.dart';
import '../../helpers/SizeConfig.dart';
import '../../helpers/otherHelpers.dart';
import '../../locale/MyLocalizations.dart';

part 'contact_payment/contact_payment_state.dart';

class ContactPayment extends StatefulWidget {
  const ContactPayment({super.key});

  @override
  _ContactPaymentState createState() => _ContactPaymentState();
}
