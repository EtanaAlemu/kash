import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/kash_theme.dart';

enum PinPadMode {
  /// Create a new PIN (enter + confirm).
  create,
  /// Unlock the app.
  unlock,
  /// Verify current PIN before a sensitive action.
  verify,
  /// Change PIN: verify current, then create new.
  change,
}

class PinPadResult {
  const PinPadResult({this.pin, this.verified = false, this.forgotPin = false});

  final String? pin;
  final bool verified;
  final bool forgotPin;
}

/// Full-screen 4-digit PIN pad.
class PinPadScreen extends StatefulWidget {
  const PinPadScreen({
    super.key,
    required this.mode,
    this.title,
    this.subtitle,
    this.onVerify,
    this.showForgotPin = false,
    this.lockoutSeconds = 0,
    this.readLockoutSeconds,
    this.readAttemptsRemaining,
    this.onResult,
  });

  final PinPadMode mode;
  final String? title;
  final String? subtitle;

  /// For unlock/verify/change: return true if PIN is correct.
  final Future<bool> Function(String pin)? onVerify;

  final bool showForgotPin;
  final int lockoutSeconds;

  /// Called after a failed verify to refresh lockout / remaining tries.
  final int Function()? readLockoutSeconds;
  final int Function()? readAttemptsRemaining;

  /// When set, called instead of `Navigator.pop` (for embedding above the router).
  final void Function(PinPadResult result)? onResult;

  static Future<PinPadResult?> show(
    BuildContext context, {
    required PinPadMode mode,
    String? title,
    String? subtitle,
    Future<bool> Function(String pin)? onVerify,
    bool showForgotPin = false,
    int lockoutSeconds = 0,
    int Function()? readLockoutSeconds,
    int Function()? readAttemptsRemaining,
  }) {
    return Navigator.of(context, rootNavigator: true).push<PinPadResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PinPadScreen(
          mode: mode,
          title: title,
          subtitle: subtitle,
          onVerify: onVerify,
          showForgotPin: showForgotPin,
          lockoutSeconds: lockoutSeconds,
          readLockoutSeconds: readLockoutSeconds,
          readAttemptsRemaining: readAttemptsRemaining,
        ),
      ),
    );
  }

  @override
  State<PinPadScreen> createState() => _PinPadScreenState();
}

