import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/database.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/tables.dart';
import '../../core/theme/kash_theme.dart';
import '../shared/category_widgets.dart';
import '../shared/providers.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'manage_categories_fab',
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add category'),
      ),
      body: categories.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No categories yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final c = list[index];
              final color = colorFromHex(c.hexColor);
              return Material(
                color: KashColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  onTap: () => _openEditor(context, ref, existing: c),
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Icon(iconForKey(c.iconKey), color: color, size: 20),
                  ),
                  title: Text(c.name),
                  subtitle: Text(
                    [
                      labelForCategoryKind(c.kind),
                      if (c.isBuiltin) 'Built-in' else 'Custom',
                    ].join(' · '),
                    style: const TextStyle(
                      color: KashColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: c.isFavorite
                            ? 'Remove from Home'
                            : 'Show on Home',
                        onPressed: () => _toggleFavorite(ref, c),
                        icon: Icon(
                          c.isFavorite
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: c.isFavorite
                              ? KashColors.accentGreen
                              : KashColors.textSecondary,
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Future<void> _toggleFavorite(WidgetRef ref, Category category) async {
    final db = await ref.read(databaseProvider.future);
    await db.updateCategory(
      category.id,
      CategoriesCompanion(isFavorite: Value(!category.isFavorite)),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    Category? existing,
  }) async {
    final result = await showDialog<_CategoryEditResult>(
      context: context,
      builder: (context) => _CategoryEditDialog(existing: existing),
    );
    if (result == null || !context.mounted) return;

    final db = await ref.read(databaseProvider.future);
    if (!context.mounted) return;

    if (result.delete && existing != null) {
      await _deleteCategory(context, ref, db, existing);
      return;
    }

    try {
      if (existing == null) {
        final sort = await db.nextCategorySortOrder();
        await db.insertCategory(
          CategoriesCompanion.insert(
            id: const Uuid().v4(),
            name: result.name,
            iconKey: result.iconKey,
            hexColor: result.hexColor,
            isFavorite: Value(result.isFavorite),
            sortOrder: Value(sort),
            isBuiltin: const Value(false),
            kind: Value(result.kind),
          ),
        );
      } else {
        await db.updateCategory(
          existing.id,
          CategoriesCompanion(
            name: Value(result.name),
            iconKey: Value(result.iconKey),
            hexColor: Value(result.hexColor),
            isFavorite: Value(result.isFavorite),
            kind: Value(result.kind),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Couldn’t save category. Try again.')),
        );
      }
    }
  }

  Future<void> _deleteCategory(
    BuildContext context,
    WidgetRef ref,
    AppDatabase db,
    Category category,
  ) async {
    if (category.isBuiltin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Built-in categories can’t be deleted.')),
      );
      return;
    }

    final all = await ref.read(categoriesProvider.future);
    final others = all.where((c) => c.id != category.id).toList();
    if (others.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keep at least one category.'),
          ),
        );
      }
      return;
    }

    final usage = await db.countTransactionsForCategory(category.id);
    String? reassignTo;

    if (usage > 0) {
      if (!context.mounted) return;
      reassignTo = await showDialog<String>(
        context: context,
        builder: (context) => _ReassignCategoryDialog(
          categoryName: category.name,
          usageCount: usage,
          others: others,
        ),
      );
      if (reassignTo == null) return;
    } else {
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete ${category.name}?'),
          content: const Text('This category will be removed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: KashColors.accentRed,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    try {
      await db.deleteCategory(
        categoryId: category.id,
        reassignToCategoryId: reassignTo,
      );
      final filter = ref.read(selectedCategoryFilterProvider);
      if (filter == category.id) {
        ref.read(selectedCategoryFilterProvider.notifier).state = null;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${category.name} deleted.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Couldn’t delete category. Try again.')),
        );
      }
    }
  }
}

class _CategoryEditResult {
  const _CategoryEditResult({
    required this.name,
    required this.iconKey,
    required this.hexColor,
    required this.isFavorite,
    required this.kind,
    this.delete = false,
  });

  final String name;
  final String iconKey;
  final String hexColor;
  final bool isFavorite;
  final CategoryKind kind;
  final bool delete;
}

