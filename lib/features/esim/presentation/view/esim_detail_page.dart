import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/esim_compatibility.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/labels.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_hero.dart';
import '../../../../core/widgets/copy_field.dart';
import '../../../../core/widgets/country_row.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/flag_icon.dart';
import '../../../../core/widgets/segmented_tabs.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/usage_progress.dart';
import '../../domain/entities/esim.dart';
import '../cubit/esim_list_cubit.dart';
import '../esim_install_tracker.dart';
import '../esim_installer.dart';
import '../open_device_settings.dart';
import '../esim_labels.dart';

class EsimDetailPage extends StatefulWidget {
  const EsimDetailPage({
    super.key,
    required this.id,
    this.showNetworkResetOnOpen = false,
  });

  final String id;
  final bool showNetworkResetOnOpen;
  @override
  State<EsimDetailPage> createState() => _EsimDetailPageState();
}

class _EsimDetailPageState extends State<EsimDetailPage> {
  late Future<Result<Esim>> _load;
  bool _guideRequested = false;
  @override
  void initState() {
    super.initState();
    _load = context.read<EsimListCubit>().detail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esims = context.watch<EsimListCubit>();
    final esim = esims.byId(widget.id);

    final c = context.colors;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        backgroundColor: c.surface,
        leading: IconButton(
          tooltip: l10n.searchBack,
          onPressed: () => context.pop(),
          icon: HugeIcon(icon: AppIcons.back, size: 24, color: c.textPrimary),
        ),
        title: Text(l10n.esimDetailTitle, style: context.text.h2),
        centerTitle: true,
      ),
      body: FutureBuilder<Result<Esim>>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final result = snapshot.data;
          if (result case Error(:final failure)) {
            return ErrorView(
              failure: failure,
              onRetry: () => setState(() {
                _load = esims.detail(widget.id);
              }),
            );
          }
          final detail = esim ?? result!.dataOrNull!;
          _openGuideIfStuck(detail);
          return RefreshIndicator(
            onRefresh: () async {
              await esims.detail(widget.id, refresh: true);
            },
            child: _Detail(esim: detail),
          );
        },
      ),
    );
  }

  void _openGuideIfStuck(Esim detail) {
    if (_guideRequested) return;
    final stuck = EsimInstallTracker.stuckFor(detail, DateTime.now()) != null;
    if (!widget.showNetworkResetOnOpen &&
        (!stuck || EsimInstallTracker.guideWasShown(widget.id))) {
      return;
    }
    _guideRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final refreshed = await context.read<EsimListCubit>().detail(
        widget.id,
        refresh: true,
      );
      if (!mounted) return;
      final current = refreshed.dataOrNull ?? detail;
      if (EsimInstallTracker.stuckFor(current, DateTime.now()) != null) {
        await EsimInstallTracker.markGuideShown(widget.id);
        if (!mounted) return;
        await _showNetworkResetGuide(context);
      }
    });
  }
}

class _Detail extends StatefulWidget {
  const _Detail({required this.esim});

  final Esim esim;

  @override
  State<_Detail> createState() => _DetailState();
}

class _DetailState extends State<_Detail> with WidgetsBindingObserver {
  Timer? _ticker;

