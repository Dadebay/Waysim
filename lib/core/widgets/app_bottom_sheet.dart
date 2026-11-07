import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
  String? subtitle,
  bool showClose = true,
  bool isDismissible = true,
  String? closeLabel,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    backgroundColor: context.colors.background,
    builder: (sheetContext) => AppSheetFrame(
      title: title,
      subtitle: subtitle,
      showClose: showClose,
      closeLabel: closeLabel,
      child: builder(sheetContext),
    ),
  );
}

class AppSheetFrame extends StatelessWidget {
  const AppSheetFrame({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showClose = true,
    this.closeLabel,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final bool showClose;
  final String? closeLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.xl,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title!, style: context.text.h2),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            subtitle!,
                            style: context.text.bodySm.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showClose) ...[
                    const SizedBox(width: AppSpacing.md),
                    _CloseButton(label: closeLabel),
                  ],
                ],
              ),
            )
          else
            const SizedBox(height: AppSpacing.lg),
          Flexible(child: child),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: label ?? MaterialLocalizations.of(context).closeButtonLabel,
      excludeSemantics: true,
      child: InkResponse(
        onTap: () => Navigator.of(context).maybePop(),
        radius: 24,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: c.surface, shape: BoxShape.circle),
          child: Center(
            child: HugeIcon(
              icon: AppIcons.close,
              size: 20,
              color: c.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
