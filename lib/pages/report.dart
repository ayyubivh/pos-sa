import 'package:flutter/material.dart';
import 'package:pos_final/helpers/AppTheme.dart';
import 'package:pos_final/pages/product_stock_report.dart';
import 'package:pos_final/pages/profit_loss_report.dart';
import 'package:pos_final/constants.dart';

import '../locale/MyLocalizations.dart';

class ReportScreen extends StatelessWidget {
  static const String routeName = '/ReportScreen';
  ReportScreen({super.key});

  static int themeType = 1;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kBackgroundColor,
        title: Text(
          AppLocalizations.of(context).translate('reports'),
          style: AppTheme.getTextStyle(
            themeData.textTheme.titleLarge,
            fontWeight: 600,
            color: kPrimaryTextColor,
          ),
        ),
        iconTheme: IconThemeData(color: kPrimaryTextColor),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate('select_report_type'),
              style: AppTheme.getTextStyle(
                themeData.textTheme.titleMedium,
                color: kMutedTextColor,
                fontWeight: 500,
              ),
            ),
            SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildReportCard(
                  context,
                  title: AppLocalizations.of(context).translate('profit_loss'),
                  icon: Icons.analytics_outlined,
                  color: Color(0xFF0F4C81),
                  onTap: () => Navigator.pushNamed(
                    context,
                    ProfitLossReportScreen.routeName,
                  ),
                ),
                _buildReportCard(
                  context,
                  title: AppLocalizations.of(
                    context,
                  ).translate('products_stock'),
                  icon: Icons.inventory_2_outlined,
                  color: Color(0xFF10B981),
                  onTap: () => Navigator.pushNamed(
                    context,
                    ProductStockReportScreen.routeName,
                  ),
                ),
                // Add more report types here if needed
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kSurfaceColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
          ],
          border: Border.all(color: kOutlineColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.getTextStyle(
                themeData.textTheme.titleSmall,
                color: kPrimaryTextColor,
                fontWeight: 600,
              ),
            ),
            SizedBox(height: 8),
            Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: kMutedTextColor.withValues(alpha: .5),
            ),
          ],
        ),
      ),
    );
  }
}
