import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../apis/api.dart';
import '../../constants.dart';
import '../../core/theme/app_theme.dart';
import '../../helpers/otherHelpers.dart';
import '../../locale/MyLocalizations.dart';
import '../../models/system.dart';

class ReportScreen extends StatefulWidget {
  static const String routeName = '/ReportScreen';

  const ReportScreen({super.key});

  static int themeType = 1;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _DailyTotal {
  final DateTime date;
  double total = 0;
  int count = 0;
  _DailyTotal(this.date);
}

class _ReportScreenState extends State<ReportScreen> {
  late final ThemeData _themeData = AppTheme.getThemeFromThemeMode(
    ReportScreen.themeType,
  );

  int _rangeDays = 30;
  bool _loading = true;
  String? _error;

  List<_DailyTotal> _series = [];
  double _totalSales = 0;
  int _txCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: _rangeDays - 1));
    final fmt = DateFormat('yyyy-MM-dd');
    final startStr = fmt.format(start);
    final endStr = fmt.format(now);

    final buckets = <String, _DailyTotal>{};
    for (int i = 0; i < _rangeDays; i++) {
      final d = start.add(Duration(days: i));
      buckets[fmt.format(d)] = _DailyTotal(d);
    }

    try {
      final dio = Dio();
      final token = await System().getToken();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $token';

      String? next =
          '${Api().baseUrl}${Api().apiUrl}/sell?order_by_date=desc'
          '&start_date=$startStr&end_date=$endStr';

      double total = 0;
      int count = 0;
      // Cap pagination so very large ranges don't hang the UI.
      int safety = 20;
      while (next != null && safety-- > 0) {
        final resp = await dio.get(next);
        final List sales = (resp.data['data'] as List?) ?? [];
        for (final s in sales) {
          final dateStr = (s['transaction_date'] ?? '').toString();
          if (dateStr.length < 10) continue;
          final key = dateStr.substring(0, 10);
          final amount =
              double.tryParse((s['final_total'] ?? '0').toString()) ?? 0;
          final bucket = buckets[key];
          if (bucket != null) {
            bucket.total += amount;
            bucket.count += 1;
          }
          total += amount;
          count += 1;
        }
        final links = resp.data['links'];
        next = (links is Map) ? links['next'] as String? : null;
      }

      if (!mounted) return;
      setState(() {
        _series = buckets.values.toList()
          ..sort((a, b) => a.date.compareTo(b.date));
        _totalSales = total;
        _txCount = count;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _setRange(int days) {
    if (days == _rangeDays) return;
    setState(() => _rangeDays = days);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kBackgroundColor,
        title: Text(
          AppLocalizations.of(context).translate('reports'),
          style: AppTheme.getTextStyle(
            _themeData.textTheme.titleLarge,
            fontWeight: 600,
            color: kPrimaryTextColor,
          ),
        ),
        iconTheme: const IconThemeData(color: kPrimaryTextColor),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildRangeSelector(context),
            const SizedBox(height: 16),
            _buildStatsRow(context),
            const SizedBox(height: 16),
            _buildChartCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeSelector(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final options = [
      (7, loc.translate('last_7_days')),
      (30, loc.translate('last_30_days')),
      (90, loc.translate('last_90_days')),
    ];
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOutlineColor),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: options.map((o) {
          final selected = o.$1 == _rangeDays;
          return Expanded(
            child: GestureDetector(
              onTap: () => _setRange(o.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? kAccentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  o.$2,
                  style: AppTheme.getTextStyle(
                    _themeData.textTheme.titleSmall,
                    color: selected ? Colors.white : kSecondaryTextColor,
                    fontWeight: 600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final avg = _rangeDays > 0 ? _totalSales / _rangeDays : 0.0;
    return Row(
      children: [
        Expanded(
          child: _statCard(
            label: loc.translate('total_sales'),
            value: Helper().formatCurrency(_totalSales),
            icon: Icons.payments_outlined,
            color: const Color(0xFF0F4C81),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            label: loc.translate('transactions'),
            value: '$_txCount',
            icon: Icons.receipt_long_outlined,
            color: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            label: loc.translate('avg_per_day'),
            value: Helper().formatCurrency(avg),
            icon: Icons.trending_up_rounded,
            color: const Color(0xFFD97706),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kOutlineColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTheme.getTextStyle(
              _themeData.textTheme.bodySmall,
              color: kMutedTextColor,
              fontWeight: 500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: AppTheme.getTextStyle(
                _themeData.textTheme.titleMedium,
                color: kPrimaryTextColor,
                fontWeight: 700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 12, 12),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kOutlineColor),
        boxShadow: const [
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
            padding: const EdgeInsets.only(left: 4, right: 4),
            child: Text(
              loc.translate('sales_overview'),
              style: AppTheme.getTextStyle(
                _themeData.textTheme.titleMedium,
                color: kPrimaryTextColor,
                fontWeight: 700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: _buildChartBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: kErrorColor),
          ),
        ),
      );
    }
    if (_series.isEmpty || _totalSales == 0) {
      return Center(
        child: Text(
          AppLocalizations.of(context).translate('no_sales_data'),
          style: AppTheme.getTextStyle(
            _themeData.textTheme.bodyMedium,
            color: kMutedTextColor,
          ),
        ),
      );
    }

    final spots = <FlSpot>[
      for (int i = 0; i < _series.length; i++)
        FlSpot(i.toDouble(), _series[i].total),
    ];
    final maxY = _series.map((e) => e.total).fold<double>(0, (p, c) => c > p ? c : p);
    final yMax = maxY <= 0 ? 1.0 : maxY * 1.2;
    final yInterval = yMax / 4;
    final xLabelEvery = (_series.length / 6).ceil().clamp(1, 30);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (_series.length - 1).toDouble(),
        minY: 0,
        maxY: yMax,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: kOutlineColor,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: yInterval,
              getTitlesWidget: (value, _) {
                if (value == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    _compactNum(value),
                    style: const TextStyle(
                      fontSize: 10,
                      color: kMutedTextColor,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= _series.length) {
                  return const SizedBox.shrink();
                }
                if (i % xLabelEvery != 0 && i != _series.length - 1) {
                  return const SizedBox.shrink();
                }
                final d = _series[i].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('d MMM').format(d),
                    style: const TextStyle(
                      fontSize: 10,
                      color: kMutedTextColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => kPrimaryTextColor,
            getTooltipItems: (touched) => touched.map((t) {
              final i = t.x.toInt();
              final d = _series[i].date;
              return LineTooltipItem(
                '${DateFormat('d MMM').format(d)}\n'
                '${Helper().formatCurrency(t.y)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: kAccentColor,
            barWidth: 3,
            dotData: FlDotData(
              show: _series.length <= 31,
              getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                radius: 3,
                color: kAccentColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kAccentColor.withValues(alpha: .25),
                  kAccentColor.withValues(alpha: .02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _compactNum(double v) {
    if (v.abs() >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    if (v.abs() >= 1e3) return '${(v / 1e3).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
