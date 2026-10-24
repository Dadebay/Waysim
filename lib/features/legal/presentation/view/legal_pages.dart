import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/bloc/async_cubit.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/app_hero.dart';
import '../../../../core/utils/safe_url.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../config/domain/entities/app_config.dart';
import '../../../config/presentation/cubit/config_cubit.dart';
import '../../domain/entities/legal_document.dart';
import '../widgets/mobile_legal_table_syntax.dart';

/// "More": the six legal documents, then the app's own details.
class LegalListPage extends StatelessWidget {
  const LegalListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    return BlocProvider(
      create: (_) =>
          getIt<AsyncCubit<List<LegalDocument>>>(param1: language)..load(),
      child: const _ListView(),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final state = context.watch<AsyncCubit<List<LegalDocument>>>().state;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        backgroundColor: c.surface,
        leading: IconButton(
          tooltip: l10n.searchBack,
          onPressed: () => context.pop(),
          icon: HugeIcon(icon: AppIcons.back, size: 24, color: c.textPrimary),
        ),
        title: AppHero(
          tag: AppHeroTags.moreTitle,
          child: Material(
            type: MaterialType.transparency,
            child: Text(l10n.more, style: context.text.h2),
          ),
        ),
        centerTitle: true,
      ),
      body: switch (state) {
        AsyncLoading() => const Padding(
          padding: EdgeInsets.all(AppSpacing.page),
          child: SkeletonList(count: 6),
        ),
        AsyncFailure(:final failure) => ErrorView(
          failure: failure,
          onRetry: () => context.read<AsyncCubit<List<LegalDocument>>>().load(),
        ),
        AsyncData(:final data) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.xxxl,
          ),
          children: [
            _DocumentLinks(documents: data),
            const _ContactLinks(),
            const SizedBox(height: AppSpacing.md),
            const _AboutBlock(),
          ],
        ),
      },
    );
  }
}

class _DocumentLinks extends StatelessWidget {
  const _DocumentLinks({required this.documents});

