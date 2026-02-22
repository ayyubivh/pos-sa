import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../apis/profit_loss_report.dart';
import '../helpers/AppTheme.dart';
import '../locale/MyLocalizations.dart';
import '../models/profit_loss_report_model.dart';
import '../constants.dart';

class ProfitLossReportScreen extends StatefulWidget {
  static const String routeName = '/ProfitLossReport';
  ProfitLossReportScreen({Key? key}) : super(key: key);

  static int themeType = 1;

  @override
  State<ProfitLossReportScreen> createState() => _ProfitLossReportScreenState();
}

class _ProfitLossReportScreenState extends State<ProfitLossReportScreen> {
  ThemeData themeData = AppTheme.getThemeFromThemeMode(
    ProfitLossReportScreen.themeType,
  );

  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(
    ProfitLossReportScreen.themeType,
  );

  ProfitLossReportModel? profitLossReportModel;
  bool loading = true;
  List<Map<String, dynamic>> myReports = [];

  Future<void> _getProfitLossReport() async {
    dev.log("Start");

    setState(() {
      loading = true;
      myReports = [];
    });

    var result = await ProfitLossReportService().getProfitLossReport();
    if (result != null) {
      setState(() {
        profitLossReportModel = result;
        Map<String, dynamic> mapData = profitLossReportModel!.toJson();
        mapData.forEach((key, value) {
          if (value != null && key != 'net_profit') {
            myReports.add({"title": key, "data": value});
          }
        });
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    _getProfitLossReport();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kBackgroundColor,
        title: Text(
          AppLocalizations.of(context).translate('profit_loss_report'),
          style: AppTheme.getTextStyle(
            themeData.textTheme.titleLarge,
            fontWeight: 600,
            color: kPrimaryTextColor,
          ),
        ),
        iconTheme: IconThemeData(color: kPrimaryTextColor),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: kDefaultColor))
          : RefreshIndicator(
              onRefresh: _getProfitLossReport,
              color: kDefaultColor,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (profitLossReportModel?.netProfit != null)
                      _buildSummaryCard(),
                    SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context).translate('report_details'),
                      style: AppTheme.getTextStyle(
                        themeData.textTheme.titleMedium,
                        fontWeight: 600,
                        color: kPrimaryTextColor,
                      ),
                    ),
                    SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: myReports.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildReportItem(
                          title: AppLocalizations.of(
                            context,
                          ).translate(myReports[index]['title']),
                          data: myReports[index]['data'].toString(),
                        );
                      },
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final netProfit = profitLossReportModel?.netProfit ?? 0.0;
    final isProfit = netProfit >= 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
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
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).translate('net_profit'),
            style: AppTheme.getTextStyle(
              themeData.textTheme.bodyMedium,
              color: kMutedTextColor,
              fontWeight: 500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            netProfit.toStringAsFixed(2),
            style: AppTheme.getTextStyle(
              themeData.textTheme.displaySmall,
              color: isProfit ? Color(0xFF10B981) : Color(0xFFEF4444),
              fontWeight: 600,
            ),
          ),
          if (profitLossReportModel?.grossProfit != null) ...[
            SizedBox(height: 16),
            Divider(color: kOutlineColor, height: 1),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).translate('gross_profit'),
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyMedium,
                    color: kMutedTextColor,
                  ),
                ),
                Text(
                  profitLossReportModel!.grossProfit!,
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyLarge,
                    color: kPrimaryTextColor,
                    fontWeight: 600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportItem({required String title, required String data}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOutlineColor, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTheme.getTextStyle(
                themeData.textTheme.bodyMedium,
                color: kMutedTextColor,
                fontWeight: 500,
              ),
            ),
          ),
          Text(
            data,
            style: AppTheme.getTextStyle(
              themeData.textTheme.bodyLarge,
              color: kPrimaryTextColor,
              fontWeight: 600,
            ),
          ),
        ],
      ),
    );
  }
}
