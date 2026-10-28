import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_icons.dart';
import '../../core/di/injector.dart';
import '../../core/network/network_info.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/no_connection_art.dart';

class ConnectionGate extends StatefulWidget {
  const ConnectionGate({super.key, required this.child, this.networkInfo});

  final Widget child;

  final NetworkInfo? networkInfo;

  @override
  State<ConnectionGate> createState() => _ConnectionGateState();
}

enum _Phase { checking, offline, through }

class _ConnectionGateState extends State<ConnectionGate> {
  late final NetworkInfo _info = widget.networkInfo ?? getIt<NetworkInfo>();
  StreamSubscription<bool>? _changes;
  _Phase _phase = _Phase.checking;
  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    unawaited(_check());
  }

  @override
  void dispose() {
    _changes?.cancel();
    super.dispose();
  }

  Future<bool> _isOnline() async {
    try {
      return await _info.isConnected;
    } catch (_) {
      return true;
    }
  }

  Future<void> _check() async {
    final online = await _isOnline();
    if (!mounted) return;
    if (online) return _goThrough();
    setState(() => _phase = _Phase.offline);
    _changes ??= _info.onConnectivityChanged.listen((connected) {
      if (connected) _goThrough();
    }, onError: (_) {});
  }

  void _goThrough() {
    if (!mounted || _phase == _Phase.through) return;
    _changes?.cancel();
    _changes = null;
    setState(() {
      _phase = _Phase.through;
      _retrying = false;
    });
  }

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);

    final results = await Future.wait([
      _isOnline(),
      Future<void>.delayed(const Duration(milliseconds: 900)),
    ]);
    if (!mounted) return;
    if (results.first as bool) return _goThrough();
    setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 350),
    child: switch (_phase) {
      _Phase.checking => ColoredBox(
        key: const ValueKey('connection-checking'),
        color: context.colors.background,
        child: const SizedBox.expand(),
      ),
      _Phase.offline => _OfflineScreen(
        key: const ValueKey('connection-offline'),
        retrying: _retrying,
        onRetry: _retry,
        onContinue: _goThrough,
      ),
      _Phase.through => KeyedSubtree(
        key: const ValueKey('connection-through'),
        child: widget.child,
      ),
    },
  );
}

class _OfflineScreen extends StatelessWidget {
  const _OfflineScreen({
    super.key,
    required this.retrying,
    required this.onRetry,
    required this.onContinue,
  });

  final bool retrying;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final reduce = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      key: const ValueKey('connection-offline-screen'),
      backgroundColor: c.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: reduce ? 1 : 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 18),
                child: child,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const NoConnectionArt(size: 260),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            l10n.noConnectionTitle,
                            style: context.text.h1,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.noConnectionBody,
                            style: context.text.body.copyWith(
                              color: c.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _WaitingPill(label: l10n.noConnectionWaiting),
                        ],
                      ),
                    ),
                  ),
                ),
                AppButton(
                  label: l10n.actionTryAgain,
                  icon: AppIcons.refresh,
                  loading: retrying,
                  onPressed: onRetry,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l10n.noConnectionContinue,
                  variant: AppButtonVariant.ghost,
                  onPressed: onContinue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaitingPill extends StatefulWidget {
  const _WaitingPill({required this.label});

  final String label;

  @override
  State<_WaitingPill> createState() => _WaitingPillState();
}

class _WaitingPillState extends State<_WaitingPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse
        ..stop()
        ..value = 1;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 0.25, end: 1).animate(_pulse),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: c.warning,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              widget.label,
              style: context.text.caption.copyWith(
                color: c.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
