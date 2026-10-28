import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/async_cubit.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/labels.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_hero.dart';
import '../../../../core/widgets/country_row.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/flag_icon.dart';
import '../../../../core/widgets/package_tile.dart';
import '../../../../core/widgets/segmented_tabs.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/tab_switcher.dart';
import '../../../config/presentation/cubit/config_cubit.dart';
import '../../../purchase/presentation/purchase_flow.dart';
import '../../../purchase/presentation/purchase_subject.dart';
import '../../domain/entities/destination.dart';
import '../../domain/entities/esim_package.dart';
import '../cubit/catalog_cubit.dart';
import '../widgets/compat_banner.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../widgets/package_details_sheet.dart';

/// A country or region: compatibility, the plans, details and the buy button.
class DestinationPage extends StatefulWidget {
  const DestinationPage({super.key, required this.code, this.packageId});

  final String code;
  final String? packageId;
  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    final catalog = context.read<CatalogCubit>();
    if (catalog.state.byCode(widget.code) == null) {
      _loading = true;
      catalog.ensureLocation(widget.code).then((_) {
        if (mounted) setState(() => _loading = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogCubit>().state;
    final code = widget.code;
    final destination = catalog.byCode(code);

    if (destination == null) {
      return Scaffold(
        appBar: const _Bar(title: null, flagCode: null),
        body: _loading || catalog.status == CatalogStatus.loading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.page),
                child: SkeletonList(count: 5),
              )
            : EmptyState(
                icon: AppIcons.globe,
                title: context.l10n.errorNotFound,
              ),
      );
    }

    return BlocProvider(
      create: (_) {
        getIt<AnalyticsService>().viewedDestination(
          code: code,
          region: destination.isRegion,
        );
        return getIt<AsyncCubit<List<EsimPackage>>>(
          instanceName: 'packages',
          param1: code,
        )..load();
      },
      child: _DestinationView(
        destination: destination,
        initialPackageId: widget.packageId,
      ),
    );
  }
}

class _Bar extends StatelessWidget implements PreferredSizeWidget {
  const _Bar({
    required this.title,
    required this.flagCode,
    this.code,
    this.isRegion = false,
  });

  final String? title;
  final String? flagCode;
  final String? code;
  final bool isRegion;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    leading: IconButton(
      tooltip: context.l10n.searchBack,
      onPressed: () => context.pop(),
      icon: HugeIcon(
        icon: AppIcons.back,
        size: 24,
        color: context.colors.textPrimary,
      ),
    ),
    titleSpacing: 0,
    title: title == null
        ? null
        : Row(
            children: [
              if (code != null)
                AppHero(
                  tag: AppHeroTags.destinationFlag(code!),
                  child: isRegion
                      ? const RegionIcon(size: 28)
                      : FlagIcon(flagCode!, size: 28),
                ),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.h2,
                ),
              ),
            ],
          ),
  );
}

class _DestinationView extends StatefulWidget {
  const _DestinationView({required this.destination, this.initialPackageId});
  final String? initialPackageId;

  final Destination destination;

  @override
  State<_DestinationView> createState() => _DestinationViewState();
}

typedef _PlanChoice = ({String? key, int? days});

class _DestinationViewState extends State<_DestinationView> {
  /// The tab chosen by the customer; null until they choose, so the default
  /// can follow what the server returned.
  PackageKind? _kind;
  late final ValueNotifier<_PlanChoice> _selection;
  final _daySelections = <String, int>{};
  bool _buyBarCompact = false;

  @override
  void initState() {
    super.initState();
    _selection = ValueNotifier((key: widget.initialPackageId, days: null));
  }

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  bool _onPlansScroll(ScrollUpdateNotification notification) {
    // Only a real finger drag can collapse the bar. Its own size animation
    // changes the scroll extent too, so listening to every offset change made
    // the bar repeatedly open and close.
    if (!_buyBarCompact &&
        notification.dragDetails != null &&
        (notification.scrollDelta ?? 0) > 0 &&
        notification.metrics.pixels > 72) {
      setState(() => _buyBarCompact = true);
    }
    return false;
  }

