import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/cubit/auth_cubit.dart';
import 'router/app_routes.dart';

Future<bool> requireSignIn(BuildContext context) async {
  if (context.read<AuthCubit>().state.isSignedIn) return true;
  final signedIn = await context.push<bool>(AppRoute.login.path);
  return signedIn ?? false;
}
