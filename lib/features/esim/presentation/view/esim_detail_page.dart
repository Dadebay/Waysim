import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/esim_compatibility.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/labels.dart';
import '../../../../core/widgets/app_button.dart';
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
import '../esim_installer.dart';
import '../esim_labels.dart';

class EsimDetailPage extends StatefulWidget {
  const EsimDetailPage({super.key, required this.id});

  final String id;
  @override
  State<EsimDetailPage> createState() => _EsimDetailPageState();
}

class _EsimDetailPageState extends State<EsimDetailPage> {
  late Future<Result<Esim>> _load;
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
}

class _Detail extends StatefulWidget {
  const _Detail({required this.esim});

  final Esim esim;

  @override
  State<_Detail> createState() => _DetailState();
}

class _DetailState extends State<_Detail> {
  late int _platformTab = Theme.of(context).platform == TargetPlatform.iOS
      ? 0
      : 1;
  late final Future<bool> _oneTap = getIt<EsimCompatibility>()
      .supportsOneTapInstall();

  @override
  Widget build(BuildContext context) {
    final esim = widget.esim;
    final l10n = context.l10n;
    final c = context.colors;
    final archived = esim.status.isArchived;

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
        if (!archived) ...[
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            key: const ValueKey('esim-qr-card'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.installByQr, style: context.text.h3),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Container(
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
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            key: const ValueKey('esim-manual-card'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.installManual, style: context.text.h3),
                const SizedBox(height: AppSpacing.md),
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
                  value: _grouped(esim.iccid),
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
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Notice(text: l10n.esimKeepWarning),
          const SizedBox(height: AppSpacing.md),
          _Notice(text: l10n.esimRoamingWarning, info: true),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            key: const ValueKey('esim-instructions-card'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.instructionsTitle, style: context.text.h3),
                const SizedBox(height: AppSpacing.md),
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
        ],
        const SizedBox(height: AppSpacing.lg),
        _Usage(esim: esim),
      ],
    );
  }

  static String _grouped(String digits) => [
    for (var i = 0; i < digits.length; i += 4)
      digits.substring(i, (i + 4).clamp(0, digits.length)),
  ].join(' ');
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
  const _Steps({required this.steps});

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
