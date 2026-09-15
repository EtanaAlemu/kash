import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_provider.dart';
import '../../core/security/app_lock_providers.dart';
import '../../core/security/app_lock_service.dart';
import '../../core/theme/kash_theme.dart';
import '../shared/providers.dart';
import 'pin_pad_screen.dart';
import 'security_question_sheet.dart';

/// Gates the app behind PIN / fingerprint when lock is enabled.
class UnlockGate extends ConsumerStatefulWidget {
  const UnlockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UnlockGate> createState() => UnlockGateState();
}

class UnlockGateState extends ConsumerState<UnlockGate>
    with WidgetsBindingObserver {
  bool _checking = true;
  bool _unlocked = false;
  bool _lockEnabled = false;
  bool _preferBio = false;
  bool _showPinPad = false;
  bool _obscureOverlay = false;
  AppLockService? _lock;
  int _lockTimeoutSeconds = 0;
  DateTime? _backgroundedAt;
  Timer? _idleTimer;

  /// Nested navigator so lock-screen dialogs work above [MaterialApp.router].
  final _lockNavKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      await ref.read(databaseProvider.future);
      final lock = await ref.read(appLockServiceProvider.future);
      final enabled = await lock.isLockEnabled();
      final bio = enabled && await lock.isBioUnlockEnabled();
      final settings = await lock.settings();
      if (!mounted) return;
      setState(() {
        _lock = lock;
        _lockEnabled = enabled;
        _preferBio = bio;
        _lockTimeoutSeconds = settings?.lockTimeoutSeconds ?? 0;
        _checking = false;
        _unlocked = !enabled;
        _showPinPad = enabled && !bio;
      });
      if (enabled && bio) {
        await _tryBio();
      }
      if (_unlocked && _lockEnabled) {
        _restartIdleTimer();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _checking = false;
          _unlocked = true;
          _lockEnabled = false;
        });
      }
    }
  }

  Future<void> _syncLockFlags() async {
    try {
      final lock = await ref.read(appLockServiceProvider.future);
      final enabled = await lock.isLockEnabled();
      final bio = enabled && await lock.isBioUnlockEnabled();
      final settings = await lock.settings();
      if (!mounted) return;
      setState(() {
        _lock = lock;
        _lockEnabled = enabled;
        _preferBio = bio;
        _lockTimeoutSeconds = settings?.lockTimeoutSeconds ?? 0;
        if (!enabled) {
          _unlocked = true;
          _showPinPad = false;
          _idleTimer?.cancel();
        }
      });
      if (_unlocked && enabled) {
        _restartIdleTimer();
      }
    } catch (_) {}
  }

  void _markUnlocked() {
    setState(() {
      _unlocked = true;
      _showPinPad = false;
    });
    _restartIdleTimer();
  }

  void _lockNow() {
    _idleTimer?.cancel();
    if (!_lockEnabled || !_unlocked) return;
    setState(() {
      _unlocked = false;
      _showPinPad = !_preferBio;
      _obscureOverlay = false;
    });
    if (_preferBio) {
      _tryBio();
    }
  }

  void _restartIdleTimer() {
    _idleTimer?.cancel();
    if (!_lockEnabled || !_unlocked) return;
    // `0` = idle lock off; leaving the app still locks immediately.
    if (_lockTimeoutSeconds <= 0) return;
    _idleTimer = Timer(Duration(seconds: _lockTimeoutSeconds), _lockNow);
  }

  void _onUserActivity() {
    if (_lockEnabled && _unlocked) {
      _restartIdleTimer();
    }
  }

  Future<void> _tryBio() async {
    final lock = _lock;
    if (lock == null) return;
    final ok = await lock.unlockWithBio();
    if (!mounted) return;
    if (ok) {
      _markUnlocked();
    } else {
      setState(() => _showPinPad = true);
    }
  }

  Future<bool> _verifyPin(String pin) async {
    final lock = _lock;
    if (lock == null) return false;
    return lock.verifyPin(pin);
  }

  Future<void> _onPinResult(PinPadResult result) async {
    if (result.forgotPin) {
      await _onForgotPin();
      return;
    }
    if (result.verified) {
      _markUnlocked();
    }
  }

  BuildContext? get _dialogContext =>
      _lockNavKey.currentContext ?? (mounted ? context : null);

  Future<void> _onForgotPin() async {
    final dialogContext = _dialogContext;
    if (dialogContext == null) return;

    final AppLockService lock =
        _lock ?? await ref.read(appLockServiceProvider.future);
    final hasQuestion = await lock.hasSecurityQuestion();
    final question = hasQuestion ? await lock.securityQuestion() : null;

    if (!mounted || !dialogContext.mounted) return;

    if (question != null && question.isNotEmpty) {
      final result = await showSecurityQuestionChallenge(
        dialogContext,
        question: question,
      );
      if (result == null || !mounted || !dialogContext.mounted) return;

      if (result == '__wipe__') {
        await _confirmAndWipe(dialogContext);
        return;
      }

      final ok = await lock.verifySecurityAnswer(result);
      if (!mounted || !dialogContext.mounted) return;
      if (!ok) {
        ScaffoldMessenger.maybeOf(dialogContext)?.showSnackBar(
          const SnackBar(content: Text('That answer wasn’t right. Try again.')),
        );
        return;
      }

      final newPin = await PinPadScreen.show(
        dialogContext,
        mode: PinPadMode.create,
        title: 'Choose a new PIN',
        subtitle: 'Your data stays on this phone',
      );
      if (newPin?.pin == null || !mounted) return;
      await lock.replacePin(newPin!.pin!);
      if (!mounted) return;
      _markUnlocked();
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('PIN reset. You’re back in.')),
      );
      return;
    }

    await _confirmAndWipe(dialogContext);
  }

  Future<void> _confirmAndWipe(BuildContext dialogContext) async {
    final confirmed = await showDialog<bool>(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: const Text('Forgot PIN?'),
        content: const Text(
          'Without a security question, the only way back in is to delete all data on this phone and start over. This can’t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: KashColors.accentRed),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

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
    if (!mounted) return;
    setState(() {
      _unlocked = true;
      _lockEnabled = false;
      _preferBio = false;
      _showPinPad = false;
    });
    _idleTimer?.cancel();
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text('All data deleted. You can set a new PIN in Settings.'),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _idleTimer?.cancel();
      if (_unlocked) {
        _backgroundedAt ??= DateTime.now();
        // Always cover amounts in the app switcher.
        setState(() => _obscureOverlay = true);
      }
    } else if (state == AppLifecycleState.resumed) {
      setState(() => _obscureOverlay = false);
      _onResumed();
    }
  }

  Future<void> _onResumed() async {
    await _syncLockFlags();
    if (!mounted) return;
    _backgroundedAt = null;
    if (!_lockEnabled) return;

    // Leaving the app always requires unlock when lock is on.
    if (_unlocked) {
      _lockNow();
    }
  }

  Widget _lockContent(BuildContext context) {
    if (_showPinPad) {
      return PinPadScreen(
        mode: PinPadMode.unlock,
        onVerify: _verifyPin,
        showForgotPin: true,
        lockoutSeconds: _lock?.lockoutRemainingSeconds ?? 0,
        readLockoutSeconds: () => _lock?.lockoutRemainingSeconds ?? 0,
        readAttemptsRemaining: () => _lock?.attemptsRemaining ?? 0,
        onResult: _onPinResult,
      );
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, size: 48, color: KashColors.fab),
              const SizedBox(height: 16),
              Text(
                'Unlock Kash to continue',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_preferBio) ...[
                FilledButton.icon(
                  onPressed: _tryBio,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock with fingerprint or Face ID'),
                ),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: () => setState(() => _showPinPad = true),
                child: Text(_preferBio ? 'Use PIN instead' : 'Enter PIN'),
              ),
              TextButton(
                onPressed: _onForgotPin,
                child: const Text('Forgot PIN?'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(dataResetTickProvider, (prev, next) {
      if (prev != next) {
        setState(() {
          _unlocked = true;
          _lockEnabled = false;
          _preferBio = false;
          _showPinPad = false;
        });
        _idleTimer?.cancel();
        _syncLockFlags();
      }
    });

    // Pick up timeout changes from Settings without a full restart.
    ref.listen(appSettingsProvider, (prev, next) {
      final seconds = next.valueOrNull?.lockTimeoutSeconds;
      if (seconds != null && seconds != _lockTimeoutSeconds) {
        setState(() => _lockTimeoutSeconds = seconds);
        if (_unlocked && _lockEnabled) {
          _restartIdleTimer();
        }
      }
      final enabled = next.valueOrNull?.appLockEnabled ?? false;
      final bio = next.valueOrNull?.bioUnlockEnabled ?? false;
      if (enabled != _lockEnabled || bio != _preferBio) {
        _syncLockFlags();
      }
    });

    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_unlocked) {
      return Navigator(
        key: _lockNavKey,
        pages: [
          MaterialPage<void>(
            key: ValueKey('lock-$_showPinPad'),
            child: _lockContent(context),
          ),
        ],
        onDidRemovePage: (_) {},
      );
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onUserActivity(),
      child: Stack(
        children: [
          widget.child,
          if (_obscureOverlay)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black,
                child: Center(child: Icon(Icons.lock_rounded, size: 48)),
              ),
            ),
        ],
      ),
    );
  }
}
