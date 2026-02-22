import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../apis/product_stock_report.dart';
import '../helpers/AppTheme.dart';
import '../locale/MyLocalizations.dart';
import '../models/product_stock_report_model.dart';
import '../constants.dart';

class ProductStockReportScreen extends StatefulWidget {
  static const String routeName = '/ProductStockReport';
  ProductStockReportScreen({Key? key}) : super(key: key);

  static int themeType = 1;

  @override
  State<ProductStockReportScreen> createState() =>
      _ProductStockReportScreenState();
}

class _ProductStockReportScreenState extends State<ProductStockReportScreen> {
  ThemeData themeData = AppTheme.getThemeFromThemeMode(
    ProductStockReportScreen.themeType,
  );

  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(
    ProductStockReportScreen.themeType,
  );

  List<ProductStockReportModel> myProductReportList = [];
  List<ProductStockReportModel> filteredList = [];
  bool loading = true;
  TextEditingController searchController = TextEditingController();

  Future<void> _getProductStockReport() async {
    dev.log("Start");

    setState(() {
      loading = true;
    });

    var result = await ProductStockReportService().getProductStockReport();
    if (result != null) {
      setState(() {
        myProductReportList = result;
        filteredList = result;
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  void _filterItems(String query) {
    setState(() {
      filteredList = myProductReportList
          .where(
            (item) =>
                (item.product?.toLowerCase().contains(query.toLowerCase()) ??
                    false) ||
                (item.sku?.toLowerCase().contains(query.toLowerCase()) ??
                    false),
          )
          .toList();
    });
  }

  @override
  void initState() {
    _getProductStockReport();
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
          AppLocalizations.of(context).translate('products_stock'),
          style: AppTheme.getTextStyle(
            themeData.textTheme.titleLarge,
            fontWeight: 600,
            color: kPrimaryTextColor,
          ),
        ),
        iconTheme: IconThemeData(color: kPrimaryTextColor),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator(color: kDefaultColor))
                : RefreshIndicator(
                    onRefresh: _getProductStockReport,
                    color: kDefaultColor,
                    child: filteredList.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            itemCount: filteredList.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return _buildProductCard(filteredList[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: TextField(
        controller: searchController,
        onChanged: _filterItems,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).translate('search_products'),
          prefixIcon: Icon(Icons.search, color: kMutedTextColor, size: 20),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: kMutedTextColor, size: 20),
                  onPressed: () {
                    searchController.clear();
                    _filterItems('');
                  },
                )
              : null,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kOutlineColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kOutlineColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kDefaultColor, width: 1.5),
          ),
          filled: true,
          fillColor: kSurfaceColor,
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductStockReportModel item) {
    final double stockNum = double.tryParse(item.stock ?? '0') ?? 0;
    final double alertNum = double.tryParse(item.alertQuantity ?? '0') ?? 0;
    final bool isLowStock = stockNum <= alertNum && stockNum > 0;
    final bool isOutOfStock = stockNum <= 0;

    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product ?? '---',
                            style: AppTheme.getTextStyle(
                              themeData.textTheme.titleMedium,
                              fontWeight: 600,
                              color: kPrimaryTextColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${AppLocalizations.of(context).translate('sku')}: ${item.sku ?? '---'}",
                            style: AppTheme.getTextStyle(
                              themeData.textTheme.bodySmall,
                              color: kMutedTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStockBadge(isLowStock, isOutOfStock),
                  ],
                ),
                SizedBox(height: 16),
                Divider(color: kOutlineColor, height: 1),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn(
                      AppLocalizations.of(context).translate('stock'),
                      "${item.stock} ${item.unit}",
                    ),
                    _buildInfoColumn(
                      AppLocalizations.of(context).translate('unit_price'),
                      item.unitPrice ?? '0.00',
                    ),
                    _buildInfoColumn(
                      AppLocalizations.of(context).translate('total_sold'),
                      item.totalSold ?? '0',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: kBackgroundSoftColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.category_outlined, size: 14, color: kMutedTextColor),
                SizedBox(width: 6),
                Text(
                  item.categoryName ?? '---',
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodySmall,
                    color: kMutedTextColor,
                    fontWeight: 500,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: kMutedTextColor,
                ),
                SizedBox(width: 6),
                Text(
                  item.locationName ?? '---',
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodySmall,
                    color: kMutedTextColor,
                    fontWeight: 500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBadge(bool isLowStock, bool isOutOfStock) {
    Color bgColor = Color(0xFF10B981).withValues(alpha: .1);
    Color textColor = Color(0xFF10B981);
    String label = AppLocalizations.of(context).translate('in_stock');

    if (isOutOfStock) {
      bgColor = Color(0xFFEF4444).withValues(alpha: .1);
      textColor = Color(0xFFEF4444);
      label = AppLocalizations.of(context).translate('out_of_stock');
    } else if (isLowStock) {
      bgColor = Color(0xFFF59E0B).withValues(alpha: .1);
      textColor = Color(0xFFF59E0B);
      label = AppLocalizations.of(context).translate('low_stock');
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTheme.getTextStyle(
          themeData.textTheme.labelSmall,
          color: textColor,
          fontWeight: 600,
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getTextStyle(
            themeData.textTheme.bodySmall,
            color: kMutedTextColor,
            fontSize: 11,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.getTextStyle(
            themeData.textTheme.bodyMedium,
            color: kPrimaryTextColor,
            fontWeight: 600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: kOutlineColor),
          SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).translate('no_products_found'),
            style: AppTheme.getTextStyle(
              themeData.textTheme.titleMedium,
              color: kMutedTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
