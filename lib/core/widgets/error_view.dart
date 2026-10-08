import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../error/failure.dart';
import '../localization/failure_localizer.dart';
import '../utils/extensions/context_extensions.dart';
import 'app_button.dart';
import 'empty_state.dart';

/// A failed load: the failure in the customer's language and a Retry button.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.failure, required this.onRetry});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      icon: failure is NetworkFailure ? AppIcons.offline : AppIcons.error,
      title: failure.localize(l10n),
      actions: [
        AppButton(
          label: l10n.actionRetry,
          onPressed: onRetry,
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.md,
          expand: false,
        ),
      ],
    );
  }
}