  late int _platformTab = Theme.of(context).platform == TargetPlatform.iOS
      ? 0
      : 1;
  int _installTab = 0;
  late final Future<bool> _oneTap = getIt<EsimCompatibility>()
      .supportsOneTapInstall();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(seconds: 20), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    final started = EsimInstallTracker.startedAt(widget.esim.id);
    if (started == null) return;
    AppLogger.i(
      '[ESIM-INSTALL] back in app id=${widget.esim.id} '
      'elapsed=${DateTime.now().difference(started).inSeconds}s '
      'status=${widget.esim.status.name}; refreshing',
    );
    unawaited(_refreshAfterResume());
  }

  Future<void> _refreshAfterResume() async {
    final cubit = context.read<EsimListCubit>();
    final result = await cubit.detail(widget.esim.id, refresh: true);
    final status = result.dataOrNull?.status;
    if (status != null &&
        EsimInstallTracker.completedSinceStart(widget.esim.id, status)) {
      await EsimInstallTracker.clear(widget.esim.id, reason: status.name);
    }
  }

  void _tick() {
    if (!mounted) return;
    final esim = widget.esim;
    if (EsimInstallTracker.completedSinceStart(esim.id, esim.status)) {
      unawaited(EsimInstallTracker.clear(esim.id, reason: esim.status.name));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final esim = widget.esim;
    final l10n = context.l10n;
    final c = context.colors;
    final archived = esim.status.isArchived;
    final stuck = EsimInstallTracker.stuckFor(esim, DateTime.now());
    final usageFirst =
        esim.status == EsimStatus.installed || esim.status == EsimStatus.active;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.xxxl,
      ),
      children: [
        _SectionCard(
          key: const ValueKey('esim-header-card'),
          child: Column(
            children: [
              _Header(esim: esim),
              if (!archived)
                FutureBuilder<bool>(
                  future: _oneTap,
                  builder: (context, snapshot) => snapshot.data == true
                      ? Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.lg),
                          child: _OneTap(esim: esim),
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
        if (!archived && stuck != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _StuckCard(minutes: stuck.inMinutes),
        ],
        if (usageFirst || archived) ...[
          const SizedBox(height: AppSpacing.lg),
          _Usage(esim: esim),
        ],
        if (!archived) ...[
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            key: const ValueKey('esim-install-card'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedTabs(
                  labels: [l10n.installByQr, l10n.installManual],
                  selectedIndex: _installTab,
                  onChanged: (i) => setState(() => _installTab = i),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_installTab == 0)
                  _QrBody(key: const ValueKey('esim-qr-card'), esim: esim)
                else
                  _ManualBody(
                    key: const ValueKey('esim-manual-card'),
                    esim: esim,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Notice(text: l10n.esimKeepWarning),
          const SizedBox(height: AppSpacing.md),
          _Notice(text: l10n.esimRoamingWarning, info: true),
          const SizedBox(height: AppSpacing.lg),
          _Collapsible(
            key: const ValueKey('esim-instructions-card'),
            title: l10n.instructionsTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedTabs(
                  labels: [l10n.tabIphone, l10n.tabAndroid],
                  selectedIndex: _platformTab,
                  onChanged: (i) => setState(() => _platformTab = i),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Steps(
                  steps: _platformTab == 0
                      ? [
                          l10n.iosStep1,
                          l10n.iosStep2,
                          l10n.iosStep3,
                          l10n.iosStep4,
                          l10n.iosStep5,
                        ]
                      : [
                          l10n.androidStep1,
                          l10n.androidStep2,
                          l10n.androidStep3,
                          l10n.androidStep4,
                          l10n.androidStep5,
                        ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Collapsible(
            key: const ValueKey('esim-trouble-card'),
            title: l10n.installTroubleTitle,
            initiallyExpanded: stuck != null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Steps(
                  steps: [
                    l10n.installTroubleStep1,
                    l10n.installTroubleStep2,
                    _platformTab == 0
                        ? l10n.installTroubleStepResetIos
                        : l10n.installTroubleStepResetAndroid,
                    l10n.installTroubleStep4,
                    l10n.installTroubleStep5,
                  ],
                ),
                if (Theme.of(context).platform != TargetPlatform.iOS) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    key: const ValueKey('esim-open-settings'),
                    label: l10n.installOpenSettings,
                    icon: AppIcons.settings,
                    size: AppButtonSize.md,
                    onPressed: openDeviceSettings,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.installOpenSettingsHint,
                    style: context.text.caption.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (!usageFirst && !archived) ...[
          const SizedBox(height: AppSpacing.lg),
          _Usage(esim: esim),
        ],
      ],
    );
  }

  static String _grouped(String digits) => [
    for (var i = 0; i < digits.length; i += 4)
      digits.substring(i, (i + 4).clamp(0, digits.length)),
  ].join(' ');
}

class _QrBody extends StatelessWidget {
  const _QrBody({super.key, required this.esim});

  final Esim esim;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: c.border),
          ),
          child: Semantics(
            label: l10n.installByQr,
            image: true,
            child: QrImageView(
              data: esim.lpa,
              size: 200,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF161D2B),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF161D2B),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.installQrNote,
          textAlign: TextAlign.center,
          style: context.text.bodySm.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        _Notice(text: l10n.installQrRetryNote, info: true),
      ],
    );
  }
}

class _ManualBody extends StatelessWidget {
  const _ManualBody({super.key, required this.esim});

  final Esim esim;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CopyField(label: l10n.esimSmdp, value: esim.smdpAddress),
        const SizedBox(height: AppSpacing.sm),
        CopyField(
          label: l10n.esimActivationCode,
          value: esim.activationCode,
          monospace: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        CopyField(
          label: l10n.esimIccid,
          value: _DetailState._grouped(esim.iccid),
          copyValue: esim.iccid,
          monospace: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        CopyField(
          key: const ValueKey('esim-full-activation-code'),
          label: l10n.esimFullActivationCode,
          value: esim.lpa,
          monospace: true,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.installManualIosHint,
          style: context.text.bodySm.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.esimFullActivationCodeHint,
          style: context.text.bodySm.copyWith(color: c.textSecondary),
        ),
      ],
    );
  }
}

class _Collapsible extends StatelessWidget {
  const _Collapsible({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: AppSpacing.md),
          shape: const Border(),
          collapsedShape: const Border(),
          initiallyExpanded: initiallyExpanded,
          title: Text(title, style: context.text.h3),
          children: [child],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.esim});

  final Esim esim;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return AppHero(
      tag: AppHeroTags.esimHeader(esim.id),
      child: Material(
        type: MaterialType.transparency,
        child: Row(
          children: [
            esim.isRegion
                ? const RegionIcon(size: 48)
                : FlagIcon(esim.destinationCode, size: 48),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.esimTitle(esim), style: context.text.h2),
                  Text(
                    l10n.esimPlan(esim),
                    style: context.text.bodySm.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            StatusBadge(label: esim.status.label(l10n), tone: esim.status.tone),
          ],
        ),
      ),
    );
  }
}

class _OneTap extends StatelessWidget {
  const _OneTap({required this.esim});

  final Esim esim;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final by = esim.installBy;
    if (esim.status == EsimStatus.installed ||
        esim.status == EsimStatus.active) {
      return _Notice(text: l10n.installAlreadyIssued, info: true);
    }
    return Column(
      children: [
        AppButton(
          label: l10n.installOneTap,
          icon: AppIcons.phone,
          onPressed: () => installEsim(context, esim, fromDetail: true),
        ),
        if (by != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.installOneTapNote(l10n.longDate(by)),
            textAlign: TextAlign.center,
            style: context.text.caption.copyWith(color: c.textSecondary),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.installArrivalNote,
          textAlign: TextAlign.center,
          style: context.text.caption.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),

        _Notice(text: l10n.installStuckNote, info: true),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          key: const ValueKey('esim-network-reset-guide'),
          label: l10n.installNetworkResetGuide,
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.md,
          onPressed: () => _showNetworkResetGuide(context),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StuckCard extends StatelessWidget {
  const _StuckCard({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      key: const ValueKey('esim-stuck-card'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Notice(
          text: '${l10n.installStuckTitle(minutes)}\n${l10n.installStuckBody}',
        ),
      ],
    );
  }
}

Future<void> _showNetworkResetGuide(BuildContext context) {
  final l10n = context.l10n;
  return showAppSheet<void>(
    context,
    title: l10n.installNetworkResetGuide,
    closeLabel: l10n.actionClose,
    builder: (sheetContext) {
      final c = sheetContext.colors;
      final ios = Theme.of(sheetContext).platform == TargetPlatform.iOS;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ios
                        ? l10n.installTroubleStepResetIos
                        : l10n.installTroubleStepResetAndroid,
                    style: sheetContext.text.body.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Notice(text: l10n.installNetworkResetWarning),
                  if (ios) ...[
                    const SizedBox(height: AppSpacing.lg),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(AppRadius.sm + 4),
                        border: Border.all(color: c.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.xs,
                        ),
                        child: _Steps(
                          key: const ValueKey('esim-network-reset-steps'),
                          steps: [
                            l10n.installResetStep1,
                            l10n.installResetStep2,
                            l10n.installResetStep3,
                            l10n.installResetStep4,
                            l10n.installResetStep5,
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
          if (!ios)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.xl,
              ),
              child: AppButton(
                key: const ValueKey('esim-network-reset-open-settings'),
                label: l10n.installOpenSettings,
                icon: AppIcons.settings,
                onPressed: openDeviceSettings,
              ),
            ),
        ],
      );
    },
  );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.info = false});

  final String text;

  final bool info;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: info ? c.primarySubtle : c.warningSubtle,
        borderRadius: BorderRadius.circular(AppRadius.sm + 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HugeIcon(
              icon: info ? AppIcons.info : AppIcons.warning,
              size: 22,
              color: info ? c.link : c.warning,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(text, style: context.text.bodySm)),
          ],
        ),
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({super.key, required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        for (final (i, text) in steps.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.primarySubtle,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: context.text.caption.copyWith(
                      color: c.link,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(text, style: context.text.body),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Usage extends StatelessWidget {
  const _Usage({required this.esim});

  final Esim esim;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final now = DateTime.now();
    final updated = esim.updatedAt;
    final canTopUp =
        esim.topUpSupported &&
        esim.status != EsimStatus.expired &&
        esim.status != EsimStatus.provisioning;

    return _SectionCard(
      key: const ValueKey('esim-usage-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.usageTitle, style: context.text.h3)),
              if (updated != null)
                Text(
                  l10n.esimUpdated(l10n.ago(updated, now)),
                  style: context.text.caption.copyWith(color: c.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (esim.isUnlimited || esim.volumeBytes == null)
            Text(l10n.usageUnlimitedNote, style: context.text.bodySm)
          else ...[
            Text(
              l10n.esimLeftOf(
                l10n.dataSize(esim.remainingBytes ?? 0),
                l10n.dataSize(esim.volumeBytes!),
              ),
              style: context.text.bodyMed.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            UsageProgress(remainingFraction: esim.remainingFraction),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            esim.daysLeft(now) != null
                ? l10n.esimDaysLeft(esim.daysLeft(now)!)
                : l10n.esimValidityFromFirst,
            style: context.text.bodySm.copyWith(color: c.textSecondary),
          ),
          if (canTopUp) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.topUpPackage,
              variant: AppButtonVariant.secondary,
              onPressed: () =>
                  context.push(AppRoute.esimTopUp.withParams({'id': esim.id})),
            ),
          ],
        ],
      ),
    );
  }
}