  EsimPackage _withChosenDays(EsimPackage package, int? days) =>
      package.dailyPrice == null
      ? package
      : package.withPurchaseDays(
          days ?? _daySelections[package.id] ?? package.purchaseDays ?? 1,
        );

  EsimPackage? _selected(List<EsimPackage> shown, _PlanChoice choice) {
    for (final p in shown) {
      if (p.selectionKey == choice.key || p.id == choice.key) {
        return _withChosenDays(p, choice.days);
      }
    }
    // Nothing chosen yet: pre-select the middle of the list, a sensible
    // default for most trips.
    return shown.isEmpty
        ? null
        : _withChosenDays(shown[(shown.length - 1).clamp(0, 2)], null);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.destination;
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final state = context.watch<AsyncCubit<List<EsimPackage>>>().state;

    return Scaffold(
      appBar: _Bar(
        title: d.nameFor(language),
        flagCode: d.flagCode,
        code: d.code,
        isRegion: d.isRegion,
      ),
      body: switch (state) {
        AsyncLoading() => const Padding(
          padding: EdgeInsets.all(AppSpacing.page),
          child: SkeletonList(count: 6),
        ),
        AsyncFailure(:final failure) => ErrorView(
          failure: failure,
          onRetry: () => context.read<AsyncCubit<List<EsimPackage>>>().load(),
        ),
        AsyncData(:final data) =>
          data.isEmpty
              ? EmptyState(icon: AppIcons.myEsim, title: l10n.packagesEmpty)
              : _content(context, d, data, language),
      },
    );
  }

