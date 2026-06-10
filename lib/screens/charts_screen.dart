import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  TransactionType _viewType = TransactionType.expense;
  String _period = 'Week'; // Week, Month, Year

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final all = provider.allTransactions
        .where((t) => t.type == _viewType)
        .toList();

    final chartData = _buildChartData(all);
    final values = chartData.values.toList();
    final labels = chartData.keys.toList();

    final total = all.fold(0.0, (s, t) => s + t.amount);
    final avg = all.isNotEmpty ? total / _uniqueDays(all) : 0.0;

    // Category breakdown
    final catMap = <Category, double>{};
    for (final t in all) {
      catMap[t.category] = (catMap[t.category] ?? 0) + t.amount;
    }
    final catList = catMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final fmt = NumberFormat('#,##0.00');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Yellow header
          Container(
            color: const Color(0xFFFFC107),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Expense / Income toggle
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TypeToggle(
                          label: 'Expense',
                          selected: _viewType == TransactionType.expense,
                          onTap: () => setState(
                              () => _viewType = TransactionType.expense),
                        ),
                        const SizedBox(width: 24),
                        _TypeToggle(
                          label: 'Income',
                          selected: _viewType == TransactionType.income,
                          onTap: () => setState(
                              () => _viewType = TransactionType.income),
                        ),
                      ],
                    ),
                  ),
                  // Period tabs
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: ['Week', 'Month', 'Year'].map((p) {
                        final sel = p == _period;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _period = p),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color:
                                    sel ? Colors.black87 : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                p,
                                style: TextStyle(
                                  color: sel ? Colors.white : Colors.black54,
                                  fontWeight: sel
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chart area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                // Summary
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: RM ${fmt.format(total)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Daily avg: RM ${fmt.format(avg)}',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black45),
                      ),
                      const SizedBox(height: 16),
                      // Line chart
                      if (values.isNotEmpty)
                        _LineChart(values: values, color: const Color(0xFFFFC107))
                      else
                        Container(
                          height: 140,
                          alignment: Alignment.center,
                          child: const Text('No data yet',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      const SizedBox(height: 4),
                      // Labels
                      if (values.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _buildDisplayLabels(labels)
                              .map((l) => Text(l,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black38)))
                              .toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Category breakdown
                if (catList.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Category Breakdown',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ...catList.map((e) {
                          final pct = total > 0 ? e.value / total : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(e.key.icon,
                                            style: const TextStyle(
                                                fontSize: 20)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                e.key.label,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${(pct * 100).toStringAsFixed(1)}%',
                                                style: const TextStyle(
                                                    color: Colors.black38,
                                                    fontSize: 12),
                                              ),
                                              const Spacer(),
                                              Text(
                                                'RM ${fmt.format(e.value)}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: pct,
                                              minHeight: 6,
                                              backgroundColor:
                                                  Colors.grey[200],
                                              valueColor:
                                                  const AlwaysStoppedAnimation(
                                                      Color(0xFFFFC107)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _buildChartData(List<Transaction> txns) {
    final now = DateTime.now();
    final data = <String, double>{};

    if (_period == 'Week') {
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        data[DateFormat('E').format(d)] = 0;
      }
      for (final t in txns) {
        for (int i = 6; i >= 0; i--) {
          final d = now.subtract(Duration(days: i));
          if (t.date.year == d.year &&
              t.date.month == d.month &&
              t.date.day == d.day) {
            final k = DateFormat('E').format(d);
            data[k] = (data[k] ?? 0) + t.amount;
            break;
          }
        }
      }
    } else if (_period == 'Month') {
      final days = DateTime(now.year, now.month + 1, 0).day;
      for (int i = 1; i <= days; i++) {
        data['$i'] = 0;
      }
      for (final t in txns) {
        if (t.date.year == now.year && t.date.month == now.month) {
          final k = '${t.date.day}';
          data[k] = (data[k] ?? 0) + t.amount;
        }
      }
    } else {
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      for (final m in months) { data[m] = 0; }
      for (final t in txns) {
        if (t.date.year == now.year) {
          final k = months[t.date.month - 1];
          data[k] = (data[k] ?? 0) + t.amount;
        }
      }
    }
    return data;
  }

  List<String> _buildDisplayLabels(List<String> all) {
    if (all.length <= 7) return all;
    final step = (all.length / 6).ceil();
    final result = <String>[];
    for (int i = 0; i < all.length; i++) {
      result.add(i % step == 0 ? all[i] : '');
    }
    return result;
  }

  int _uniqueDays(List<Transaction> txns) {
    final days =
        txns.map((t) => '${t.date.year}-${t.date.month}-${t.date.day}').toSet();
    return days.isEmpty ? 1 : days.length;
  }
}

class _TypeToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeToggle(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.black87 : Colors.black45,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: selected ? Colors.black87 : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<double> values;
  final Color color;

  const _LineChart({required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: CustomPaint(
        painter: _LineChartPainter(values: values, color: color),
        size: Size.infinite,
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _LineChartPainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final max = values.reduce((a, b) => a > b ? a : b);
    if (max == 0) return;

    const pl = 8.0, pr = 8.0, pt = 12.0, pb = 8.0;
    final w = size.width - pl - pr;
    final h = size.height - pt - pb;

    final step = values.length > 1 ? w / (values.length - 1) : w;

    final points = <Offset>[
      for (int i = 0; i < values.length; i++)
        Offset(pl + i * step, pt + h - (values[i] / max) * h),
    ];

    // Draw average dashed line
    final avg = values.fold(0.0, (a, b) => a + b) / values.length;
    final avgY = pt + h - (avg / max) * h;
    final dashPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    double x = pl;
    while (x < size.width - pr) {
      canvas.drawLine(Offset(x, avgY), Offset(x + 8, avgY), dashPaint);
      x += 14;
    }

    // Draw line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    if (points.length > 1) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // Draw dots
    for (final pt2 in points) {
      canvas.drawCircle(
          pt2, 5, Paint()..color = Colors.white..style = PaintingStyle.fill);
      canvas.drawCircle(
          pt2,
          5,
          Paint()
            ..color = color
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.values != values || old.color != color;
}
