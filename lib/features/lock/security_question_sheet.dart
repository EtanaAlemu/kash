import 'package:flutter/material.dart';

import '../../core/theme/kash_theme.dart';
import '../shared/info_tip.dart';

const kSecurityQuestionPresets = <String>[
  'What city were you born in?',
  'What was the name of your first pet?',
  'What is your mother’s maiden name?',
  'What was the name of your first school?',
  'What is your favorite food?',
];

/// Ask whether to add a question, then collect question + answer.
/// Returns null if skipped/cancelled, otherwise question and answer.
Future<({String question, String answer})?> offerSecurityQuestionSetup(
  BuildContext context,
) async {
  final want = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const InfoTitle(
        text: 'Security question?',
        tipTitle: 'Why add one?',
        tip:
            'Optional. If you forget your PIN, you can answer this instead of deleting all your data.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Skip'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Add one'),
        ),
      ],
    ),
  );
  if (want != true || !context.mounted) return null;
  return showSecurityQuestionEditor(context);
}

/// Create or edit a security question.
Future<({String question, String answer})?> showSecurityQuestionEditor(
  BuildContext context, {
  String? initialQuestion,
}) {
  return showDialog<({String question, String answer})>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        _SecurityQuestionEditorDialog(initialQuestion: initialQuestion),
  );
}

/// Challenge with the stored question. Returns:
/// - answer string on Continue
/// - `'__wipe__'` if user chooses delete data
/// - null if cancelled
Future<String?> showSecurityQuestionChallenge(
  BuildContext context, {
  required String question,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _SecurityAnswerDialog(question: question),
  );
}

class _SecurityQuestionEditorDialog extends StatefulWidget {
  const _SecurityQuestionEditorDialog({this.initialQuestion});

  final String? initialQuestion;

  @override
  State<_SecurityQuestionEditorDialog> createState() =>
      _SecurityQuestionEditorDialogState();
}

class _SecurityQuestionEditorDialogState
    extends State<_SecurityQuestionEditorDialog> {
  late String _question;
  final _answerController = TextEditingController();
  final _customController = TextEditingController();
  String? _error;
  bool _custom = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuestion?.trim();
    if (initial != null &&
        initial.isNotEmpty &&
        !kSecurityQuestionPresets.contains(initial)) {
      _custom = true;
      _customController.text = initial;
      _question = initial;
    } else {
      _question = (initial != null && kSecurityQuestionPresets.contains(initial))
          ? initial
          : kSecurityQuestionPresets.first;
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _customController.dispose();
    super.dispose();
  }

  void _submit() {
    final question = (_custom ? _customController.text : _question).trim();
    final answer = _answerController.text.trim();
    if (question.isEmpty) {
      setState(() => _error = 'Choose or type a question');
      return;
    }
    if (answer.length < 2) {
      setState(() => _error = 'Answer must be at least 2 characters');
      return;
    }
    Navigator.pop(context, (question: question, answer: answer));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const InfoTitle(
        text: 'Security question',
        tipTitle: 'Tips',
        tip:
            'Pick a question only you would know. Answers aren’t case-sensitive.',
      ),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _custom ? '__custom__' : _question,
                decoration: const InputDecoration(labelText: 'Question'),
                items: [
                  for (final q in kSecurityQuestionPresets)
                    DropdownMenuItem(
                      value: q,
                      child: Text(q, overflow: TextOverflow.ellipsis),
                    ),
                  const DropdownMenuItem(
                    value: '__custom__',
                    child: Text('Write my own…'),
                  ),
                ],
                selectedItemBuilder: (context) => [
                  for (final q in kSecurityQuestionPresets)
                    Text(
                      q,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  const Text(
                    'Write my own…',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _custom = v == '__custom__';
                    if (!_custom) _question = v;
                    _error = null;
                  });
                },
              ),
              if (_custom) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _customController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Your question',
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _answerController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Answer'),
                onSubmitted: (_) => _submit(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(color: KashColors.accentRed),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _SecurityAnswerDialog extends StatefulWidget {
  const _SecurityAnswerDialog({required this.question});

  final String question;

  @override
  State<_SecurityAnswerDialog> createState() => _SecurityAnswerDialogState();
}

class _SecurityAnswerDialogState extends State<_SecurityAnswerDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final answer = _controller.text.trim();
    if (answer.length < 2) {
      setState(() => _error = 'Enter your answer');
      return;
    }
    Navigator.pop(context, answer);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const InfoTitle(
        text: 'Security question',
        tipTitle: 'Forgot PIN',
        tip:
            'Answer the question you set earlier to choose a new PIN. Or delete all data on this phone and start over.',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.question,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Your answer'),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: KashColors.accentRed)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, '__wipe__'),
          style: TextButton.styleFrom(foregroundColor: KashColors.accentRed),
          child: const Text('Delete data instead'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