  Widget _content(
    BuildContext context,
    Destination d,
    List<EsimPackage> all,
    String language,
  ) {
    final l10n = context.l10n;
    if (_kind == null && widget.initialPackageId != null) {
      _kind = all
          .where((p) => p.id == widget.initialPackageId)
          .firstOrNull
          ?.kind;
    }
    final unlimited = all.where((p) => p.isUnlimited).toList();
    final limited = all.where((p) => !p.isUnlimited).toList();

    // An empty category has no tab.
    final kinds = [
      if (unlimited.isNotEmpty) PackageKind.unlimited,
      if (limited.isNotEmpty) PackageKind.limited,
    ];
    final kind = kinds.contains(_kind)
        ? _kind!
        : (kinds.contains(PackageKind.limited)
              ? PackageKind.limited
              : kinds.first);
    final shown = kind == PackageKind.unlimited ? unlimited : limited;
    final config = context.watch<ConfigCubit>().state;

    return Column(
      children: [
        Expanded(
          child: NotificationListener<ScrollUpdateNotification>(
            onNotification: _onPlansScroll,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.xxl,
              ),
              children: [
                const CompatBanner(),
                if (d.isRegion) ...[
                  const SizedBox(height: AppSpacing.md),
                  _Coverage(
                    codes: all.first.coverage,
                    names: all.first.coverageNames,
                    language: language,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                if (kinds.length > 1) ...[
                  SegmentedTabs(
                    labels: [
                      for (final k in kinds)
                        k == PackageKind.unlimited
                            ? '${l10n.packagesUnlimited} (${unlimited.length})'
                            : '${l10n.packagesLimited} (${limited.length})',
                    ],
                    selectedIndex: kinds.indexOf(kind),
                    onChanged: (i) => setState(() {
                      _kind = kinds[i];
                      _selection.value = (key: null, days: null);
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Text(l10n.packagesChoose, style: context.text.h2),
                const SizedBox(height: AppSpacing.md),
                ValueListenableBuilder<_PlanChoice>(
                  valueListenable: _selection,
                  builder: (context, choice, _) {
                    final selected = _selected(shown, choice);
                    return TabSwitcher(
                      index: kinds.indexOf(kind),
                      child: Column(
                        children: [
                          for (final p in shown) ...[
                            Builder(
                              builder: (context) {
                                final shownPackage = _withChosenDays(p, null);
                                return PackageTile(
                                  volume: l10n.packageVolume(shownPackage),
                                  duration:
                                      p.dailyPrice != null &&
                                          shownPackage.dailyBytes != null
                                      ? l10n.dailyAllowance(
                                          l10n.dataSize(
                                            shownPackage.dailyBytes!,
                                          ),
                                        )
                                      : l10n.packageDuration(shownPackage),
                                  price: shownPackage.price.format(),
                                  selected: p.id == selected?.id,
                                  selectedDays: p.dailyPrice == null
                                      ? null
                                      : shownPackage.days,
                                  minDays: p.minPurchaseDays,
                                  maxDays: p.maxPurchaseDays,
                                  onDaysChanged: p.dailyPrice == null
                                      ? null
                                      : (days) {
                                          _daySelections[p.id] = days;
                                          final chosen = p.withPurchaseDays(
                                            days,
                                          );
                                          _selection.value = (
                                            key: p.selectionKey,
                                            days: days,
                                          );
                                          getIt<AnalyticsService>()
                                              .selectedPackage(
                                                packageId: p.id,
                                                price: chosen.price,
                                              );
                                        },
                                  onTap: () {
                                    if (selected?.id == p.id) return;
                                    getIt<AnalyticsService>().selectedPackage(
                                      packageId: p.id,
                                      price: shownPackage.price,
                                    );
                                    _selection.value = (
                                      key: p.selectionKey,
                                      days: shownPackage.purchaseDays,
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                const _ActivationNote(),
              ],
            ),
          ),
        ),
        ValueListenableBuilder<_PlanChoice>(
          valueListenable: _selection,
          builder: (context, choice, _) {
            final selected = _selected(shown, choice);
            return _BuyBar(
              compact: _buyBarCompact,
              onExpand: () => setState(() => _buyBarCompact = false),
              maintenance: config.maintenance,
              selected: selected,
              onDetails: selected == null
                  ? null
                  : () => _openDetails(context, d, selected, language),
              onBuy: selected == null
                  ? null
                  : () => _buy(context, d, selected, language),
            );
          },
        ),
      ],
    );
  }

  PurchaseSubject _subject(
    BuildContext context,
    Destination d,
    EsimPackage p,
    String language,
  ) {
    final l10n = context.l10n;
    return PurchaseSubject(
      package: p,
      title: d.isRegion
          ? l10n.esimRegionTitle(d.nameFor(language), d.countryCount ?? 0)
          : d.nameFor(language),
      planLine: '${l10n.packageVolume(p)} · ${l10n.packageDuration(p)}',
      flagCode: d.flagCode,
    );
  }

  Future<void> _buy(
    BuildContext context,
    Destination d,
    EsimPackage p,
    String language,
  ) async {
    await startPurchase(context, _subject(context, d, p, language));
  }

  Future<void> _openDetails(
    BuildContext context,
    Destination d,
    EsimPackage p,
    String language,
  ) async {
    final l10n = context.l10n;
    getIt<AnalyticsService>().openedPackageDetails(p.id);
    final maintenance = context.read<ConfigCubit>().state.maintenance;
    final result = await getIt<CatalogRepository>().detail(p);
    if (!context.mounted) return;
    if (result case Error(:final failure)) {
      AppToast.show(context, failure.localize(l10n));
      return;
    }
    final fullPackage = result.dataOrNull!;
    final buy = await showPackageDetailsSheet(
      context,
      package: fullPackage,
      destinationName: d.nameFor(language),
      coverage: d.isRegion
          ? l10n.regionCountries(d.countryCount ?? 0)
          : d.nameFor(language),
      canBuy: !maintenance,
    );
    if (buy && context.mounted) await _buy(context, d, p, language);
  }
}

/// The bottom area: details link, the buy button and the legal lines.
class _BuyBar extends StatefulWidget {
  const _BuyBar({
    required this.compact,
    required this.onExpand,
    required this.maintenance,
    required this.selected,
    required this.onDetails,
    required this.onBuy,
  });

  final bool compact;
  final VoidCallback onExpand;
  final bool maintenance;
  final EsimPackage? selected;
  final VoidCallback? onDetails;
  final VoidCallback? onBuy;

  @override
  State<_BuyBar> createState() => _BuyBarState();
}

class _BuyBarState extends State<_BuyBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expanded;
  late final Animation<double> _collapsed;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animationSlow,
      value: widget.compact ? 0 : 1,
    );
    _expanded = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );
    _collapsed = ReverseAnimation(_expanded);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) _controller.value = widget.compact ? 0 : 1;
  }

  @override
  void didUpdateWidget(_BuyBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.compact == oldWidget.compact) return;
    if (_reduceMotion) {
      _controller.value = widget.compact ? 0 : 1;
    } else if (widget.compact) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return DecoratedBox(
      key: const ValueKey('destination-buy-bar'),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: _reduceMotion ? Duration.zero : AppConstants.animationSlow,
          curve: Curves.easeInOutSine,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            widget.compact ? AppSpacing.sm : AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.maintenance)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    l10n.maintenanceBanner,
                    style: context.text.bodySm.copyWith(color: c.warning),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizeTransition(
                key: const ValueKey('buy-bar-details'),
                sizeFactor: _expanded,
                alignment: Alignment.bottomCenter,
                child: FadeTransition(
                  opacity: _expanded,
                  child: IgnorePointer(
                    ignoring: widget.compact,
                    child: TextButton.icon(
                      onPressed: widget.onDetails,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        foregroundColor: c.link,
                      ),
                      icon: HugeIcon(
                        icon: AppIcons.info,
                        size: 18,
                        color: c.link,
                      ),
                      label: Text(
                        l10n.packageDetailsLink,
                        style: context.text.bodySm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  SizeTransition(
                    axis: Axis.horizontal,
                    sizeFactor: _collapsed,
                    alignment: Alignment.centerLeft,
                    child: FadeTransition(
                      opacity: _collapsed,
                      child: IgnorePointer(
                        ignoring: !widget.compact,
                        child: SizedBox(
                          width: 56,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              tooltip: l10n.packageDetailsLink,
                              onPressed: widget.onExpand,
                              style: IconButton.styleFrom(
                                minimumSize: const Size(48, 48),
                                backgroundColor: c.primarySubtle,
                                foregroundColor: c.link,
                              ),
                              icon: HugeIcon(
                                icon: AppIcons.info,
                                size: 20,
                                color: c.link,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AppButton(
                      label: widget.selected == null
                          ? l10n.packagesChoose
                          : l10n.buyFor(widget.selected!.price.format()),
                      onPressed: widget.maintenance ? null : widget.onBuy,
                    ),
                  ),
                ],
              ),
              SizeTransition(
                key: const ValueKey('buy-bar-legal'),
                sizeFactor: _expanded,
                alignment: Alignment.topCenter,
                child: FadeTransition(
                  opacity: _expanded,
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Column(
                      children: [
                        Text(
                          l10n.purchaseDisclaimer,
                          textAlign: TextAlign.center,
                          style: context.text.caption.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                        Text(
                          l10n.oneTimePurchase,
                          textAlign: TextAlign.center,
                          style: context.text.caption.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Some networks only activate the eSIM in the destination, so iOS shows
/// "Activating…" until then; said before buying so nobody deletes it.
class _ActivationNote extends StatelessWidget {
  const _ActivationNote();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HugeIcon(icon: AppIcons.info, size: 16, color: c.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            context.l10n.esimActivatingNote,
            style: context.text.caption.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// A region's countries as an expandable list of flag + name.
class _Coverage extends StatefulWidget {
  const _Coverage({
    required this.codes,
    required this.names,
    required this.language,
  });

  final List<String> codes;
  final Map<String, String> names;
  final String language;

  @override
  State<_Coverage> createState() => _CoverageState();
}

class _CoverageState extends State<_Coverage> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final catalog = context.watch<CatalogCubit>().state;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            onTap: () => setState(() => _open = !_open),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${l10n.coverageCountries} (${widget.codes.length})',
                        style: context.text.bodyMed.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: HugeIcon(
                        icon: AppIcons.chevronDown,
                        size: 20,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        for (final code in widget.codes)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                FlagIcon(code, size: 24),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    widget.names[code]?.isNotEmpty == true
                                        ? widget.names[code]!
                                        : catalog
                                                  .byCode(code)
                                                  ?.nameFor(widget.language) ??
                                              code,
                                    style: context.text.bodySm,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
