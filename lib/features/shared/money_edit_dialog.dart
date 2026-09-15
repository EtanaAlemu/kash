import 'package:flutter/material.dart';

/// Dialog that owns its [TextEditingController] so it isn't disposed mid-close.
Future<double?> showMoneyEditDialog(
  BuildContext context, {
  required String title,
  required double current,
  String? label,
  String? hint,
}) {
  return showDialog<double>(
    context: context,
    builder: (context) => _MoneyEditDialog(
      title: title,
      current: current,
      label: label ?? title,
      hint: hint,
    ),
  );
}

class _MoneyEditDialog extends StatefulWidget {
  const _MoneyEditDialog({
    required this.title,
    required this.current,
    required this.label,
    this.hint,
  });

  final String title;
  final double current;
  final String label;
  final String? hint;

  @override
  State<_MoneyEditDialog> createState() => _MoneyEditDialogState();
}

class _MoneyEditDialogState extends State<_MoneyEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.current.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(
      _controller.text.replaceAll(',', '').trim(),
    );
    if (value == null || value <= 0) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onSubmitted: (_) => _save(),
        decoration: InputDecoration(
          prefixText: r'$ ',
          hintText: widget.hint,
          labelText: widget.label,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
