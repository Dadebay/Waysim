import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/bloc/async_cubit.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/segmented_tabs.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/tab_switcher.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/esim.dart';
import '../cubit/esim_list_cubit.dart';
import '../esim_installer.dart';
import '../widgets/esim_card.dart';
import 'how_it_works_sheet.dart';

class MyEsimPage extends StatefulWidget {
  const MyEsimPage({super.key});

  @override
  State<MyEsimPage> createState() => _MyEsimPageState();
}

class _MyEsimPageState extends State<MyEsimPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthCubit>().state;
    final state = context.watch<EsimListCubit>().state;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.myEsimTitle, style: context.text.h1),
            const SizedBox(height: AppSpacing.lg),
            Expanded(child: _content(context, auth, state)),
          ],
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    AuthState auth,
    AsyncState<List<Esim>> state,
  ) {
    if (!auth.isSignedIn) return const _Empty();

    switch (state) {
      case AsyncLoading():
        return const SingleChildScrollView(child: _CardSkeletons());
      case AsyncFailure(:final failure):
        return ErrorView(
          failure: failure,
          onRetry: () => getIt<EsimListCubit>().load(),
        );
      case AsyncData(:final data):
        if (data.isEmpty) return const _Empty();
        return _list(context, data);
    }
  }

  Widget _list(BuildContext context, List<Esim> all) {
    final l10n = context.l10n;
    final current = all.where((e) => !e.status.isArchived).toList();
    final archive = all.where((e) => e.status.isArchived).toList();
    final shown = _tab == 0 ? current : archive;

    return Column(
      children: [
        SegmentedTabs(
          labels: [l10n.myEsimCurrent, l10n.myEsimArchive],
          selectedIndex: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: TabSwitcher(
            index: _tab,
            child: RefreshIndicator(
              onRefresh: () => getIt<EsimListCubit>().load(silent: true),
              child: shown.isEmpty
                  ? _tab == 0
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: AppSpacing.xxxl),
                              EmptyState(
                                icon: AppIcons.myEsim,
                                title: l10n.myEsimEmptyTitle,
                                body: l10n.myEsimEmptyBody,
                              ),
                            ],
                          )
                        : const _ArchiveEmptyState()
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 104),
                      itemCount: shown.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) => EsimCard(
                        esim: shown[i],
                        onInstall: () => installEsim(context, shown[i]),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArchiveEmptyState extends StatelessWidget {
  const _ArchiveEmptyState();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 188,
                      height: 188,
                      decoration: BoxDecoration(
                        color: c.primarySubtle.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Image.asset(
                      'assets/illustrations/esim_archive_empty.png',
                      key: const ValueKey('esim-archive-empty-illustration'),
                      width: 240,
                      height: 240,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  context.l10n.myEsimArchiveEmpty,
                  style: context.text.h2,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, AppSpacing.xxl, 0, 88),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _EmptyEsimArtwork(),
                const SizedBox(height: AppSpacing.xxxl),
                Text(
                  l10n.myEsimEmptyTitle,
                  style: context.text.h1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 290),
                  child: Text(
                    l10n.myEsimEmptyBody,
                    style: context.text.body.copyWith(color: c.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                AppButton(
                  label: l10n.buyEsim,
                  trailingIcon: AppIcons.chevronRight,
                  onPressed: () => context.go(AppRoute.home.path),
                ),
                const SizedBox(height: AppSpacing.md),
                Material(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  child: InkWell(
                    key: const ValueKey('how-esim-works'),
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    onTap: () => showHowItWorksSheet(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: AppIcons.info,
                            size: 22,
                            color: c.link,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              l10n.howEsimWorks,
                              style: context.text.bodyMed.copyWith(
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                          HugeIcon(
                            icon: AppIcons.chevronRight,
                            size: 20,
                            color: c.textSecondary,
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
      ),
    );
  }
}

class _EmptyEsimArtwork extends StatelessWidget {
  const _EmptyEsimArtwork();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox.square(
      dimension: 164,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 164,
            height: 164,
            decoration: BoxDecoration(
              color: c.primarySubtle.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: c.primarySubtle,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 88,
            height: 112,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: c.border),
              boxShadow: [
                BoxShadow(
                  color: c.shadow,
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: HugeIcon(icon: AppIcons.myEsim, size: 42, color: c.primary),
          ),
          Positioned(
            right: 11,
            bottom: 16,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: c.primary,
                shape: BoxShape.circle,
                border: Border.all(color: c.background, width: 4),
              ),
              alignment: Alignment.center,
              child: HugeIcon(
                icon: AppIcons.globe,
                size: 22,
                color: c.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSkeletons extends StatelessWidget {
  const _CardSkeletons();

  @override
  Widget build(BuildContext context) => Skeleton(
    child: Column(
      children: [
        for (var i = 0; i < 3; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: SkeletonBox(height: 132, radius: AppRadius.card),
          ),
      ],
    ),
  );
}
