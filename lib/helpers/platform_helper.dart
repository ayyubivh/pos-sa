import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

bool get isWeb => kIsWeb;

bool get isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

bool get isMobile =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);
