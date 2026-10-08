import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/copy_field.dart';
import '../../../../core/widgets/country_row.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/flag_icon.dart';
import '../../../../core/widgets/otp_field.dart';
import '../../../../core/widgets/package_tile.dart';
import '../../../../core/widgets/promo_carousel.dart';
import '../../../../core/widgets/segmented_tabs.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/usage_progress.dart';

/// Every design-system component, drawn twice — once in the light theme and
/// once in the dark theme — so both can be reviewed on one screen. Reached
/// from Settings in debug builds only (docs/06-roadmap.md T1.7).
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: HugeIcon(
            icon: AppIcons.back,
            size: 24,
            color: context.colors.textPrimary,
          ),
        ),
        title: Text(context.l10n.settingsGallery),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _Section('Colors', (_) => const _Palette()),
          _Section('Typography', (_) => const _Type()),
          _Section('Buttons', (_) => const _Buttons()),
          _Section('Fields', (_) => const _Fields()),
          _Section('Status badges', (_) => const _Badges()),
          _Section('Rows, tiles, tabs', (_) => const _Rows()),
          _Section('Cards, usage, copy', (_) => const _Cards()),
          _Section('Sheet, toast, loading', (_) => const _Feedback()),
          _Section('Empty state', (_) => const _Empty()),
          _Section('Banners', (_) => const _Banners()),
          _Section('Flags & languages', (_) => const _Flags()),
        ],
      ),
    );
  }
}

/// A titled section rendered in both themes, light first.
class _Section extends StatelessWidget {
  const _Section(this.title, this.builder);

  final String title;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.h2),
        const SizedBox(height: AppSpacing.md),
        _Panel(theme: AppTheme.light, label: 'LIGHT', builder: builder),
        const SizedBox(height: AppSpacing.md),
        _Panel(theme: AppTheme.dark, label: 'DARK', builder: builder),
      ],
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.theme,
    required this.label,
    required this.builder,
  });

  final ThemeData theme;
  final String label;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          final c = context.colors;
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Material(
              color: c.background,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: c.border),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: context.text.caption.copyWith(
                          color: c.textSecondary,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      builder(context),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Palette extends StatelessWidget {
  const _Palette();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final swatches = <(String, Color)>[
      ('primary', c.primary),
      ('primaryPressed', c.primaryPressed),
      ('primarySubtle', c.primarySubtle),
      ('link', c.link),
      ('background', c.background),
      ('surface', c.surface),
      ('textPrimary', c.textPrimary),
      ('textSecondary', c.textSecondary),
      ('border', c.border),
      ('success', c.success),
      ('warning', c.warning),
      ('error', c.error),
      ('errorSubtle', c.errorSubtle),
    ];
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final (name, color) in swatches)
          SizedBox(
            width: 92,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: c.border),
                  ),
                ),
                const SizedBox(height: 4),
                Text(name, style: context.text.caption),
              ],
            ),
          ),
      ],
    );
  }
}

class _Type extends StatelessWidget {
  const _Type();

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('eSIM is ready!', style: t.display),
        Text('My eSIM · Мои eSIM', style: t.h1),
        Text('Package details', style: t.h2),
        Text('Install via QR code', style: t.h3),
        Text('Install your eSIM now while on Wi-Fi.', style: t.body),
        Text('Balance after purchase', style: t.bodyMed),
        Text('Validity starts on first connection', style: t.bodySm),
        Text(
          'By placing the order you confirm compatibility',
          style: t.caption,
        ),
        Text('你好 · Español · Français', style: t.body),
      ],
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons();

  @override
  Widget build(BuildContext context) {
    void noop() {}
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            AppButton(label: 'Primary lg', onPressed: noop, expand: false),
            AppButton(
              label: 'Primary md',
              onPressed: noop,
              size: AppButtonSize.md,
              expand: false,
            ),
            AppButton(
              label: 'Primary sm',
              onPressed: noop,
              size: AppButtonSize.sm,
              expand: false,
            ),
            AppButton(
              label: 'Secondary',
              onPressed: noop,
              variant: AppButtonVariant.secondary,
              expand: false,
            ),
            AppButton(
              label: 'Ghost',
              onPressed: noop,
              variant: AppButtonVariant.ghost,
              expand: false,
            ),
            AppButton(
              label: 'Danger',
              onPressed: noop,
              variant: AppButtonVariant.danger,
              expand: false,
            ),
            const AppButton(label: 'Disabled', onPressed: null, expand: false),
            AppButton(
              label: 'Loading',
              onPressed: noop,
              loading: true,
              expand: false,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(label: 'Pay \$5.99', onPressed: noop, icon: AppIcons.wallet),
      ],
    );
  }
}

class _Fields extends StatefulWidget {
  const _Fields();

  @override
  State<_Fields> createState() => _FieldsState();
}

class _FieldsState extends State<_Fields> {
  final _otp = TextEditingController(text: '48');

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const AppTextField(label: 'Email', hint: 'name@example.com'),
      const SizedBox(height: AppSpacing.lg),
      const AppTextField(
        label: 'Email (error)',
        hint: 'name@example.com',
        errorText: 'Enter a valid email address',
      ),
      const SizedBox(height: AppSpacing.lg),
      OtpField(controller: _otp, autofocus: false),
      const SizedBox(height: AppSpacing.lg),
      OtpField(
        controller: TextEditingController(text: '123456'),
        autofocus: false,
        hasError: true,
      ),
    ],
  );
}

