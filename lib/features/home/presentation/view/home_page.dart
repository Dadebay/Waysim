import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/auth_gate.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
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
import '../widgets/destination_list.dart';
import '../widgets/home_header.dart';
import '../widgets/promo_banner.dart';

/// The first tab: balance, search, banners, then every country and region.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 0 = Local (countries), 1 = Regional.
  int _tab = 0;

  Future<void> _refresh() async {
    final auth = context.read<AuthCubit>().state;
    await Future.wait([
      getIt<CatalogCubit>().load(),
      getIt<ConfigCubit>().refresh(),
      if (auth.isSignedIn) getIt<WalletCubit>().refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final catalog = context.watch<CatalogCubit>().state;
    final language = Localizations.localeOf(context).languageCode;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.xl,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              sliver: SliverToBoxAdapter(child: HomeHeader()),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
              sliver: SliverToBoxAdapter(child: _SearchField()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            if (catalog.status == CatalogStatus.loaded &&
                catalog.destinations.isNotEmpty)
              SliverToBoxAdapter(
                child: _Banners(onShowLocal: () => setState(() => _tab = 0)),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.xl,
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              sliver: SliverToBoxAdapter(
                child: TabSwitcher(
                  index: _tab,
                  child: _body(catalog, language),
                ),
              ),
            ),
            // Room for the support button and the last row.
            const SliverToBoxAdapter(child: SizedBox(height: 104)),
          ],
        ),
      ),
    );
  }

  Widget _body(CatalogState catalog, String language) {
    final l10n = context.l10n;
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
          // Countries alphabetically in the app language; regions keep the
          // server's order (Europe first).
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
        // The box itself flies up into the search page's app bar.
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

/// The three banners: what eSIM is, invite a friend (only while the referral
/// programme is on) and the Local list. Content comes from the server in the
/// real app; here the copy is local.
class _Banners extends StatelessWidget {
  const _Banners({required this.onShowLocal});

  final VoidCallback onShowLocal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final config = context.watch<ConfigCubit>().state;

    return PromoCarousel(
      children: [
        PromoBanner(
          key: const ValueKey('esim'),
          title: l10n.bannerEsimTitle,
          body: l10n.bannerEsimBody,
          action: l10n.bannerEsimAction,
          icon: AppIcons.myEsim,
          onTap: () => showHowItWorksSheet(context),
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
            onTap: () async {
              if (await requireSignIn(context) && context.mounted) {
                await context.push(AppRoute.referral.path);
              }
            },
          ),
        PromoBanner(
          key: const ValueKey('travel'),
          title: l10n.bannerTravelTitle,
          body: l10n.bannerTravelBody,
          action: l10n.bannerTravelAction,
          icon: AppIcons.globe,
          onTap: onShowLocal,
        ),
      ],
    );
  }
}
