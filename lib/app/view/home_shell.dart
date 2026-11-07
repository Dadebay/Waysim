import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/offline_banner.dart';
import '../../core/widgets/support_fab.dart';
import '../../features/support/presentation/view/support_sheet.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import 'widgets/app_tab_bar.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  StatefulNavigationShell get navigationShell => widget.navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: navigationShell),
                Positioned(
                  right: AppSpacing.page,
                  bottom: AppSpacing.lg,
                  child: SupportFab(
                    unread:
                        context.watch<AuthCubit>().state.user?.supportUnread ??
                        0,
                    onPressed: () => showSupportSheet(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppTabBar(
        currentIndex: navigationShell.currentIndex,
        onSelected: (index) {
          unawaited(context.read<AuthCubit>().revalidate());
          navigationShell.goBranch(
            index,

            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
