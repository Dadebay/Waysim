import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.prefix,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = false,
    this.maxLength,
    this.enabled = true,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefix;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final int? maxLength;
  final bool enabled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasError = widget.errorText != null;
    final focused = _focus.hasFocus;

    final borderColor = hasError
        ? c.error
        : focused
        ? c.primary
        : c.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: context.text.bodySm.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: hasError ? c.errorSubtle : c.background,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: borderColor, width: focused ? 1.5 : 1),
          ),
          child: Row(
            children: [
              if (widget.prefix != null)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.lg),
                  child: widget.prefix,
                ),
              Expanded(
                child: TextField(
                  focusNode: _focus,
                  controller: widget.controller,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  autofillHints: widget.autofillHints,
                  inputFormatters: widget.inputFormatters,
                  textCapitalization: widget.textCapitalization,
                  autocorrect: widget.autocorrect,
                  maxLength: widget.maxLength,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  cursorColor: c.primary,
                  style: context.text.body,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: context.text.body.copyWith(
                      color: c.textSecondary,
                    ),
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError || widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            widget.errorText ?? widget.helperText!,
            style: context.text.caption.copyWith(
              color: hasError ? c.error : c.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