class _Badges extends StatelessWidget {
  const _Badges();

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      StatusBadge(label: 'Processing', tone: StatusTone.info),
      StatusBadge(label: 'Not installed', tone: StatusTone.warning),
      StatusBadge(label: 'Installed', tone: StatusTone.info),
      StatusBadge(label: 'Active', tone: StatusTone.success),
      StatusBadge(label: 'Used up', tone: StatusTone.neutral),
      StatusBadge(label: 'Expired', tone: StatusTone.neutral),
      StatusBadge(label: 'Failed, refunded', tone: StatusTone.error),
    ],
  );
}

class _Rows extends StatefulWidget {
  const _Rows();

  @override
  State<_Rows> createState() => _RowsState();
}

class _RowsState extends State<_Rows> {
  int _tab = 0;
  int _package = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SegmentedTabs(
          labels: const ['Local', 'Regional'],
          selectedIndex: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: AppSpacing.md),
        CountryRow(
          leading: const FlagIcon('tr'),
          title: 'Türkiye',
          price: r'$1.99',
          pricePrefix: 'from ',
          onTap: () {},
        ),
        CountryRow(
          leading: const FlagIcon('az'),
          title: 'Azerbaijan',
          price: r'$4.99',
          pricePrefix: 'from ',
          highlight: 2,
          onTap: () {},
        ),
        CountryRow(
          leading: const RegionIcon(),
          title: 'Asia',
          subtitle: '20 countries',
          price: r'$8.99',
          pricePrefix: 'from ',
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        for (final (i, p) in const [
          ('1 GB', '7 days', r'$1.99'),
          ('3 GB', '30 days', r'$3.99'),
          ('5 GB', '30 days', r'$5.99'),
        ].indexed) ...[
          PackageTile(
            volume: p.$1,
            duration: p.$2,
            price: p.$3,
            selected: i == _package,
            onTap: () => setState(() => _package = i),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _Cards extends StatelessWidget {
  const _Cards();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          elevated: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const FlagIcon('tr'),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text('Türkiye', style: context.text.h3)),
                  const StatusBadge(label: 'Active', tone: StatusTone.success),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '3.2 GB of 5 GB left',
                      style: context.text.bodySm,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      '18 days left',
                      textAlign: TextAlign.end,
                      style: context.text.bodySm.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const UsageProgress(remainingFraction: 0.64),
              const SizedBox(height: AppSpacing.sm),
              const UsageProgress(remainingFraction: 0.08),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const CopyField(label: 'SM-DP+ address', value: 'smdp.example.com'),
        const SizedBox(height: AppSpacing.sm),
        const CopyField(
          label: 'Activation code',
          value: 'K2-4F7Q-9XHD-2M8A',
          monospace: true,
        ),
      ],
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            AppButton(
              label: 'Show toast',
              expand: false,
              size: AppButtonSize.md,
              variant: AppButtonVariant.secondary,
              onPressed: () => AppToast.show(context, context.l10n.toastCopied),
            ),
            AppButton(
              label: 'Show sheet',
              expand: false,
              size: AppButtonSize.md,
              variant: AppButtonVariant.secondary,
              onPressed: () => showAppSheet<void>(
                context,
                title: 'Package details',
                subtitle: 'Türkiye · 5 GB · 30 days',
                builder: (_) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    0,
                    AppSpacing.page,
                    AppSpacing.xxl,
                  ),
                  child: AppButton(label: 'Buy for \$5.99', onPressed: () {}),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonList(count: 3),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: AppIcons.myEsim,
    title: 'No eSIMs yet',
    body: 'Buy a plan for your trip — it only takes a couple of minutes.',
    actions: [
      AppButton(label: 'Get an eSIM', onPressed: () {}),
      AppButton(
        label: 'How eSIM works',
        onPressed: () {},
        variant: AppButtonVariant.ghost,
      ),
    ],
  );
}

class _Banners extends StatelessWidget {
  const _Banners();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget banner(String title, AppIconData icon) => DecoratedBox(
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HugeIcon(icon: icon, size: 28, color: c.textOnPrimary),
            const Spacer(),
            Text(
              title,
              style: context.text.h2.copyWith(color: c.textOnPrimary),
            ),
          ],
        ),
      ),
    );
    return SizedBox(
      // Panels are inset; the carousel wants full width, so give it room.
      height: 220,
      child: PromoCarousel(
        height: 190,
        children: [
          banner('What is eSIM?', AppIcons.myEsim),
          banner('Invite a friend', AppIcons.gift),
          banner('Travel easy', AppIcons.globe),
        ],
      ),
    );
  }
}

class _Flags extends StatelessWidget {
  const _Flags();

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.md,
    runSpacing: AppSpacing.md,
    children: [
      for (final l in AppLanguage.values)
        Column(
          children: [
            FlagIcon(l.flagCode, size: 40),
            const SizedBox(height: 4),
            Text(l.nativeName, style: context.text.caption),
          ],
        ),
      for (final code in const ['us', 'tr', 'de', 'jp', 'es', 'xx-missing'])
        FlagIcon(code, size: 32),
    ],
  );
}
