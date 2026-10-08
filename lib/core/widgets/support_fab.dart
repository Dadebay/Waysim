import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../utils/extensions/context_extensions.dart';

/// 56 pt floating support button.
class SupportFab extends StatelessWidget {
  const SupportFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: context.l10n.supportFabLabel,
      excludeSemantics: true,
      child: Material(
        color: c.primary,
        shape: const CircleBorder(),
        elevation: 6,
        shadowColor: c.shadow,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 56,
            child: Center(
              child: HugeIcon(
                icon: AppIcons.support,
                size: 24,
                color: c.textOnPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