  final List<LegalDocument> documents;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      key: const ValueKey('more-document-links'),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Column(
          children: [
            for (final (index, doc) in documents.indexed) ...[
              if (index > 0) Divider(height: 1, indent: 12, color: c.border),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => context.push(
                    AppRoute.legalDocument.withParams({'id': doc.id}),
                    extra: doc,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppHero(
                              tag: AppHeroTags.legalTitle(doc.id),
                              child: Material(
                                type: MaterialType.transparency,
                                child: Text(
                                  doc.title,
                                  style: context.text.bodyMed,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          HugeIcon(
                            icon: AppIcons.arrowUpRight,
                            size: 17,
                            color: c.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// `meta.contacts`: website, e-mail, Telegram, Instagram. Whatever the admin
/// left empty is not shown; the label is the server's text, the link opens
/// outside the app.
class _ContactLinks extends StatelessWidget {
  const _ContactLinks();

  @override
  Widget build(BuildContext context) {
    final contacts = context.watch<ConfigCubit>().state.contacts;
    final rows = <(AppIconData, ContactLink)>[
      if (contacts.website != null) (AppIcons.globe, contacts.website!),
      if (contacts.email != null) (AppIcons.mail, contacts.email!),
      if (contacts.telegram != null) (AppIcons.send, contacts.telegram!),
      if (contacts.instagram != null) (AppIcons.sparkles, contacts.instagram!),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Container(
        key: const ValueKey('more-contact-links'),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: c.border),
          boxShadow: [
            BoxShadow(
              color: c.shadow,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.xs,
                  ),
                  child: Text(
                    context.l10n.contactsTitle,
                    style: context.text.bodySm.copyWith(color: c.textSecondary),
                  ),
                ),
                for (final (index, (icon, link)) in rows.indexed) ...[
                  if (index > 0)
                    Divider(height: 1, indent: 12, color: c.border),
                  InkWell(
                    onTap: () => _open(link.url),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            HugeIcon(icon: icon, size: 20, color: c.link),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                link.label,
                                style: context.text.bodyMed,
                              ),
                            ),
                            HugeIcon(
                              icon: AppIcons.arrowUpRight,
                              size: 17,
                              color: c.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The link is server text: only `mailto:` and plain `https` open.
  static Future<void> _open(String raw) async {
    final uri = raw.trim().toLowerCase().startsWith('mailto:')
        ? Uri.tryParse(raw.trim())
        : safeHttpsUri(raw);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _AboutBlock extends StatelessWidget {
  const _AboutBlock();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        return Container(
          key: const ValueKey('more-about-card'),
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          decoration: BoxDecoration(
            color: c.background,
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                color: c.shadow,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        const _AppIcon(size: 72),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Waysim',
                          style: context.text.h2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.aboutTagline,
                          textAlign: TextAlign.center,
                          style: context.text.bodySm.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                        if (info != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          _VersionPill(info: info),
                        ],
                      ],
                    ),
                  ),
                  Divider(height: 1, color: c.border),
                  InkWell(
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (_) => _AboutAppDialog(info: info),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 52),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: AppIcons.info,
                              size: 20,
                              color: c.link,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                l10n.aboutApp,
                                style: context.text.bodyMed.copyWith(
                                  color: c.link,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            HugeIcon(
                              icon: AppIcons.chevronRight,
                              size: 18,
                              color: c.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The launcher icon (`assets/brand/app_icon.png`, 512 × 512), clipped to the
/// same rounded square the home screen uses.
class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('about-app-icon'),
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size * 0.2237),
      boxShadow: [
        BoxShadow(
          color: context.colors.shadow,
          blurRadius: size * 0.25,
          offset: Offset(0, size * 0.1),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.2237),
      child: Image.asset(
        'assets/brand/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        excludeFromSemantics: true,
      ),
    ),
  );
}

class _VersionPill extends StatelessWidget {
  const _VersionPill({required this.info});

  final PackageInfo info;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: c.border),
      ),
      child: Text(
        context.l10n.aboutVersion(info.version, info.buildNumber),
        textAlign: TextAlign.center,
        style: context.text.caption.copyWith(
          color: c.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AboutAppDialog extends StatelessWidget {
  const _AboutAppDialog({required this.info});

  final PackageInfo? info;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return Dialog(
      key: const ValueKey('about-app-dialog'),
      backgroundColor: c.background,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.xl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sheet),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  tooltip: l10n.actionClose,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: HugeIcon(
                    icon: AppIcons.close,
                    size: 22,
                    color: c.textSecondary,
                  ),
                ),
              ),
              const _AppIcon(size: 128),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Waysim',
                style: context.text.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.aboutTagline,
                textAlign: TextAlign.center,
                style: context.text.bodyMed.copyWith(color: c.textSecondary),
              ),
              if (info != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _VersionPill(info: info!),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.actionClose,
                size: AppButtonSize.md,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One document, read as plain paragraphs.
class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({super.key, required this.id, this.document});

  final String id;

  /// Passed from the list; when absent (a deep link) the page loads it.
  final LegalDocument? document;

  @override
  Widget build(BuildContext context) {
    if (document != null) {
      return _DocumentScaffold(
        title: document!.title,
        heroTag: AppHeroTags.legalTitle(document!.id),
        body: _DocumentBody(document!),
      );
    }

    final language = Localizations.localeOf(context).languageCode;
    return BlocProvider(
      create: (_) =>
          getIt<AsyncCubit<List<LegalDocument>>>(param1: language)..load(),
      child: _LoadedDocument(id: id),
    );
  }
}

class _LoadedDocument extends StatelessWidget {
  const _LoadedDocument({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AsyncCubit<List<LegalDocument>>>().state;
    final doc = switch (state) {
      AsyncData(:final data) => data.where((item) => item.id == id).firstOrNull,
      _ => null,
    };

    return _DocumentScaffold(
      title: doc?.title ?? context.l10n.more,
      heroTag: doc == null ? null : AppHeroTags.legalTitle(doc.id),
      body: switch (state) {
        AsyncLoading() => const Padding(
          padding: EdgeInsets.all(AppSpacing.page),
          child: SkeletonList(count: 3),
        ),
        AsyncFailure(:final failure) => ErrorView(
          failure: failure,
          onRetry: () => context.read<AsyncCubit<List<LegalDocument>>>().load(),
        ),
        AsyncData() =>
          doc == null
              ? Center(child: Text(context.l10n.errorNotFound))
              : _DocumentBody(doc),
      },
    );
  }
}

class _DocumentScaffold extends StatelessWidget {
  const _DocumentScaffold({
    required this.title,
    required this.body,
    this.heroTag,
  });

  final String title;
  final Widget body;
  final String? heroTag;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: context.l10n.searchBack,
        onPressed: () => context.pop(),
        icon: HugeIcon(
          icon: AppIcons.back,
          size: 24,
          color: context.colors.textPrimary,
        ),
      ),
      title: heroTag == null
          ? Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.h2,
            )
          : AppHero(
              tag: heroTag!,
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.h2,
                ),
              ),
            ),
      centerTitle: true,
    ),
    body: body,
  );
}

class _DocumentBody extends StatelessWidget {
  const _DocumentBody(this.document);

  final LegalDocument document;

  @override
  Widget build(BuildContext context) => document.markdown
      ? LayoutBuilder(
          builder: (context, constraints) => Markdown(
            key: ValueKey(constraints.maxWidth < 600),
            data: document.body,
            selectable: true,
            blockSyntaxes: constraints.maxWidth < 600
                ? const [MobileLegalTableSyntax()]
                : null,
            padding: const EdgeInsets.all(AppSpacing.page),
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                .copyWith(
                  p: context.text.body,
                  h1: context.text.h1,
                  h2: context.text.h2,
                  h3: context.text.h3,
                  a: context.text.body.copyWith(color: context.colors.link),
                  blockSpacing: AppSpacing.md,
                  tableBody: context.text.bodySm,
                  blockquote: context.text.body,
                  blockquotePadding: const EdgeInsets.all(AppSpacing.lg),
                  blockquoteDecoration: BoxDecoration(
                    color: context.colors.surface,
                    border: Border.all(color: context.colors.border),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
            onTapLink: (_, href, _) {
              final uri = Uri.tryParse(href ?? '');
              if (uri != null && ['https', 'mailto'].contains(uri.scheme)) {
                launchUrl(uri);
              }
            },
          ),
        )
      : ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            for (final paragraph in document.body.split('\n\n'))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(paragraph, style: context.text.body),
              ),
          ],
        );
}
