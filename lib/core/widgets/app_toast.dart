import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

/// Short confirmation ("Copied") as a dark floating pill with a check.
abstract final class AppToast {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final c = context.colors;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            AppSpacing.xxl + 72,
          ),
          content: Align(
            alignment: Alignment.bottomCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                // Inverse of the page: dark on light, light on dark.
                color: c.textPrimary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: isError ? AppIcons.error : AppIcons.check,
                      size: 18,
                      color: c.background,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        message,
                        style: context.text.bodySm.copyWith(
                          color: c.background,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}
