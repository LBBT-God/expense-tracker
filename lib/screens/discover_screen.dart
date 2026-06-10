import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final now = DateTime.now();
    final fmt = NumberFormat('#,##0.00');

    final monthTxns = provider.allTransactions.where((t) =>
        t.date.year == now.year && t.date.month == now.month).toList();

    final income = monthTxns
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final expense = monthTxns
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);
    final balance = income - expense;

    final budget = provider.monthlyBudget;
    final remaining = budget - expense;
    final budgetPct = budget > 0 ? (expense / budget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            // Header
            Container(
              color: const Color(0xFFFFC107),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: const Text(
                'Discover',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),

            // ── Monthly Bill card ──
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Monthly Bill',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const Spacer(),
                      Text(
                        DateFormat('MMM yyyy').format(now),
                        style: const TextStyle(
                            color: Colors.black45, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _BillItem(
                          label: 'Income',
                          value: 'RM ${fmt.format(income)}',
                          color: Colors.green[600]!),
                      _BillItem(
                          label: 'Expense',
                          value: 'RM ${fmt.format(expense)}',
                          color: Colors.red[600]!),
                      _BillItem(
                          label: 'Balance',
                          value: 'RM ${fmt.format(balance)}',
                          color: balance >= 0
                              ? Colors.green[600]!
                              : Colors.red[600]!),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Monthly Budget card ──
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Monthly Budget',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showBudgetDialog(context, provider, budget),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            budget > 0 ? 'Edit Budget' : '+ Set Budget',
                            style: const TextStyle(
                                color: Color(0xFFFFC107),
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (budget == 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined,
                              size: 36, color: Colors.black26),
                          SizedBox(height: 8),
                          Text('Tap "+ Set Budget" to start',
                              style: TextStyle(
                                  color: Colors.black38, fontSize: 13)),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        // Circular progress
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: budgetPct,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation(
                                  budgetPct >= 1.0
                                      ? Colors.red
                                      : const Color(0xFFFFC107),
                                ),
                                strokeWidth: 8,
                              ),
                              Text(
                                '${(budgetPct * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _BudgetRow(
                                  label: 'Monthly Budget',
                                  value: 'RM ${fmt.format(budget)}'),
                              const SizedBox(height: 6),
                              _BudgetRow(
                                  label: 'This Month Expense',
                                  value: 'RM ${fmt.format(expense)}'),
                              const SizedBox(height: 6),
                              _BudgetRow(
                                label: 'Remaining',
                                value: 'RM ${fmt.format(remaining)}',
                                valueColor: remaining < 0
                                    ? Colors.red[600]!
                                    : Colors.green[600]!,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Stats card ──
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Stats',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          icon: Icons.receipt_long,
                          label: 'Total Records',
                          value:
                              '${provider.allTransactions.length}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          icon: Icons.calendar_today,
                          label: 'Days Recorded',
                          value: _countDays(provider.allTransactions)
                              .toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          icon: Icons.arrow_downward,
                          label: 'Total Income',
                          value: 'RM ${fmt.format(provider.totalIncome)}',
                          iconColor: Colors.green[600]!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          icon: Icons.arrow_upward,
                          label: 'Total Expense',
                          value: 'RM ${fmt.format(provider.totalExpense)}',
                          iconColor: Colors.red[600]!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _countDays(List<Transaction> txns) {
    return txns
        .map((t) =>
            '${t.date.year}-${t.date.month}-${t.date.day}')
        .toSet()
        .length;
  }

  Future<void> _showBudgetDialog(
      BuildContext context, TransactionProvider provider, double current) async {
    final ctrl = TextEditingController(
        text: current > 0 ? current.toStringAsFixed(2) : '');
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            prefixText: 'RM  ',
            hintText: '0.00',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.trim()) ?? 0;
              provider.setBudget(val);
              Navigator.pop(context);
            },
            child: const Text('Save',
                style: TextStyle(
                    color: Color(0xFFFFC107),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Reusable widgets ──

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BillItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _BillItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: Colors.black45)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _BudgetRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style:
                const TextStyle(color: Colors.black45, fontSize: 12)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: valueColor ?? Colors.black87)),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  const _StatBox(
      {required this.icon,
      required this.label,
      required this.value,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: iconColor ?? const Color(0xFFFFC107), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(label,
                    style: const TextStyle(
                        color: Colors.black45, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
