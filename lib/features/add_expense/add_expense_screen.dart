import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/database.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/tables.dart';
import '../../core/theme/kash_theme.dart';
import '../shared/category_widgets.dart';
import '../shared/money_format.dart';
import '../shared/providers.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key, this.transactionId});

  /// When set, the screen edits an existing transaction instead of creating one.
  final String? transactionId;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TxnType _type = TxnType.expense;
  String? _categoryId;
  DateTime _timestamp = DateTime.now();
  bool _saving = false;
  bool _loading = false;
  bool _notFound = false;

  bool get _isEditing => widget.transactionId != null;
  bool get _isExpense => _type == TxnType.expense;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loading = true;
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    try {
      final db = await ref.read(databaseProvider.future);
      final txn = await db.getTransactionById(widget.transactionId!);
      if (!mounted) return;
      if (txn == null) {
        setState(() {
          _loading = false;
          _notFound = true;
        });
        return;
      }
      setState(() {
        _amountController.text = txn.amount.toStringAsFixed(
          txn.amount == txn.amount.roundToDouble() ? 0 : 2,
        );
        _noteController.text = txn.merchant;
        _type = txn.type;
        _categoryId = txn.categoryId;
        _timestamp = txn.timestamp;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _notFound = true;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _setType(TxnType type) {
    if (_type == type) return;
    setState(() {
      _type = type;
      _categoryId = null;
    });
  }

  List<Category> _matchingCategories(List<Category> cats) {
    return cats.where((c) => categoryMatchesTxnType(c.kind, _type)).toList();
  }

  Future<void> _save() async {
    final raw =
        _amountController.text.replaceAll(r'$', '').replaceAll(',', '').trim();
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a category')),
      );
      return;
    }

    final merchant = _noteController.text.trim();
    setState(() => _saving = true);
    try {
      final db = await ref.read(databaseProvider.future);
      if (_isEditing) {
        await db.updateTransaction(
          widget.transactionId!,
          TransactionsCompanion(
            categoryId: Value(_categoryId!),
            amount: Value(amount),
            type: Value(_type),
            merchant: Value(merchant),
            timestamp: Value(_timestamp),
          ),
        );
      } else {
        await db.into(db.transactions).insert(
              TransactionsCompanion.insert(
                id: const Uuid().v4(),
                categoryId: _categoryId!,
                amount: amount,
                type: _type,
                merchant: Value(merchant),
                timestamp: _timestamp,
              ),
            );
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Couldn’t save. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this entry?'),
        content: const Text(
          'This removes it from your history. You can’t undo it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: KashColors.accentRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      final db = await ref.read(databaseProvider.future);
      await db.deleteTransaction(widget.transactionId!);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Couldn’t delete. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (!mounted) return;
    setState(() {
      _timestamp = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _timestamp.hour,
        time?.minute ?? _timestamp.minute,
      );
    });
  }

  String get _title {
    if (_isEditing) {
      return _isExpense ? 'Edit Expense' : 'Edit Income';
    }
    return _isExpense ? 'Add Expense' : 'Add Income';
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final amountColor =
        _isExpense ? KashColors.textPrimary : KashColors.accentGreen;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
          title: const Text('Edit'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_notFound) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
          title: const Text('Not found'),
        ),
        body: const Center(
          child: Text('This entry was already deleted.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(_title),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete',
              onPressed: _saving ? null : _confirmDelete,
              icon: const Icon(
                Icons.delete_outline,
                color: KashColors.accentRed,
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SegmentedButton<TxnType>(
            segments: const [
              ButtonSegment(
                value: TxnType.expense,
                label: Text('Expense'),
                icon: Icon(Icons.arrow_upward_rounded, size: 18),
              ),
              ButtonSegment(
                value: TxnType.income,
                label: Text('Income'),
                icon: Icon(Icons.arrow_downward_rounded, size: 18),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (s) => _setType(s.first),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            autofocus: !_isEditing,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(color: amountColor.withValues(alpha: 0.35)),
              prefixText: r'$ ',
              prefixStyle: TextStyle(
                color: amountColor,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
              border: InputBorder.none,
              filled: false,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Select Category',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          categories.when(
            data: (cats) {
              final matching = _matchingCategories(cats);
              if (_categoryId != null &&
                  !matching.any((c) => c.id == _categoryId)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() {
                    _categoryId =
                        matching.isNotEmpty ? matching.first.id : null;
                  });
                });
              } else if (_categoryId == null && matching.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _categoryId == null) {
                    setState(() => _categoryId = matching.first.id);
                  }
                });
              }

              if (matching.isEmpty) {
                return const Text(
                  'No categories for this type — add one in Settings',
                  style: TextStyle(color: KashColors.textSecondary),
                );
              }

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final c in matching)
                    CategoryChip(
                      label: c.name,
                      iconKey: c.iconKey,
                      hexColor: c.hexColor,
                      selected: _categoryId == c.id,
                      onTap: () => setState(() => _categoryId = c.id),
                    ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('$e'),
          ),
          const SizedBox(height: 28),
          Text(
            'Details (Optional)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(formatTxnTime(_timestamp)),
            trailing: TextButton(
              onPressed: _pickDate,
              child: const Text('Change Date'),
            ),
          ),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.notes_outlined),
              hintText: _isExpense
                  ? 'Where did you spend? (optional)'
                  : 'Where did it come from? (optional)',
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor:
                  _isExpense ? KashColors.fab : KashColors.accentGreen,
            ),
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _isEditing
                        ? 'Save changes'
                        : (_isExpense ? 'Save expense' : 'Save income'),
                  ),
          ),
        ],
      ),
    );
  }
}
