import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_environment.dart';
import '../../core/services/push_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../core/di/injector.dart';
import '../../core/services/analytics_service.dart';
import '../../core/storage/local_storage.dart';
import '../../core/storage/storage_keys.dart';
import '../../features/auth/presentation/view/delete_account_page.dart';
import '../../features/auth/presentation/view/devices_page.dart';
import '../../features/auth/presentation/view/login_page.dart';
import '../../features/catalog/presentation/view/destination_page.dart';
import '../../features/catalog/presentation/view/search_page.dart';
import '../../features/catalog/presentation/view/package_link_page.dart';
import '../../features/esim/presentation/view/esim_detail_page.dart';
import '../../features/esim/presentation/view/esim_top_up_page.dart';
import '../../features/esim/presentation/view/my_esim_page.dart';
import '../../features/gallery/presentation/view/gallery_page.dart';
import '../../features/home/presentation/view/home_page.dart';
import '../../features/legal/domain/entities/legal_document.dart';
import '../../features/legal/presentation/view/legal_pages.dart';
import '../../features/profile/presentation/view/profile_page.dart';
import '../../features/profile/presentation/view/settings_page.dart';
import '../../features/purchase/presentation/purchase_subject.dart';
import '../../features/purchase/presentation/view/purchase_page.dart';
import '../../features/referral/presentation/view/referral_page.dart';
import '../../features/support/presentation/view/chat_page.dart';
import '../../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../../features/wallet/presentation/view/balance_top_up_page.dart';
import '../../features/wallet/presentation/view/orders_page.dart';
import '../../features/wallet/presentation/view/order_activity_detail_page.dart';
import '../../features/wallet/presentation/view/payment_detail_page.dart';
import '../view/home_shell.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static GoRouter create() => GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'root'),
    initialLocation: AppEnvironment.initialRoute,
    redirect: (_, state) {
      final localizedInvite = RegExp(
        r'^/(?:en|zh|ru|es|fr)/r/([^/?#]+)$',
      ).firstMatch(state.uri.path);
      if (localizedInvite != null) {
        return AppRoute.invite.withParams({'code': localizedInvite.group(1)!});
      }
      final normalized = PushRouter.routeForLink(state.uri.toString());
      if (normalized != null && normalized != state.uri.toString()) {
        return normalized;
      }
      if (!AppEnvironment.useMockApi &&
          state.matchedLocation == AppRoute.supportChat.path &&
          !getIt<AuthCubit>().state.isSignedIn) {
        return AppRoute.login.path;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/package/:id',
        builder: (_, state) => PackageLinkPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/payment/:id',
        redirect: (_, state) =>
            '${AppRoute.balanceTopUp.path}?paymentId=${Uri.encodeComponent(state.pathParameters["id"]!)}',
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.home.path,
                name: AppRoute.home.routeName,
                builder: (_, _) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.myEsim.path,
                name: AppRoute.myEsim.routeName,
                builder: (_, _) => const MyEsimPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.profile.path,
                name: AppRoute.profile.routeName,
                builder: (_, _) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.search.path,
        name: AppRoute.search.routeName,

        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          name: state.name,
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 340),
          child: const SearchPage(),
          transitionsBuilder: (context, animation, secondary, child) =>
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0, 0.55, curve: Curves.easeOut),
                  reverseCurve: const Interval(0.35, 1, curve: Curves.easeIn),
                ),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: AppRoute.destination.path,
        name: AppRoute.destination.routeName,
        builder: (_, state) => DestinationPage(
          code: state.pathParameters['code']!,
          packageId: state.uri.queryParameters['packageId'],
        ),
      ),
      GoRoute(
        path: AppRoute.purchase.path,
        name: AppRoute.purchase.routeName,

        redirect: (_, state) =>
            state.extra is PurchaseSubject ? null : AppRoute.home.path,
        builder: (_, state) =>
            PurchasePage(subject: state.extra! as PurchaseSubject),
      ),
      GoRoute(
        path: AppRoute.esim.path,
        name: AppRoute.esim.routeName,
        builder: (_, state) => EsimDetailPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoute.esimTopUp.path,
        name: AppRoute.esimTopUp.routeName,
        builder: (_, state) =>
            EsimTopUpPage(esimId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.routeName,
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoute.balanceTopUp.path,
        name: AppRoute.balanceTopUp.routeName,
        builder: (_, state) => BalanceTopUpPage(
          initialCents: state.extra is int ? state.extra! as int : null,
          paymentId: state.uri.queryParameters['paymentId'],
        ),
      ),
      GoRoute(
        path: AppRoute.orders.path,
        name: AppRoute.orders.routeName,
        builder: (_, _) => const OrdersPage(),
      ),
      GoRoute(
        path: AppRoute.orderDetail.path,
        name: AppRoute.orderDetail.routeName,
        builder: (_, state) => OrderDetailPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoute.paymentDetail.path,
        name: AppRoute.paymentDetail.routeName,
        builder: (_, state) =>
            PaymentDetailPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoute.activityDetail.path,
        name: AppRoute.activityDetail.routeName,
        builder: (_, state) => ActivityDetailPage(
          id: state.pathParameters['id']!,
          initialEntry: state.extra is Map<String, dynamic>
              ? state.extra! as Map<String, dynamic>
              : null,
        ),
      ),
      GoRoute(
        path: AppRoute.referral.path,
        name: AppRoute.referral.routeName,
        builder: (_, _) => const ReferralPage(),
      ),
      GoRoute(
        path: AppRoute.devices.path,
        name: AppRoute.devices.routeName,
        builder: (_, _) => const DevicesPage(),
      ),
      GoRoute(
        path: AppRoute.deleteAccount.path,
        name: AppRoute.deleteAccount.routeName,
        builder: (_, _) => const DeleteAccountPage(),
      ),
      GoRoute(
        path: AppRoute.settings.path,
        name: AppRoute.settings.routeName,
        builder: (_, _) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoute.legal.path,
        name: AppRoute.legal.routeName,
        builder: (_, _) => const LegalListPage(),
      ),
      GoRoute(
        path: AppRoute.legalDocument.path,
        name: AppRoute.legalDocument.routeName,
        builder: (_, state) => LegalDocumentPage(
          id: state.pathParameters['id']!,
          document: state.extra is LegalDocument
              ? state.extra! as LegalDocument
              : null,
        ),
      ),
      GoRoute(
        path: AppRoute.supportChat.path,
        name: AppRoute.supportChat.routeName,
        builder: (_, _) => const ChatPage(),
      ),

      GoRoute(
        path: AppRoute.invite.path,
        name: AppRoute.invite.routeName,
        redirect: (_, state) {
          final code = state.pathParameters['code'] ?? '';
          final valid = RegExp(r'^[A-Za-z0-9]{4,12}$').hasMatch(code);
          if (valid) {
            getIt<LocalStorage>().setString(
              StorageKeys.pendingInvite,
              code.toUpperCase(),
            );

            getIt<AnalyticsService>()
              ..inviteLinkOpened(code.toUpperCase())
              ..setUserProperty('acquisition', 'invite');
          }
          return AppRoute.home.path;
        },
      ),

      GoRoute(
        path: AppRoute.payReturn.path,
        name: AppRoute.payReturn.routeName,
        redirect: (_, _) {
          getIt<WalletCubit>().refresh();
          return AppRoute.home.path;
        },
      ),

      if (!kReleaseMode)
        GoRoute(
          path: AppRoute.gallery.path,
          name: AppRoute.gallery.routeName,
          builder: (_, _) => const GalleryPage(),
        ),
    ],
  );
}
