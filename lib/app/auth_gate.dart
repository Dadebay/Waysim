import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/cubit/auth_cubit.dart';
import 'router/app_routes.dart';

/// Guests can browse; buying, topping up, referrals and orders need an
/// account. Returns `true` when the customer is signed in — already, or after
/// the sign-in screen — so the caller continues exactly where it left off.
Future<bool> requireSignIn(BuildContext context) async {
  if (context.read<AuthCubit>().state.isSignedIn) return true;
  final signedIn = await context.push<bool>(AppRoute.login.path);
  return signedIn ?? false;
}
