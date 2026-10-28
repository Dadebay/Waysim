import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_icons.dart';
import '../utils/extensions/context_extensions.dart';

class FlagIcon extends StatelessWidget {
  const FlagIcon(this.code, {super.key, this.size = 32});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primarySubtle,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: HugeIcon(
          icon: AppIcons.globe,
          size: size * 0.6,
          color: colors.primary,
        ),
      ),
    );

    return SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: SvgPicture.asset(
          'assets/flags/${code.toLowerCase()}.svg',
          fit: BoxFit.cover,

          alignment: Alignment.center,
          width: size,
          height: size,
          placeholderBuilder: (_) => fallback,
          errorBuilder: (_, _, _) => fallback,
        ),
      ),
    );
  }
}
