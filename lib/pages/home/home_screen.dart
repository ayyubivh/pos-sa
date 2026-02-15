import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pos_final/config.dart';
import 'package:pos_final/helpers/AppTheme.dart';
import 'package:pos_final/helpers/icons.dart';
import 'package:pos_final/locale/MyLocalizations.dart';
import 'package:pos_final/models/sellDatabase.dart';
import 'package:pos_final/pages/home/widgets/greeting_widget.dart';
import 'package:pos_final/pages/notifications/view_model_manger/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/statistics_widget.dart';
import 'widgets/quick_actions_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static ThemeData themeData = AppTheme.getThemeFromThemeMode(1);
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Ensure the key is assigned to the Scaffold
      backgroundColor: themeData.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('home'),
          style: AppTheme.getTextStyle(
            themeData.textTheme.titleLarge,
            fontWeight: 700,
            color: themeData.textTheme.titleLarge?.color,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu_rounded, // Rounded menu icon for softer look
              color: themeData.iconTheme.color,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    // Navigator.pushNamed(context, '/notify');
                  },
                  icon: Icon(
                    IconBroken.Notification,
                    color: themeData.iconTheme.color,
                  ),
                ),
                BlocBuilder<NotificationsCubit, NotificationsState>(
                  builder: (context, state) {
                    int count = NotificationsCubit.get(
                      context,
                    ).notificationsCount;
                    if (count == 0) return SizedBox();
                    return Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(minWidth: 8, minHeight: 8),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              /*     (await Helper().checkConnectivity())
                    ? await sync()
                    : Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)
                        .translate('check_connectivity'));*/
            },
            icon: Icon(MdiIcons.syncIcon, color: themeData.iconTheme.color),
          ),
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await SellDatabase().getNotSyncedSells().then((value) {
                if (value.isEmpty) {
                  //saving userId in disk
                  prefs.setInt('prevUserId', Config.userId!);
                  prefs.remove('userId');
                  Navigator.pushReplacementNamed(context, '/login');
                } else {
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(
                      context,
                    ).translate('sync_all_sales_before_logout'),
                  );
                }
              });
            },
            icon: Icon(IconBroken.Logout, color: themeData.iconTheme.color),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: GreetingWidget(themeData: themeData, userName: 'Shehab'),
            ),
            Statistics(
              themeData: themeData,
              totalSales: 0,
              totalReceivedAmount: 0,
              totalDueAmount: 0,
              totalSalesAmount: 0,
            ),
            QuickActionsWidget(themeData: themeData),
          ],
        ),
      ),
    );
  }
}
