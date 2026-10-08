import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_icons.dart';
import '../utils/extensions/context_extensions.dart';

/// A country flag from `assets/flags/{code}.svg`, clipped to a circle.
///
/// [code] is an ISO 3166-1 alpha-2 code in any case (`TR`, `tr`); the set also
/// holds a few non-country codes (`eu`, `un`, …). When the file does not
/// exist — a region code from the supplier, a typo — a globe stands in, so a
/// missing flag never breaks a row.
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
          // The flags are 4:3; cover + a square box crops the sides evenly.
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
