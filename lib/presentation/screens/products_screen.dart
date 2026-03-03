import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pos_final/helpers/icons.dart';

import '../../constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/product_model.dart';
import '../../domain/models/sell.dart';
import '../../domain/models/system.dart';
import '../../domain/models/variations.dart';
import '../../helpers/otherHelpers.dart';
import '../../locale/MyLocalizations.dart';

part 'products/products_state.dart';
part 'products/products_widgets.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  _ProductsState createState() => _ProductsState();
}
