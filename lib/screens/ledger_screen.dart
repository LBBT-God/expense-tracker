import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';
import 'detail_screen.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  DateTime _month = DateTime.now();

  void _prevMonth() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1));

  void _nextMonth() {
    final next = DateTime(_month.year, _month.month + 1);
    if (!next.isAfter(DateTime(DateTime.now().year, DateTime.now().month))) {
      setState(() => _month = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final fmt = NumberFormat('#,##0.00');

    final all = provider.allTransactions
        .where((t) =>
            t.date.year == _month.year && t.date.month == _month.month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final income = all
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final expense = all
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);

    // Group by day
    final grouped = <String, List<Transaction>>{};
    for (final t in all) {
      final key = DateFormat('yyyy-MM-dd').format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    final keys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Yellow header ──
          Container(
            color: const Color(0xFFFFC107),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    // Month selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left,
                              color: Colors.black87, size: 22),
                          onPressed: _prevMonth,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: _pickMonth,
                          child: Row(
                            children: [
                              Text(
                                DateFormat('MMMM yyyy').format(_month),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down,
                                  size: 20, color: Colors.black54),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.chevron_right,
                              color: Colors.black87, size: 22),
                          onPressed: _nextMonth,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Income / Expense row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Income',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54)),
                              const SizedBox(height: 2),
                              Text(
                                fmt.format(income),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Expense',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54)),
                              const SizedBox(height: 2),
                              Text(
                                fmt.format(expense),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Transaction list ──
          Expanded(
            child: all.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 88),
                    itemCount: keys.length,
                    itemBuilder: (ctx, i) {
                      final key = keys[i];
                      final items = grouped[key]!;
                      final date = DateTime.parse(key);
                      final dayExp = items
                          .where((t) => t.type == TransactionType.expense)
                          .fold(0.0, (s, t) => s + t.amount);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: Row(
                              children: [
                                Text(
                                  DateFormat('MMM d  ·  EEEE').format(date),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black45),
                                ),
                                const Spacer(),
                                if (dayExp > 0)
                                  Text(
                                    'Exp: ${fmt.format(dayExp)}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black38),
                                  ),
                              ],
                            ),
                          ),
                          // White card group
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: items.asMap().entries.map((e) {
                                final isLast = e.key == items.length - 1;
                                return Column(
                                  children: [
                                    TransactionTile(
                                      transaction: e.value,
                                      onTap: () => Navigator.push(
                                        ctx,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              DetailScreen(id: e.value.id),
                                        ),
                                      ),
                                    ),
                                    if (!isLast)
                                      Divider(
                                          height: 1,
                                          indent: 72,
                                          color: Colors.grey[100]),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Month'),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: 280,
          height: 220,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (_, i) {
              final m = DateTime(now.year, i + 1);
              final sel = _month.month == m.month && _month.year == m.year;
              return GestureDetector(
                onTap: () {
                  setState(() => _month = m);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFFFFC107)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    DateFormat('MMM').format(m),
                    style: TextStyle(
                      fontWeight:
                          sel ? FontWeight.bold : FontWeight.normal,
                      color: sel ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text('No records this month',
              style: TextStyle(color: Colors.grey[400], fontSize: 16)),
          const SizedBox(height: 8),
          Text('Tap Record to add one',
              style: TextStyle(color: Colors.grey[350], fontSize: 13)),
        ],
      ),
    );
  }
}