class _CategoryEditDialog extends StatefulWidget {
  const _CategoryEditDialog({this.existing});

  final Category? existing;

  @override
  State<_CategoryEditDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends State<_CategoryEditDialog> {
  late final TextEditingController _nameController;
  late String _iconKey;
  late String _hexColor;
  late bool _isFavorite;
  late CategoryKind _kind;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _iconKey = e?.iconKey ?? kCategoryIconKeys.first;
    _hexColor = e?.hexColor ?? kCategoryColorHexes.first;
    _isFavorite = e?.isFavorite ?? false;
    _kind = e?.kind ?? CategoryKind.expense;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(
      context,
      _CategoryEditResult(
        name: name,
        iconKey: _iconKey,
        hexColor: _hexColor,
        isFavorite: _isFavorite,
        kind: _kind,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final canDelete = isEdit && !(widget.existing!.isBuiltin);

    return AlertDialog(
      title: Text(isEdit ? 'Edit category' : 'New category'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                autofocus: !isEdit,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Coffee',
                ),
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Type',
                style: TextStyle(color: KashColors.textSecondary),
              ),
              const SizedBox(height: 8),
              SegmentedButton<CategoryKind>(
                segments: const [
                  ButtonSegment(
                    value: CategoryKind.expense,
                    label: Text('Expense'),
                  ),
                  ButtonSegment(
                    value: CategoryKind.income,
                    label: Text('Income'),
                  ),
                  ButtonSegment(
                    value: CategoryKind.both,
                    label: Text('Both'),
                  ),
                ],
                selected: {_kind},
                onSelectionChanged: (s) => setState(() => _kind = s.first),
              ),
              const SizedBox(height: 16),
              const Text(
                'Icon',
                style: TextStyle(color: KashColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final key in kCategoryIconKeys)
                    _PickerCircle(
                      selected: _iconKey == key,
                      color: colorFromHex(_hexColor),
                      child: Icon(
                        iconForKey(key),
                        size: 20,
                        color: colorFromHex(_hexColor),
                      ),
                      onTap: () => setState(() => _iconKey = key),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Color',
                style: TextStyle(color: KashColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final hex in kCategoryColorHexes)
                    _PickerCircle(
                      selected: _hexColor == hex,
                      color: colorFromHex(hex),
                      child: _hexColor == hex
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                      onTap: () => setState(() => _hexColor = hex),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show on Home'),
                subtitle: const Text('Appears in the category row'),
                value: _isFavorite,
                onChanged: (v) => setState(() => _isFavorite = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (canDelete)
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              _CategoryEditResult(
                name: widget.existing!.name,
                iconKey: widget.existing!.iconKey,
                hexColor: widget.existing!.hexColor,
                isFavorite: widget.existing!.isFavorite,
                kind: widget.existing!.kind,
                delete: true,
              ),
            ),
            style: TextButton.styleFrom(foregroundColor: KashColors.accentRed),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

class _PickerCircle extends StatelessWidget {
  const _PickerCircle({
    required this.selected,
    required this.color,
    required this.onTap,
    this.child,
  });

  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: child == null
          ? color
          : color.withValues(alpha: selected ? 0.25 : 0.12),
      shape: CircleBorder(
        side: BorderSide(
          color: selected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _ReassignCategoryDialog extends StatefulWidget {
  const _ReassignCategoryDialog({
    required this.categoryName,
    required this.usageCount,
    required this.others,
  });

  final String categoryName;
  final int usageCount;
  final List<Category> others;

  @override
  State<_ReassignCategoryDialog> createState() =>
      _ReassignCategoryDialogState();
}

class _ReassignCategoryDialogState extends State<_ReassignCategoryDialog> {
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.others.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete ${widget.categoryName}?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.usageCount} '
            '${widget.usageCount == 1 ? 'entry uses' : 'entries use'} '
            'this category. Move them to:',
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedId,
            items: [
              for (final c in widget.others)
                DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _selectedId = v);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedId),
          style: TextButton.styleFrom(foregroundColor: KashColors.accentRed),
          child: const Text('Move & delete'),
        ),
      ],
    );
  }
}
