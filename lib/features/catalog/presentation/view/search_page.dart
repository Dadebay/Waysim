import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../home/presentation/widgets/destination_list.dart';
import '../../domain/catalog_search.dart';
import '../cubit/catalog_cubit.dart';
import '../cubit/search_cubit.dart';
import '../widgets/search_field_box.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<SearchCubit>(),
    child: const _SearchView(),
  );
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Animation<double>? _routeAnimation;
  bool _armed = false;

  Animation<double>? get _enter => _routeAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_armed) return;
    _armed = true;

    _routeAnimation = ModalRoute.of(context)?.animation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final animation = _routeAnimation;

      if (animation == null || animation.isCompleted) {
        _focusWhenReady();
      } else {
        animation.addStatusListener(_onRouteStatus);
      }
    });
  }

  void _onRouteStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      _routeAnimation?.removeStatusListener(_onRouteStatus);
      _focusWhenReady();
    }
  }

  Future<void> _focusWhenReady() async {
    for (var i = 0; i < 8 && mounted; i++) {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      if (_focus.context != null) {
        _focus.requestFocus();
        return;
      }
    }
  }

  void _leave() {
    _focus.unfocus();
    context.pop();
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Widget _staggered(Widget child, {double from = 0.45}) {
    final animation = _enter;
    if (animation == null) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(from, 1, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.015),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }

  void _onChanged(String text) {
    context.read<SearchCubit>().query(
      text,
      destinations: context.read<CatalogCubit>().state.destinations,
      language: Localizations.localeOf(context).languageCode,
    );
  }

  void _repeatSearch(String phrase) {
    _controller.value = TextEditingValue(
      text: phrase,
      selection: TextSelection.collapsed(offset: phrase.length),
    );
    _onChanged(phrase);
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final search = context.watch<SearchCubit>().state;
    final language = Localizations.localeOf(context).languageCode;
    final catalogCountries = [...context.watch<CatalogCubit>().state.countries]
      ..sort(
        (a, b) => b
            .nameFor(language)
            .toLowerCase()
            .compareTo(a.nameFor(language).toLowerCase()),
      );
    final countries = search.isSearching
        ? search.hits.where((h) => !h.destination.isRegion)
        : catalogCountries.map((destination) => SearchHit(destination, 0));
    final regions = search.hits.where((h) => h.destination.isRegion);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  _staggered(
                    from: 0.2,
                    IconButton(
                      tooltip: l10n.searchBack,
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      onPressed: _leave,
                      icon: HugeIcon(
                        icon: AppIcons.back,
                        size: 24,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Hero(
                      tag: searchFieldHeroTag,
                      createRectTween: (begin, end) =>
                          SearchFlightRectTween(begin: begin, end: end),
                      flightShuttleBuilder: searchFlightShuttle,
                      child: Material(
                        type: MaterialType.transparency,
                        child: SearchFieldBox(
                          focus: 1,
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: AppIcons.search,
                                size: 20,
                                color: c.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focus,
                                  textInputAction: TextInputAction.search,
                                  cursorColor: c.primary,
                                  style: context.text.bodyMed,
                                  onChanged: _onChanged,
                                  onSubmitted: context
                                      .read<SearchCubit>()
                                      .rememberQuery,
                                  decoration: InputDecoration(
                                    hintText: l10n.searchHint,
                                    hintStyle: context.text.bodyMed.copyWith(
                                      color: c.textSecondary,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              if (_controller.text.isNotEmpty)
                                IconButton(
                                  tooltip: l10n.searchClear,
                                  style: IconButton.styleFrom(
                                    backgroundColor: c.surface,
                                    minimumSize: const Size(32, 32),
                                  ),
                                  onPressed: () {
                                    _controller.clear();
                                    _onChanged('');
                                    setState(() {});
                                  },
                                  icon: HugeIcon(
                                    icon: AppIcons.close,
                                    size: 18,
                                    color: c.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _staggered(
                ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.md,
                    AppSpacing.page,
                    AppSpacing.xxxl,
                  ),
                  children: [
                    if (search.recent.isNotEmpty) ...[
                      _SectionHeader(
                        l10n.searchRecent,
                        action: l10n.searchClear,
                        onAction: context.read<SearchCubit>().clearRecent,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final phrase in search.recent)
                            ActionChip(
                              label: Text(phrase),
                              backgroundColor: c.surface,
                              side: BorderSide(color: c.border),
                              shape: const StadiumBorder(),
                              onPressed: () => _repeatSearch(phrase),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    if (search.isSearching && search.hits.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxxl),
                        child: EmptyState(
                          icon: AppIcons.search,
                          title: l10n.searchNoResults(search.query.trim()),
                          body: l10n.searchNoResultsHint,
                        ),
                      ),
                    if (countries.isNotEmpty) ...[
                      _SectionHeader(l10n.searchCountries),
                      ..._rows(context, countries),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (regions.isNotEmpty) ...[
                      _SectionHeader(l10n.searchRegions),
                      ..._rows(context, regions),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _rows(BuildContext context, Iterable<SearchHit> hits) => [
    for (final hit in hits) ...[
      DestinationRow(
        destination: hit.destination,
        highlight: hit.highlight,
        searchStyle: true,
        onOpen: () {
          final search = context.read<SearchCubit>();
          if (!search.state.isSearching) return;
          getIt<AnalyticsService>().searched(
            search.state.query.trim(),
            results: search.state.hits.length,
            destinationCode: hit.destination.code,
            region: hit.destination.isRegion,
          );
          search.rememberQuery(search.state.query);
        },
      ),
      Divider(color: context.colors.border, height: AppSpacing.xs),
    ],
  ];
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: context.text.caption.copyWith(
              color: c.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44),
              foregroundColor: c.link,
            ),
            child: Text(
              action!,
              style: context.text.bodySm.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