class _PinPadScreenState extends State<PinPadScreen>
    with SingleTickerProviderStateMixin {
  String _entry = '';
  String? _firstPin;
  String? _error;
  bool _busy = false;
  late int _lockoutLeft;
  late final AnimationController _shake;

  /// change flow: 0 = enter current, 1 = enter new, 2 = confirm new
  int _changeStep = 0;

  @override
  void initState() {
    super.initState();
    _lockoutLeft = widget.lockoutSeconds;
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (_lockoutLeft > 0) _tickLockout();
  }

  @override
  void dispose() {
    if (_shake.isAnimating) {
      _shake.stop();
    }
    _shake.dispose();
    super.dispose();
  }

  void _tickLockout() async {
    while (_lockoutLeft > 0 && mounted) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _lockoutLeft--);
    }
  }

  String get _title {
    if (widget.title != null) return widget.title!;
    switch (widget.mode) {
      case PinPadMode.create:
        return _firstPin == null ? 'Create a PIN' : 'Confirm your PIN';
      case PinPadMode.unlock:
        return 'Enter your PIN';
      case PinPadMode.verify:
        return 'Enter your PIN';
      case PinPadMode.change:
        if (_changeStep == 0) return 'Enter current PIN';
        if (_changeStep == 1) return 'Choose a new PIN';
        return 'Confirm new PIN';
    }
  }

  String get _subtitle {
    if (_lockoutLeft > 0) {
      return 'Try again in ${_formatLockout(_lockoutLeft)}';
    }
    if (widget.subtitle != null) return widget.subtitle!;
    switch (widget.mode) {
      case PinPadMode.create:
        return _firstPin == null
            ? 'Use 4 digits to lock Kash on this phone'
            : 'Enter the same PIN again';
      case PinPadMode.unlock:
        return 'Unlock Kash';
      case PinPadMode.verify:
        return 'Confirm it’s you';
      case PinPadMode.change:
        if (_changeStep == 0) return 'Confirm it’s you';
        if (_changeStep == 1) return 'Pick 4 new digits';
        return 'Enter the new PIN again';
    }
  }

  String _formatLockout(int seconds) {
    if (seconds >= 60) {
      final minutes = (seconds / 60).ceil();
      return minutes == 1 ? '1 minute' : '$minutes minutes';
    }
    return seconds == 1 ? '1 second' : '$seconds seconds';
  }

  Future<void> _applyLockoutFromService() async {
    final left = widget.readLockoutSeconds?.call() ?? 0;
    if (left <= 0 || !mounted) return;
    setState(() => _lockoutLeft = left);
    _tickLockout();
  }

  String _incorrectPinMessage() {
    final left = widget.readAttemptsRemaining?.call();
    if (left != null && left > 0) {
      return left == 1
          ? 'Incorrect PIN · 1 try left'
          : 'Incorrect PIN · $left tries left';
    }
    final lockout = widget.readLockoutSeconds?.call() ?? 0;
    if (lockout > 0) {
      return 'Too many wrong tries. Wait ${_formatLockout(lockout)}.';
    }
    return 'Incorrect PIN';
  }

  void _finish(PinPadResult result) {
    final cb = widget.onResult;
    if (cb != null) {
      cb(result);
    } else if (Navigator.of(context).canPop()) {
      Navigator.pop(context, result);
    }
  }

  Future<void> _onDigit(String d) async {
    if (!mounted || _busy || _lockoutLeft > 0 || _entry.length >= 4) return;
    HapticFeedback.selectionClick();
    setState(() {
      _entry += d;
      _error = null;
    });
    if (_entry.length == 4) await _submit(_entry);
  }

  void _onBackspace() {
    if (!mounted || _busy || _entry.isEmpty) return;
    setState(() {
      _entry = _entry.substring(0, _entry.length - 1);
      _error = null;
    });
  }

  Future<void> _submit(String pin) async {
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      switch (widget.mode) {
        case PinPadMode.create:
          if (_firstPin == null) {
            if (!mounted) return;
            setState(() {
              _firstPin = pin;
              _entry = '';
              _busy = false;
            });
            return;
          }
          if (pin != _firstPin) {
            await _fail('PINs didn’t match. Try again.');
            if (!mounted) return;
            setState(() => _firstPin = null);
            return;
          }
          if (mounted) {
            _finish(PinPadResult(pin: pin, verified: true));
          }
          return;

        case PinPadMode.unlock:
        case PinPadMode.verify:
          final ok = await widget.onVerify?.call(pin) ?? false;
          if (!mounted) return;
          if (ok) {
            _finish(const PinPadResult(verified: true));
          } else {
            await _fail(_incorrectPinMessage());
            await _applyLockoutFromService();
          }
          return;

        case PinPadMode.change:
          if (_changeStep == 0) {
            final ok = await widget.onVerify?.call(pin) ?? false;
            if (!mounted) return;
            if (!ok) {
              await _fail(_incorrectPinMessage());
              await _applyLockoutFromService();
              return;
            }
            setState(() {
              _changeStep = 1;
              _entry = '';
              _busy = false;
            });
            return;
          }
          if (_changeStep == 1) {
            if (!mounted) return;
            setState(() {
              _firstPin = pin;
              _changeStep = 2;
              _entry = '';
              _busy = false;
            });
            return;
          }
          if (pin != _firstPin) {
            await _fail('PINs didn’t match. Try again.');
            if (!mounted) return;
            setState(() {
              _changeStep = 1;
              _firstPin = null;
            });
            return;
          }
          if (mounted) {
            _finish(PinPadResult(pin: pin, verified: true));
          }
      }
    } finally {
      if (mounted && _busy) setState(() => _busy = false);
    }
  }

  Future<void> _fail(String message) async {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _error = message;
      _entry = '';
      _busy = false;
    });
    if (!mounted) return;
    try {
      await _shake.forward(from: 0);
    } catch (_) {
      // Controller may already be disposed if the screen was closed.
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = _lockoutLeft > 0;

    return Scaffold(
      backgroundColor: KashColors.background,
      appBar: AppBar(
        leading: widget.onResult == null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _finish(const PinPadResult()),
              )
            : null,
        automaticallyImplyLeading: widget.onResult == null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.lock_rounded, size: 40, color: KashColors.fab),
            const SizedBox(height: 20),
            Text(
              _title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _subtitle,
              style: const TextStyle(color: KashColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            AnimatedBuilder(
              animation: _shake,
              builder: (context, child) {
                final t = _shake.value;
                final dx = (t < 0.5 ? t : 1 - t) * 16 *
                    ((t * 10).floor().isEven ? 1 : -1);
                return Transform.translate(offset: Offset(dx, 0), child: child);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _entry.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? KashColors.fab : Colors.transparent,
                      border: Border.all(
                        color: filled ? KashColors.fab : KashColors.border,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 24,
              child: _error != null
                  ? Text(
                      _error!,
                      style: const TextStyle(color: KashColors.accentRed),
                    )
                  : null,
            ),
            const Spacer(),
            _Keypad(
              enabled: !locked && !_busy,
              onDigit: _onDigit,
              onBackspace: _onBackspace,
            ),
            if (widget.showForgotPin)
              TextButton(
                onPressed: locked
                    ? null
                    : () => _finish(const PinPadResult(forgotPin: true)),
                child: const Text('Forgot PIN?'),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.enabled,
    required this.onDigit,
    required this.onBackspace,
  });

  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget key(String label, {VoidCallback? onTap, Widget? child}) {
      return SizedBox(
        width: 84,
        height: 64,
        child: Material(
          color: KashColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: child ??
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? KashColors.textPrimary
                          : KashColors.textSecondary,
                    ),
                  ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          for (final row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final d in row) key(d, onTap: () => onDigit(d)),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 84, height: 64),
              key('0', onTap: () => onDigit('0')),
              key(
                '',
                onTap: onBackspace,
                child: Icon(
                  Icons.backspace_outlined,
                  color: enabled
                      ? KashColors.textPrimary
                      : KashColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
