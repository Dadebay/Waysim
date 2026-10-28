import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../utils/extensions/context_extensions.dart';

class SupportFab extends StatelessWidget {
  const SupportFab({super.key, required this.onPressed, this.unread = 0});

  final VoidCallback onPressed;
  final int unread;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: context.l10n.supportFabLabel,
      value: unread > 0 ? '$unread' : null,
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
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: HugeIcon(
                    icon: AppIcons.support,
                    size: 24,
                    color: c.textOnPrimary,
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.background, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
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
