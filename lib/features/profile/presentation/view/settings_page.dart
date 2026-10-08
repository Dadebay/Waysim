import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/cubit/locale_cubit.dart';
import '../../../../app/cubit/theme_cubit.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_crossfade.dart';
import '../../../../core/widgets/app_hero.dart';
import '../../../../core/widgets/flag_icon.dart';
import '../../../notification/presentation/cubit/notification_prefs_cubit.dart';
import '../widgets/theme_picker.dart';

/// Language (five, with flags) and theme (light / dark). Notification
/// switches arrive with push in docs/06-roadmap.md T5.4.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = AppLanguage.fromLocale(context.watch<LocaleCubit>().state);
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
          icon: HugeIcon(
            icon: AppIcons.back,
            size: 24,
            color: context.colors.textPrimary,
          ),
        ),
        title: AppHero(
          tag: AppHeroTags.settingsTitle,
          child: Material(
            type: MaterialType.transparency,
            child: Text(l10n.settings, style: context.text.h2),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          _SectionLabel(l10n.settingsLanguage),
          _LanguageGrid(
            current: current,
            onPick: (lang) {
              if (lang == current) return;
              HapticFeedback.selectionClick();
              final cubit = context.read<LocaleCubit>();
              // The whole app redraws in the new language: fade it in rather
              // than flashing.
              void change() => cubit.setLocale(lang.locale);
              final fade = AppCrossfade.of(context);
              fade == null ? change() : fade.run(change);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel(l10n.settingsTheme),
          ThemePicker(
            mode: isDark ? ThemeMode.dark : ThemeMode.light,
            onChanged: (mode) {
              final cubit = context.read<ThemeCubit>();
              void change() => cubit.setThemeMode(mode);
              final transition = AppCrossfade.of(context);
              transition == null
                  ? change()
                  : transition.run(
                      change,
                      transition: mode == ThemeMode.light
                          ? AppScreenTransition.revealFromLeft
                          : AppScreenTransition.revealFromRight,
                    );
            },
          ),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionLabel(l10n.settingsNotifications),
          _SwitchRow(
            title: l10n.notifEsimTitle,
            body: l10n.notifEsimBody,
            value: context.watch<NotificationPrefsCubit>().state.esim,
            onChanged: context.read<NotificationPrefsCubit>().setEsim,
          ),
          _SwitchRow(
            title: l10n.notifNewsTitle,
            body: l10n.notifNewsBody,
            value: context.watch<NotificationPrefsCubit>().state.news,
            onChanged: context.read<NotificationPrefsCubit>().setNews,
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.xxl),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: HugeIcon(
                icon: AppIcons.sparkles,
                size: 22,
                color: context.colors.primary,
              ),
              title: Text(l10n.settingsGallery),
              trailing: HugeIcon(
                icon: AppIcons.chevronRight,
                size: 20,
                color: context.colors.textSecondary,
              ),
              onTap: () => context.pushNamed(AppRoute.gallery.routeName),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(
      text.toUpperCase(),
      style: context.text.caption.copyWith(
        color: context.colors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    ),
  );
}

// ── Language: 2-col flag cards, selected glows ────────────────────────────

class _LanguageGrid extends StatelessWidget {
  const _LanguageGrid({required this.current, required this.onPick});

  final AppLanguage current;
  final ValueChanged<AppLanguage> onPick;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.35,
      ),
      itemCount: AppLanguage.values.length + 1,
      itemBuilder: (context, i) {
        // Last cell: filler keeps grid balanced when count is odd (5 langs).
        if (i >= AppLanguage.values.length) {
          return const SizedBox.shrink();
        }
        final lang = AppLanguage.values[i];
        return _LanguageCard(
          language: lang,
          selected: lang == current,
          onTap: () => onPick(lang),
        );
      },
    );
  }
}

class _LanguageCard extends StatefulWidget {
  const _LanguageCard({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<_LanguageCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final radius = BorderRadius.circular(AppRadius.card);
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.language.nativeName,
      excludeSemantics: true,
      child: AnimatedScale(
        scale: _pressed && !reduceMotion ? 0.97 : 1,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: reduceMotion ? Duration.zero : AppConstants.animationBase,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: widget.selected ? c.primary : c.surface,
            borderRadius: radius,
            border: Border.all(
              color: widget.selected ? c.primary : c.border,
              width: widget.selected ? 1.5 : 1,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: c.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              excludeFromSemantics: true,
              onHighlightChanged: (pressed) =>
                  setState(() => _pressed = pressed),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.selected
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: FlagIcon(widget.language.flagCode, size: 32),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.language.nativeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMed.copyWith(
                          color: widget.selected
                              ? c.textOnPrimary
                              : c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: reduceMotion
                          ? Duration.zero
                          : AppConstants.animationFast,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeOutCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween(begin: 0.9, end: 1.0).animate(animation),
                          child: child,
                        ),
                      ),
                      child: widget.selected
                          ? HugeIcon(
                              key: const ValueKey('selected'),
                              icon: AppIcons.check,
                              size: 20,
                              color: c.textOnPrimary,
                            )
                          : const SizedBox(
                              key: ValueKey('unselected'),
                              width: 20,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.body,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String body;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      toggled: value,
      label: title,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.text.bodyMed.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        body,
                        style: context.text.caption.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: c.primary,
                activeThumbColor: c.textOnPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
