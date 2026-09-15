import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/database.dart';
import '../../core/database/database_provider.dart';
import '../../core/notifications/expense_reminder_service.dart';
import '../../core/security/app_lock_providers.dart';
import '../../core/security/app_lock_service.dart';
import '../../core/theme/kash_theme.dart';
import '../lock/pin_pad_screen.dart';
import '../lock/security_question_sheet.dart';
import '../shared/money_edit_dialog.dart';
import '../shared/money_format.dart';
import '../shared/providers.dart';
import 'backup_service.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  bool? _bioSupported;
  bool? _hasSecurityQuestion;

  @override
  void initState() {
    super.initState();
    _loadBioSupport();
    _loadSecurityQuestionFlag();
  }

  Future<void> _loadBioSupport() async {
    try {
      final lock = await ref.read(appLockServiceProvider.future);
      final supported = await lock.deviceSupportsBio();
      if (mounted) setState(() => _bioSupported = supported);
    } catch (_) {
      if (mounted) setState(() => _bioSupported = false);
    }
  }

  Future<void> _loadSecurityQuestionFlag() async {
    try {
      final lock = await ref.read(appLockServiceProvider.future);
      final has = await lock.hasSecurityQuestion();
      if (mounted) setState(() => _hasSecurityQuestion = has);
    } catch (_) {
      if (mounted) setState(() => _hasSecurityQuestion = false);
    }
  }

  Future<AppLockService> _lock() => ref.read(appLockServiceProvider.future);

  Future<void> _toggleAppLock({
    required bool enable,
  }) async {
    final lock = await _lock();
    if (!mounted) return;
    if (enable) {
      final result = await PinPadScreen.show(
        context,
        mode: PinPadMode.create,
      );
      if (result?.pin == null || !mounted) return;
      await lock.setPinAndEnableLock(result!.pin!);
      if (!mounted) return;
      final qa = await offerSecurityQuestionSetup(context);
      if (qa != null) {
        await lock.setSecurityQuestion(
          question: qa.question,
          answer: qa.answer,
        );
      }
      await _loadSecurityQuestionFlag();
      ref.invalidate(appSettingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              qa != null
                  ? 'App lock is on, with a security question for recovery.'
                  : 'App lock is on. You’ll need your PIN to open Kash.',
            ),
          ),
        );
      }
      return;
    }

    // Turning off — verify first
    if (!mounted) return;
    final verified = await PinPadScreen.show(
      context,
      mode: PinPadMode.verify,
      title: 'Enter your PIN',
      subtitle: 'Confirm to turn off app lock',
      onVerify: lock.verifyPin,
      lockoutSeconds: lock.lockoutRemainingSeconds,
      readLockoutSeconds: () => lock.lockoutRemainingSeconds,
      readAttemptsRemaining: () => lock.attemptsRemaining,
    );
    if (verified?.verified != true || !mounted) return;
    await lock.disableLock();
    await _loadSecurityQuestionFlag();
    ref.invalidate(appSettingsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App lock is off.')),
      );
    }
  }

  Future<void> _editSecurityQuestion() async {
    final lock = await _lock();
    if (!mounted) return;

    if (_hasSecurityQuestion == true) {
      final action = await showDialog<String>(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('Security question'),
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Change'),
              onTap: () => Navigator.pop(context, 'change'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: KashColors.accentRed),
              title: const Text('Remove'),
              onTap: () => Navigator.pop(context, 'remove'),
            ),
          ],
        ),
      );
      if (action == null || !mounted) return;
      if (action == 'remove') {
        await _removeSecurityQuestion();
        return;
      }
    }

    final verified = await PinPadScreen.show(
      context,
      mode: PinPadMode.verify,
      title: 'Enter your PIN',
      subtitle: 'Confirm it’s you to change the security question',
      onVerify: lock.verifyPin,
      lockoutSeconds: lock.lockoutRemainingSeconds,
      readLockoutSeconds: () => lock.lockoutRemainingSeconds,
      readAttemptsRemaining: () => lock.attemptsRemaining,
    );
    if (verified?.verified != true || !mounted) return;

    final existing = await lock.securityQuestion();
    if (!mounted) return;
    final qa = await showSecurityQuestionEditor(
      context,
      initialQuestion: existing,
    );
    if (qa == null || !mounted) return;
    await lock.setSecurityQuestion(question: qa.question, answer: qa.answer);
    await _loadSecurityQuestionFlag();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Security question saved.')),
      );
    }
  }

  Future<void> _removeSecurityQuestion() async {
    final lock = await _lock();
    if (!mounted) return;
    final verified = await PinPadScreen.show(
      context,
      mode: PinPadMode.verify,
      title: 'Enter your PIN',
      subtitle: 'Confirm to remove the security question',
      onVerify: lock.verifyPin,
      lockoutSeconds: lock.lockoutRemainingSeconds,
      readLockoutSeconds: () => lock.lockoutRemainingSeconds,
      readAttemptsRemaining: () => lock.attemptsRemaining,
    );
    if (verified?.verified != true || !mounted) return;
    await lock.clearSecurityQuestion();
    await _loadSecurityQuestionFlag();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Security question removed.')),
      );
    }
  }

  Future<void> _pickLockTimeout(int currentSeconds) async {
    const options = <(int, String)>[
      (0, 'Off'),
      (60, 'After 1 minute'),
      (300, 'After 5 minutes'),
      (900, 'After 15 minutes'),
    ];
    final chosen = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Lock when idle'),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              'While Kash is open and you’re not using it. Leaving the app always locks right away.',
              style: TextStyle(
                color: KashColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          for (final (seconds, label) in options)
            ListTile(
              title: Text(label),
              trailing: seconds == currentSeconds
                  ? const Icon(Icons.check, color: KashColors.fab)
                  : null,
              onTap: () => Navigator.pop(context, seconds),
            ),
        ],
      ),
    );
    if (chosen == null || !mounted) return;
    final lock = await _lock();
    await lock.setLockTimeoutSeconds(chosen);
    ref.invalidate(appSettingsProvider);
  }

  String _timeoutLabel(int seconds) {
    switch (seconds) {
      case 0:
        return 'Off — still locks when you leave';
      case 60:
        return 'After 1 minute idle';
      case 300:
        return 'After 5 minutes idle';
      case 900:
        return 'After 15 minutes idle';
      default:
        if (seconds < 60) return 'After $seconds seconds idle';
        final mins = (seconds / 60).round();
        return 'After $mins minutes idle';
    }
  }

  Future<void> _toggleDailyReminder(bool enable) async {
    final db = await ref.read(databaseProvider.future);
    final current = await db.watchAppSettings().first;
    if (enable) {
      final ok = await ExpenseReminderService.instance.sync(enabled: true);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notifications are blocked. Allow them in system settings.',
            ),
          ),
        );
        return;
      }
    } else {
      await ExpenseReminderService.instance.sync(enabled: false);
    }
    await db.upsertAppSettings(
      AppSettingsCompanion(
        id: const Value(1),
        appLockEnabled: Value(current?.appLockEnabled ?? false),
        bioUnlockEnabled: Value(current?.bioUnlockEnabled ?? false),
        hideBalancesOnSwitch: const Value(true),
        encryptionActive: Value(current?.encryptionActive ?? true),
        lockTimeoutSeconds: Value(current?.lockTimeoutSeconds ?? 0),
        dailyExpenseReminderEnabled: Value(enable),
      ),
    );
    ref.invalidate(appSettingsProvider);
  }

  Future<void> _changePin() async {
    final lock = await _lock();
    if (!mounted) return;
    final result = await PinPadScreen.show(
      context,
      mode: PinPadMode.change,
      onVerify: lock.verifyPin,
      lockoutSeconds: lock.lockoutRemainingSeconds,
      readLockoutSeconds: () => lock.lockoutRemainingSeconds,
      readAttemptsRemaining: () => lock.attemptsRemaining,
    );
    if (result?.pin == null || !mounted) return;
    await lock.replacePin(result!.pin!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN updated.')),
      );
    }
  }

  Future<void> _toggleBio(bool enable) async {
    final lock = await _lock();
    try {
      if (enable) {
        if (!await lock.hasPin()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Turn on app lock with a PIN first.'),
              ),
            );
          }
          return;
        }
        await lock.enableBioUnlock();
      } else {
        await lock.disableBioUnlock();
      }
      ref.invalidate(appSettingsProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Couldn’t turn on fingerprint or Face ID. Try again.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final budget = ref.watch(budgetSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settings.when(
        data: (s) {
          final appLock = s?.appLockEnabled ?? false;
          final bioOn = s?.bioUnlockEnabled ?? false;
          final encrypted = s?.encryptionActive ?? true;
          final lockTimeout = s?.lockTimeoutSeconds ?? 0;
          final reminderOn = s?.dailyExpenseReminderEnabled ?? true;
          final cap = budget.valueOrNull?.monthlyCap ?? 0;
          final income = budget.valueOrNull?.monthlyIncome ?? 0;
          final showBio = _bioSupported == true;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              const _SectionLabel('YOUR BUDGET'),
              _SettingsCard(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: const Text('Monthly spending limit'),
                    subtitle: Text(cap > 0 ? formatMoney(cap) : 'Not set — tap to add'),
                    trailing: const Icon(Icons.edit_outlined, size: 18),
                    onTap: () => _editBudgetField(
                      context,
                      ref,
                      title: 'Monthly spending limit',
                      current: cap,
                      income: income,
                      isCap: true,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.payments_outlined),
                    title: const Text('Monthly income'),
                    subtitle: Text(
                      income > 0 ? formatMoney(income) : 'Not set — tap to add',
                    ),
                    trailing: const Icon(Icons.edit_outlined, size: 18),
                    onTap: () => _editBudgetField(
                      context,
                      ref,
                      title: 'Monthly income',
                      current: income,
                      income: income,
                      isCap: false,
                      cap: cap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionLabel('CATEGORIES'),
              _SettingsCard(
                children: [
                  ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: const Text('Manage categories'),
                    subtitle: const Text('Add your own, or edit built-in ones'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/vault/categories'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionLabel('PRIVACY'),
              _SettingsCard(
                children: [
                  ListTile(
                    leading: const Icon(Icons.shield_outlined),
                    title: const Text('Private on this phone'),
                    subtitle:
                        const Text('Your money data never leaves this device'),
                    trailing: Text(
                      encrypted ? 'On' : 'Off',
                      style: TextStyle(
                        color: encrypted
                            ? KashColors.accentGreen
                            : KashColors.accentRed,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.pin_outlined),
                    title: const Text('App lock (PIN)'),
                    subtitle: const Text(
                      'Ask for a 4-digit PIN when opening Kash',
                    ),
                    value: appLock,
                    onChanged: (v) => _toggleAppLock(enable: v),
                  ),
                  if (appLock)
                    ListTile(
                      leading: const Icon(Icons.password_outlined),
                      title: const Text('Change PIN'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _changePin,
                    ),
                  if (appLock)
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: Text(
                        _hasSecurityQuestion == true
                            ? 'Security question'
                            : 'Add security question',
                      ),
                      subtitle: Text(
                        _hasSecurityQuestion == true
                            ? 'Used if you forget your PIN'
                            : 'Optional recovery without deleting data',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _editSecurityQuestion,
                    ),
                  if (appLock)
                    ListTile(
                      leading: const Icon(Icons.timer_outlined),
                      title: const Text('Lock when idle'),
                      subtitle: Text(_timeoutLabel(lockTimeout)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _pickLockTimeout(lockTimeout),
                    ),
                  if (appLock && showBio)
                    SwitchListTile(
                      secondary: const Icon(Icons.fingerprint),
                      title: const Text('Unlock with fingerprint or Face ID'),
                      subtitle: const Text('Faster unlock — PIN still works'),
                      value: bioOn,
                      onChanged: _toggleBio,
                    ),
                  if (appLock && _bioSupported == false)
                    const ListTile(
                      leading: Icon(Icons.fingerprint),
                      title: Text('Fingerprint or Face ID'),
                      subtitle: Text('Not available on this phone'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionLabel('REMINDERS'),
              _SettingsCard(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_outlined),
                    title: const Text('Daily expense reminder'),
                    subtitle: const Text('Every day at 8:30 PM'),
                    value: reminderOn,
                    onChanged: (v) => _toggleDailyReminder(v),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionLabel('BACKUP'),
              _SettingsCard(
                children: [
                  ListTile(
                    leading: const Icon(Icons.folder_outlined),
                    title: const Text('Save a backup'),
                    subtitle: const Text(
                      'Saves a private copy to Downloads or Documents',
                    ),
                    trailing: TextButton(
                      onPressed: () => _exportKash(context, ref),
                      child: const Text('Save'),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: const Text('Restore a backup'),
                    subtitle:
                        const Text('Replace current data with a saved copy'),
                    trailing: TextButton(
                      onPressed: () => _importKash(context, ref),
                      child: const Text('Restore'),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.table_chart_outlined),
                    title: const Text('Save as spreadsheet'),
                    subtitle: const Text(
                      'Save a CSV you can open in Excel or Sheets',
                    ),
                    trailing: TextButton(
                      onPressed: () => _exportCsv(context, ref),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _panicReset(context, ref),
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Delete all data'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: KashColors.accentRed,
                  side: const BorderSide(color: KashColors.accentRed),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Everything stays on your phone. Nothing is uploaded.',
                style: TextStyle(
                  color: KashColors.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(
          child: Text('Couldn’t load settings.'),
        ),
      ),
    );
  }

  Future<void> _editBudgetField(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required double current,
    required double income,
    required bool isCap,
    double? cap,
  }) async {
    final result = await showMoneyEditDialog(
      context,
      title: title,
      current: current > 0 ? current : 0,
      label: title,
      hint: '0',
    );
    if (result == null) return;

    final db = await ref.read(databaseProvider.future);
    await db.upsertBudgetSettings(
      BudgetSettingsCompanion(
        id: const Value(1),
        monthlyCap: Value(isCap ? result : (cap ?? 0)),
        monthlyIncome: Value(isCap ? income : result),
      ),
    );
  }

  Future<void> _exportKash(BuildContext context, WidgetRef ref) async {
    try {
      final db = await ref.read(databaseProvider.future);
      final keys = ref.read(vaultKeyStoreProvider);
      final file = await BackupService(db, keys).exportKashBackup();
      if (file == null || !context.mounted) return;
      debugPrint('Kash backup saved: ${file.path}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup saved:\n${file.path}'),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Couldn’t save the backup. Try again.')),
        );
      }
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    try {
      final db = await ref.read(databaseProvider.future);
      final keys = ref.read(vaultKeyStoreProvider);
      final file = await BackupService(db, keys).exportCsv();
      if (file == null || !context.mounted) return;
      debugPrint('Kash CSV saved: ${file.path}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Spreadsheet saved:\n${file.path}'),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Couldn’t save your spending. Try again.'),
          ),
        );
      }
    }
  }

  Future<void> _importKash(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    final path = result?.files.single.path;
    if (path == null) return;
    if (!path.endsWith('.kash')) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pick a Kash backup file to restore.')),
        );
      }
      return;
    }
    try {
      final db = await ref.read(databaseProvider.future);
      final keys = ref.read(vaultKeyStoreProvider);
      await BackupService(db, keys).importKashBackup(File(path));
      ref.invalidate(transactionsProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(budgetSettingsProvider);
      ref.invalidate(appSettingsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your backup was restored.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Couldn’t restore that backup. Try another file.'),
          ),
        );
      }
    }
  }

  Future<void> _panicReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete everything?'),
        content: const Text(
          'This removes all your spending from this phone. You can’t undo it.',
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
    if (confirmed != true) return;

    try {
      final db = await ref.read(databaseProvider.future);
      final keys = ref.read(vaultKeyStoreProvider);
      await keys.clearPin();
      await db.resetToBlankSlate();
      ref.invalidate(transactionsProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(appSettingsProvider);
      ref.invalidate(budgetSettingsProvider);
      ref.invalidate(appLockServiceProvider);
      ref.read(dataResetTickProvider.notifier).state++;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All spending deleted. Fresh start.')),
        );
      }
    } catch (e, st) {
      debugPrint('Delete all data failed: $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Couldn’t delete data. Try again.')),
        );
      }
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              letterSpacing: 1.1,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KashColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KashColors.border),
      ),
      child: Column(children: children),
    );
  }
}
