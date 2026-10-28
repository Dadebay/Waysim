import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

class PromoCarousel extends StatefulWidget {
  const PromoCarousel({
    super.key,
    required this.children,
    this.interval = AppConstants.bannerAutoScroll,
    this.height = 232,
    this.aspectRatio,
  });

  final List<Widget> children;
  final Duration interval;
  final double height;

  final double? aspectRatio;

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  static const _viewportFraction = 0.93;

  static const _loopSpan = 10000;

  late PageController _controller = _newController();
  Timer? _timer;

  late int _page = _startPage;
  bool _touching = false;

  int get _count => widget.children.length;

  int get _startPage => _count > 1 ? _count * _loopSpan : 0;

  int get _visible => _count == 0 ? 0 : _page % _count;

  PageController _newController({int? initialPage}) => PageController(
    viewportFraction: _viewportFraction,
    initialPage: initialPage ?? _startPage,
    keepPage: false,
  );

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(PromoCarousel old) {
    super.didUpdateWidget(old);
    if (widget.children.length != old.children.length) {
      final visible = _indexAfterChildrenChange(old.children);
      _controller.dispose();
      _page = _startPage + visible;
      _controller = _newController(initialPage: _page);
      _start();
    }
  }

  int _indexAfterChildrenChange(List<Widget> previous) {
    if (_count == 0 || previous.isEmpty) return 0;
    final oldIndex = _page % previous.length;

    for (var offset = 0; offset < previous.length; offset++) {
      final key = previous[(oldIndex + offset) % previous.length].key;
      if (key == null) continue;
      final index = widget.children.indexWhere((child) => child.key == key);
      if (index >= 0) return index;
    }
    return oldIndex.clamp(0, _count - 1);
  }

  void _start() {
    _timer?.cancel();
    if (_count < 2) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (_touching || !_controller.hasClients) return;
      _controller.animateToPage(
        _page + 1,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final count = _count;
    if (count == 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = widget.aspectRatio;
        final slideHeight = ratio != null && ratio > 0
            ? constraints.maxWidth * _viewportFraction / ratio
            : widget.height;

        return Column(
          children: [
            SizedBox(
              height: slideHeight,
              child: Listener(
                onPointerDown: (_) => _touching = true,
                onPointerUp: (_) => _touching = false,
                onPointerCancel: (_) => _touching = false,
                child: PageView.builder(
                  key: ValueKey(_controller),
                  controller: _controller,
                  itemCount: count > 1 ? null : 1,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, page) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm - 2,
                    ),
                    child: widget.children[page % count],
                  ),
                ),
              ),
            ),
            if (count > 1) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < count; i++)
                    AnimatedContainer(
                      duration: AppConstants.animationFast,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _visible ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _visible ? c.primary : c.border,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
