import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:window_manager/window_manager.dart';

import 'config.dart';
import 'core/theme/app_theme.dart';
import 'helpers/platform_helper.dart';
import 'locale/MyLocalizations.dart';
import 'presentation/navigation/app_routes.dart';
import 'viewmodel/viewmodels/notifications_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  if (kIsWeb) {
    // Initialize sqflite WASM factory so the same DB code works in the browser.
    databaseFactory = databaseFactoryFfiWeb;
  } else if (isDesktop) {
    // Initialize sqflite FFI for desktop SQLite support
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Configure the application window
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(900, 600),
      center: true,
      title: 'EazyERP POS',
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } else {
    // Lock portrait on mobile
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  runApp(MyApp(appLanguage: appLanguage));
}

class MyApp extends StatelessWidget {
  final AppLanguage? appLanguage;

  const MyApp({super.key, this.appLanguage});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationsCubit()..getNotification(),
      child: ChangeNotifierProvider<AppLanguage>(
        create: (_) => appLanguage!,
        child: Consumer<AppLanguage>(
          builder: (context, model, child) {
            return MaterialApp(
              routes: Routes.generateRoute(),
              initialRoute: '/splash',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.getThemeFromThemeMode(1),
              locale: model.appLocal,
              supportedLocales: Config().supportedLocales,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
            );
          },
        ),
      ),
    );
  }
}
