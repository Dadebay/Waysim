import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

class OtpField extends StatefulWidget {
  const OtpField({
    super.key,
    required this.controller,
    this.onCompleted,
    this.onChanged,
    this.hasError = false,
    this.enabled = true,
    this.autofocus = true,
    this.length = 6,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final bool enabled;
  final bool autofocus;
  final int length;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onText);
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    _focus.dispose();
    super.dispose();
  }

  void _onText() {
    setState(() {});
    final text = widget.controller.text;
    widget.onChanged?.call(text);
    if (text.length == widget.length) widget.onCompleted?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    final activeIndex = text.length.clamp(0, widget.length - 1);

    return Stack(
      alignment: Alignment.center,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = AppSpacing.sm;
            final cellWidth =
                ((constraints.maxWidth - gap * (widget.length - 1)) /
                        widget.length)
                    .clamp(0.0, 52.0);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < widget.length; i++)
                  _Cell(
                    width: cellWidth,
                    char: i < text.length ? text[i] : '',
                    active: _focus.hasFocus && i == activeIndex,
                    error: widget.hasError,
                  ),
              ],
            );
          },
        ),

        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: widget.controller,
              enabled: widget.enabled,
              focusNode: _focus,
              autofocus: widget.autofocus,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              enableInteractiveSelection: false,
              showCursor: false,
              maxLength: widget.length,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(counterText: ''),
            ),
          ),
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.width,
    required this.char,
    required this.active,
    required this.error,
  });

  final double width;
  final String char;
  final bool active;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final borderColor = error
        ? c.error
        : active
        ? c.primary
        : c.border;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: error
            ? c.errorSubtle
            : active
            ? c.primarySubtle
            : c.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: borderColor, width: active ? 1.5 : 1),
      ),
      child: Text(char, style: context.text.h2),
    );
  }
}
