import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/notifications/expense_reminder_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/kash_theme.dart';
import 'features/lock/unlock_gate.dart';
import 'features/shared/providers.dart';

class KashApp extends ConsumerStatefulWidget {
  const KashApp({super.key});

  @override
  ConsumerState<KashApp> createState() => _KashAppState();
}

class _KashAppState extends ConsumerState<KashApp> {
  late final GoRouter _router = buildAppRouter();
  var _scheduledInitialReminderSync = false;

  @override
  void initState() {
    super.initState();
    ExpenseReminderService.instance.onNotificationTap = _openFromReminder;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final details =
          await ExpenseReminderService.instance.notificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp == true &&
          details?.notificationResponse?.payload ==
              ExpenseReminderService.payloadAdd) {
        _openFromReminder(ExpenseReminderService.payloadAdd);
      }
    });
  }

  void _openFromReminder(String? payload) {
    if (payload != ExpenseReminderService.payloadAdd) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _router.go('/home');
      _router.push('/add');
    });
  }

  void _syncReminder(bool enabled) {
    ExpenseReminderService.instance.sync(enabled: enabled);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appSettingsProvider, (prev, next) {
      next.whenData((s) {
        _syncReminder(s?.dailyExpenseReminderEnabled ?? true);
      });
    });

    final settings = ref.watch(appSettingsProvider).valueOrNull;
    if (settings != null && !_scheduledInitialReminderSync) {
      _scheduledInitialReminderSync = true;
      Future.microtask(
        () => _syncReminder(settings.dailyExpenseReminderEnabled),
      );
    }

    return MaterialApp.router(
      title: 'Kash',
      debugShowCheckedModeBanner: false,
      theme: buildKashTheme(),
      routerConfig: _router,
      builder: (context, child) {
        return UnlockGate(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
