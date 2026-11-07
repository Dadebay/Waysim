import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/money.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/promo_carousel.dart';
import '../../../../core/widgets/segmented_tabs.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/tab_switcher.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../catalog/presentation/cubit/catalog_cubit.dart';
import '../../../config/presentation/cubit/config_cubit.dart';
import '../../../esim/presentation/view/how_it_works_sheet.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import '../../../catalog/presentation/widgets/search_field_box.dart';
import '../../../catalog/presentation/widgets/compat_banner.dart';
import '../widgets/destination_list.dart';
import '../widgets/home_header.dart';
import '../widgets/promo_banner.dart';
import '../widgets/sim_refresh_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _minimumRefreshDisplay = Duration(milliseconds: 700);

  int _tab = 0;
  bool _guideShown = false;
  bool _refreshing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_guideShown &&
        GoRouterState.of(context).uri.queryParameters['guide'] == 'true') {
      _guideShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showHowItWorksSheet(context);
      });
    }
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    final auth = context.read<AuthCubit>().state;
    try {
      await Future.wait([
        Future<void>.delayed(_minimumRefreshDisplay),
        getIt<CatalogCubit>().load(),
        getIt<ConfigCubit>().refresh(),
        if (auth.isSignedIn) getIt<WalletCubit>().refresh(),
      ]);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final catalog = context.watch<CatalogCubit>().state;
    final language = Localizations.localeOf(context).languageCode;
    final showBanners =
        catalog.status == CatalogStatus.loaded &&
        catalog.destinations.isNotEmpty &&
        (catalog.banners?.isNotEmpty ?? true);
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          RefreshIndicator.noSpinner(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.xl,
                    AppSpacing.page,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(child: HomeHeader()),
                ),
                const SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchHeaderDelegate(),
                ),
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.sm,
                    AppSpacing.page,
                    AppSpacing.sm,
                  ),
                  sliver: SliverToBoxAdapter(child: CompatBanner()),
                ),
                if (showBanners)
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.sm),
                  ),
                if (showBanners) SliverToBoxAdapter(child: const _Banners()),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    showBanners ? AppSpacing.xl : 0,
                    AppSpacing.page,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: SegmentedTabs(
                      labels: [l10n.homeLocal, l10n.homeRegional],
                      selectedIndex: _tab,
                      onChanged: (i) => setState(() => _tab = i),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: TabSwitcher(
                      index: _tab,
                      child: _body(catalog, language),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 104)),
              ],
            ),
          ),
          Positioned(
            top: AppSpacing.sm,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedSwitcher(
                duration: AppConstants.animationFast,
                child: _refreshing
                    ? const SimRefreshIndicator(
                        key: ValueKey('home-sim-refresh-indicator'),
                        active: true,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(CatalogState catalog, String language) {
    final l10n = context.l10n;
    if (_refreshing) {
      return const Padding(
        padding: EdgeInsets.only(top: AppSpacing.lg),
        child: SkeletonList(count: 8),
      );
    }
    switch (catalog.status) {
      case CatalogStatus.initial || CatalogStatus.loading:
        return const Padding(
          padding: EdgeInsets.only(top: AppSpacing.lg),
          child: SkeletonList(count: 8),
        );
      case CatalogStatus.failure:
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xxxl),
          child: ErrorView(
            failure: catalog.failure!,
            onRetry: () => getIt<CatalogCubit>().load(),
          ),
        );
      case CatalogStatus.loaded:
        final list = _tab == 0 ? catalog.countries : catalog.regions;
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxxl),
            child: EmptyState(icon: AppIcons.globe, title: l10n.catalogEmpty),
          );
        }
        final sorted = [...list];
        if (_tab == 0) {
          sorted.sort(
            (a, b) => a
                .nameFor(language)
                .toLowerCase()
                .compareTo(b.nameFor(language).toLowerCase()),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: DestinationList(destinations: sorted),
        );
    }
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SearchHeaderDelegate();

  static const _fieldHeight = 52.0;

  @override
  double get minExtent => _fieldHeight + 2 * AppSpacing.sm;

  @override
  double get maxExtent => _fieldHeight + AppSpacing.lg + AppSpacing.md;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final c = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.background,
        boxShadow: progress == 0
            ? null
            : [
                BoxShadow(
                  color: c.textPrimary.withValues(alpha: 0.08 * progress),
                  blurRadius: 12 * progress,
                  offset: Offset(0, 3 * progress),
                ),
              ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.page,
          ui.lerpDouble(AppSpacing.lg, AppSpacing.sm, progress)!,
          AppSpacing.page,
          ui.lerpDouble(AppSpacing.md, AppSpacing.sm, progress)!,
        ),
        child: const _SearchField(),
      ),
    );
  }

  @override
  bool shouldRebuild(_SearchHeaderDelegate oldDelegate) => false;
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.searchHint,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push(AppRoute.search.path),

        child: Hero(
          tag: searchFieldHeroTag,
          createRectTween: (begin, end) =>
              SearchFlightRectTween(begin: begin, end: end),
          flightShuttleBuilder: searchFlightShuttle,
          child: Material(
            type: MaterialType.transparency,
            child: SearchFieldBox(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                child: SearchFieldHint(hint: context.l10n.searchHint),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Banners extends StatelessWidget {
  const _Banners();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final config = context.watch<ConfigCubit>().state;

    final banners = context.watch<CatalogCubit>().state.banners;
    if (banners != null) {
      if (banners.isEmpty) return const SizedBox.shrink();
      return PromoCarousel(
        aspectRatio: 16 / 9,
        children: [
          for (final banner in banners)
            ClipRRect(
              key: ValueKey(banner.id),
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Material(
                color: context.colors.surface,
                child: InkWell(
                  onTap: () => context.go(AppRoute.myEsim.path),
                  child: CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const Skeleton(
                      child: SizedBox.expand(
                        child: ColoredBox(color: Colors.white),
                      ),
                    ),
                    errorWidget: (_, _, _) => const SizedBox.expand(),
                  ),
                ),
              ),
            ),
        ],
      );
    }
    void openMyEsims() => context.go(AppRoute.myEsim.path);
    return PromoCarousel(
      aspectRatio: 16 / 9,
      children: [
        PromoBanner(
          key: const ValueKey('esim'),
          title: l10n.bannerEsimTitle,
          body: l10n.bannerEsimBody,
          action: l10n.bannerEsimAction,
          icon: AppIcons.myEsim,
          compact: true,
          onTap: openMyEsims,
        ),
        if (config.referralEnabled)
          PromoBanner(
            key: const ValueKey('invite'),
            tone: PromoTone.subtle,
            title: l10n.bannerInviteTitle(
              Money(config.referralRewardCents).format(withCents: false),
            ),
            action: l10n.bannerInviteAction,
            icon: AppIcons.gift,
            compact: true,
            onTap: openMyEsims,
          ),
        PromoBanner(
          key: const ValueKey('travel'),
          title: l10n.bannerTravelTitle,
          body: l10n.bannerTravelBody,
          action: l10n.bannerTravelAction,
          icon: AppIcons.globe,
          compact: true,
          onTap: openMyEsims,
        ),
      ],
    );
  }
}
