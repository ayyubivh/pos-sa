import 'package:flutter/material.dart';
import 'package:pos_final/helpers/SizeConfig.dart';
import 'package:pos_final/helpers/otherHelpers.dart';
import 'package:pos_final/locale/MyLocalizations.dart';

class Statistics extends StatelessWidget {
  Statistics({
    this.businessSymbol = '',
    this.totalSales,
    this.totalSalesAmount = 0,
    this.totalReceivedAmount = 0,
    this.totalDueAmount = 0,
    required this.themeData,
  });

  final String businessSymbol;
  final int? totalSales;
  final double totalSalesAmount, totalReceivedAmount, totalDueAmount;
  final ThemeData themeData;
  static const List<Color> _iconBg = [
    Color(0xFFFFF4E5),
    Color(0xFFE8F4EE),
    Color(0xFFFFECEC),
    Color(0xFFE9F0FB),
  ];
  static const List<Color> _iconColor = [
    Color(0xFFCC7A00),
    Color(0xFF2D7A52),
    Color(0xFFD64045),
    Color(0xFF295FA8),
  ];
  static const List<IconData> _icons = [
    Icons.point_of_sale_rounded,
    Icons.show_chart_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.pending_actions_rounded,
  ];
  static const List<String> _labels = [
    'number_of_sales',
    'sales_amount',
    'paid_amount',
    'due_amount',
  ];

  @override
  Widget build(BuildContext context) {
    final values = [
      Helper().formatQuantity(totalSales ?? 0),
      '$businessSymbol ${Helper().formatCurrency(totalSalesAmount)}',
      '$businessSymbol ${Helper().formatCurrency(totalReceivedAmount)}',
      '$businessSymbol ${Helper().formatCurrency(totalDueAmount)}',
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: MySize.size12!,
        childAspectRatio: 1.32,
        crossAxisSpacing: MySize.size12!,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _iconBg[index],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icons[index], size: 19, color: _iconColor[index]),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context).translate(_labels[index]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: themeData.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF334155),
                ),
              ),
              const Spacer(),
              Text(
                values[index],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: themeData.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
