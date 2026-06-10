import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class AddRecordScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddRecordScreen({super.key, this.transaction});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  TransactionType _type = TransactionType.expense;
  Category _category = Category.food;
  String _amountStr = '0';
  String _note = '';
  DateTime _date = DateTime.now();

  bool get _isEditing => widget.transaction != null;

  static const _expenseCats = [
    Category.food,
    Category.transport,
    Category.shopping,
    Category.entertainment,
    Category.health,
    Category.education,
    Category.other,
  ];

  static const _incomeCats = [
    Category.salary,
    Category.other,
  ];

  List<Category> get _cats =>
      _type == TransactionType.expense ? _expenseCats : _incomeCats;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);

    if (_isEditing) {
      final t = widget.transaction!;
      _type = t.type;
      _tabCtrl.index = t.type == TransactionType.expense ? 0 : 1;
      _category = t.category;
      _amountStr = t.amount % 1 == 0
          ? t.amount.toInt().toString()
          : t.amount.toStringAsFixed(2);
      _note = t.note;
      _date = t.date;
    }

    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() {
          _type = _tabCtrl.index == 0
              ? TransactionType.expense
              : TransactionType.income;
          _category = _cats.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountStr) ?? 0;

  void _onKey(String k) {
    setState(() {
      if (k == '⌫') {
        if (_amountStr.length > 1) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        } else {
          _amountStr = '0';
        }
      } else if (k == '.') {
        if (!_amountStr.contains('.')) _amountStr += '.';
      } else {
        if (_amountStr == '0') {
          _amountStr = k;
        } else if (_amountStr.contains('.')) {
          final parts = _amountStr.split('.');
          if (parts[1].length < 2) _amountStr += k;
        } else {
          if (_amountStr.length < 8) _amountStr += k;
        }
      }
    });
  }

  void _save() {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }

    final provider = context.read<TransactionProvider>();
    final t = Transaction(
      id: _isEditing ? widget.transaction!.id : const Uuid().v4(),
      title: _category.label,
      amount: _amount,
      category: _category,
      date: _date,
      type: _type,
      note: _note,
    );

    if (_isEditing) {
      provider.update(t);
    } else {
      provider.add(t);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Yellow header with tab bar
          Container(
            color: const Color(0xFFFFC107),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TabBar(
                            controller: _tabCtrl,
                            tabs: const [
                              Tab(text: 'Expense'),
                              Tab(text: 'Income'),
                            ],
                            labelColor: Colors.black87,
                            unselectedLabelColor: Colors.black45,
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            unselectedLabelStyle:
                                const TextStyle(fontSize: 16),
                            indicator: const UnderlineTabIndicator(
                              borderSide:
                                  BorderSide(width: 3, color: Colors.black87),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 15)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Amount display
          Container(
            color: const Color(0xFFFFF8E1),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                const Text('RM',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _amountStr,
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Category grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date row
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMM d, yyyy').format(_date),
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down,
                              size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Category',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black45)),
                  const SizedBox(height: 12),
                  // Category icons grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _cats.length,
                    itemBuilder: (_, i) {
                      final cat = _cats[i];
                      final selected = cat == _category;
                      return GestureDetector(
                        onTap: () => setState(() => _category = cat),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFFFC107)
                                    : Colors.grey[100],
                                shape: BoxShape.circle,
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFFFC107)
                                              .withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(cat.icon,
                                    style: const TextStyle(fontSize: 26)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cat.label,
                              style: TextStyle(
                                fontSize: 11,
                                color: selected
                                    ? const Color(0xFFFFC107)
                                    : Colors.black54,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Note field
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Add a note...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon:
                          Icon(Icons.edit_note, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onChanged: (v) => _note = v,
                    controller: TextEditingController(text: _note),
                  ),
                ],
              ),
            ),
          ),

          // Numpad
          Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Column(
              children: [
                _NumRow(keys: const ['7', '8', '9'], onKey: _onKey),
                const SizedBox(height: 6),
                _NumRow(keys: const ['4', '5', '6'], onKey: _onKey),
                const SizedBox(height: 6),
                _NumRow(keys: const ['1', '2', '3'], onKey: _onKey),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _NumKey(label: '.', onTap: () => _onKey('.')),
                    _NumKey(label: '0', onTap: () => _onKey('0')),
                    _NumKey(
                      label: '⌫',
                      onTap: () => _onKey('⌫'),
                      isIcon: true,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: GestureDetector(
                        onTap: _save,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFFFC107)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }
}

class _NumRow extends StatelessWidget {
  final List<String> keys;
  final ValueChanged<String> onKey;

  const _NumRow({required this.keys, required this.onKey});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: keys
          .map((k) => _NumKey(label: k, onTap: () => onKey(k)))
          .toList(),
    );
  }
}

class _NumKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isIcon;

  const _NumKey({
    required this.label,
    required this.onTap,
    this.isIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: isIcon
                  ? const Icon(Icons.backspace_outlined,
                      size: 20, color: Colors.black54)
                  : Text(
                      label,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
