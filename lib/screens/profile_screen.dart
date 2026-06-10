import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final fmt = NumberFormat('#,##0.00');
    final totalRecords = provider.allTransactions.length;
    final daysRecorded = provider.allTransactions
        .map((t) => '${t.date.year}-${t.date.month}-${t.date.day}')
        .toSet()
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            // Yellow header with avatar
            Container(
              color: const Color(0xFFFFC107),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 36, color: Colors.grey[400]),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Wallet User',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        SizedBox(height: 4),
                        Text('Personal Expense Tracker',
                            style: TextStyle(
                                fontSize: 13, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                        value: '$totalRecords', label: 'Total Records'),
                  ),
                  _Divider(),
                  Expanded(
                    child: _StatItem(
                        value: '$daysRecorded', label: 'Days Recorded'),
                  ),
                  _Divider(),
                  Expanded(
                    child: _StatItem(
                        value: 'RM ${fmt.format(provider.balance)}',
                        label: 'Net Balance'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Summary section
            _SectionCard(
              title: 'Financial Summary',
              children: [
                _Row(
                  icon: Icons.arrow_downward_rounded,
                  iconColor: Colors.green[600]!,
                  label: 'Total Income',
                  value: 'RM ${fmt.format(provider.totalIncome)}',
                ),
                _Row(
                  icon: Icons.arrow_upward_rounded,
                  iconColor: Colors.red[600]!,
                  label: 'Total Expense',
                  value: 'RM ${fmt.format(provider.totalExpense)}',
                ),
                _Row(
                  icon: Icons.account_balance_wallet,
                  iconColor: const Color(0xFFFFC107),
                  label: 'Net Balance',
                  value: 'RM ${fmt.format(provider.balance)}',
                  valueColor: provider.balance >= 0
                      ? Colors.green[600]!
                      : Colors.red[600]!,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Settings section
            _SectionCard(
              title: 'Settings',
              children: [
                _SettingRow(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () => _showInfo(context, 'Notifications',
                      'Notification settings will be available in a future update.'),
                ),
                _SettingRow(
                  icon: Icons.lock_outline,
                  label: 'Privacy & Security',
                  onTap: () => _showInfo(context, 'Privacy',
                      'All your data is stored locally on this device only.'),
                ),
                _SettingRow(
                  icon: Icons.info_outline,
                  label: 'About My Wallet',
                  onTap: () => _showInfo(context, 'About My Wallet',
                      'My Wallet v1.0.0\nA personal expense tracker built with Flutter.\n\nFeatures: CRUD transactions, charts, budget tracking.'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Danger zone
            _SectionCard(
              title: 'Data',
              children: [
                _SettingRow(
                  icon: Icons.delete_outline,
                  label: 'Clear All Records',
                  labelColor: Colors.red,
                  onTap: () => _confirmClear(context, provider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: Color(0xFFFFC107))),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, TransactionProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Records'),
        content: const Text(
            'This will permanently delete ALL transactions. This cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All records cleared.')),
              );
            },
            child: const Text('Delete All',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black38)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: Colors.grey[200]);
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black45)),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  const _Row({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: labelColor ?? Colors.black54, size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontSize: 14, color: labelColor ?? Colors.black87)),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey[300], size: 20),
          ],
        ),
      ),
    );
  }
}
