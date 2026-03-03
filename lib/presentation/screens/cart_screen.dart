import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/product_model.dart';
import '../../domain/models/sell.dart';
import '../../domain/models/sell_database.dart';
import '../../domain/models/system.dart';
import '../../domain/models/variations.dart';
import '../../helpers/SizeConfig.dart';
import '../../helpers/icons.dart';
import '../../helpers/otherHelpers.dart';
import '../../locale/MyLocalizations.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import '../../pages/elements.dart';

part 'cart/cart_state.dart';

class Cart extends StatefulWidget {
  @override
  CartState createState() => CartState();
}
