import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/labels.dart';
import '../../../../core/widgets/country_row.dart';
import '../../../../core/widgets/app_hero.dart';
import '../../../../core/widgets/flag_icon.dart';
import '../../../catalog/domain/entities/destination.dart';

class DestinationRow extends StatelessWidget {
  const DestinationRow({
    super.key,
    required this.destination,
    this.highlight,
    this.onOpen,
    this.searchStyle = false,
  });

  final Destination destination;
  final int? highlight;

  final VoidCallback? onOpen;
  final bool searchStyle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final (prefix, suffix) = l10n.priceFromParts;
    final d = destination;

    return CountryRow(
      leading: AppHero(
        tag: AppHeroTags.destinationFlag(d.code),
        child: d.isRegion
            ? RegionIcon(size: searchStyle ? 32 : 40)
            : FlagIcon(d.flagCode!, size: searchStyle ? 32 : 40),
      ),
      title: d.nameFor(language),
      subtitle: d.isRegion
          ? (d.coverageNote ?? l10n.regionCountries(d.countryCount ?? 0))
          : null,
      price: d.minPrice.format(),
      pricePrefix: prefix,
      priceSuffix: suffix,
      highlight: highlight,
      showChevron: !searchStyle,
      onTap: () {
        onOpen?.call();
        context.push(AppRoute.destination.withParams({'code': d.code}));
      },
    );
  }
}

class DestinationList extends StatelessWidget {
  const DestinationList({super.key, required this.destinations});

  final List<Destination> destinations;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (i, d) in destinations.indexed) ...[
          DestinationRow(destination: d),
          if (i < destinations.length - 1)
            Divider(color: context.colors.border, height: AppSpacing.xs),
        ],
      ],
    );
  }
}
