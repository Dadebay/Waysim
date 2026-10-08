import 'package:flutter/material.dart';

/// Shared route identities for elements that visibly continue onto a page.
abstract final class AppHeroTags {
  static String destinationFlag(String code) => 'destination:$code:flag';
  static String esimHeader(String id) => 'esim:$id:header';
  static String legalTitle(String id) => 'legal:$id:title';
  static const settingsTitle = 'profile:settings:title';
  static const moreTitle = 'profile:more:title';
}

/// Hero flights are skipped when the system requests reduced motion.
class AppHero extends StatelessWidget {
  const AppHero({super.key, required this.tag, required this.child});

  final Object tag;
  final Widget child;

  @override
  Widget build(BuildContext context) => MediaQuery.disableAnimationsOf(context)
      ? child
      : Hero(tag: tag, child: child);
}
