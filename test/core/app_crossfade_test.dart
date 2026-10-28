import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/constants/app_constants.dart';
import 'package:waysim/core/widgets/app_crossfade.dart';

class _Host extends StatefulWidget {
  const _Host({this.transition = AppScreenTransition.crossfade});

  final AppScreenTransition transition;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  String text = 'Hello';

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: AppCrossfade(
      child: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => AppCrossfade.of(context)!.run(
                () => setState(() => text = 'Привет'),
                transition: widget.transition,
              ),
              child: Text(text),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('every repeated transition starts with a fully opaque snapshot', (
    tester,
  ) async {
    final photo = (await tester.runAsync(
      () => createTestImage(width: 8, height: 8),
    ))!;
    AppCrossfadeState.debugCapture = () async => photo.clone();
    addTearDown(() {
      AppCrossfadeState.debugCapture = null;
      photo.dispose();
    });
    await tester.pumpWidget(const _Host());
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      await tester.pump();
      final fade = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.byType(RawImage),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(
        fade.opacity.value,
        1,
        reason: 'Transition ${i + 1} must cover the theme change',
      );
      await tester.pumpAndSettle();
      expect(find.byType(RawImage), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('the new text appears and the photograph fades away', (
    tester,
  ) async {
    final photo = (await tester.runAsync(
      () => createTestImage(width: 8, height: 8),
    ))!;
    AppCrossfadeState.debugCapture = () async => photo;
    addTearDown(() => AppCrossfadeState.debugCapture = null);

    await tester.pumpWidget(const _Host());
    expect(find.text('Hello'), findsOneWidget);

    await tester.tap(find.text('Hello'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Привет'), findsOneWidget);
    expect(find.byType(RawImage), findsOneWidget);

    final midOpacity =
        (find
                    .ancestor(
                      of: find.byType(RawImage),
                      matching: find.byType(FadeTransition),
                    )
                    .evaluate()
                    .first
                    .widget
                as FadeTransition)
            .opacity
            .value;
    expect(midOpacity, inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(find.byType(RawImage), findsNothing);
    expect(find.text('Привет'), findsOneWidget);
  });

  testWidgets('if the screenshot stalls the change still happens', (
    tester,
  ) async {
    await tester.pumpWidget(const _Host());

    await tester.tap(find.text('Hello'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('Привет'), findsOneWidget);
    expect(find.byType(RawImage), findsNothing);
  });

  testWidgets('the new screen is revealed from left to right', (tester) async {
    final photo = (await tester.runAsync(
      () => createTestImage(width: 8, height: 8),
    ))!;
    AppCrossfadeState.debugCapture = () async => photo;
    addTearDown(() => AppCrossfadeState.debugCapture = null);

    await tester.pumpWidget(
      const _Host(transition: AppScreenTransition.revealFromLeft),
    );
    await tester.tap(find.text('Hello'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump(AppConstants.themeFallbackAnimation);
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Привет'), findsOneWidget);
    final clip = tester.widget<ClipRect>(
      find
          .ancestor(of: find.byType(RawImage), matching: find.byType(ClipRect))
          .first,
    );
    final size = tester.getSize(find.byType(RawImage));
    expect(clip.clipper!.getClip(size).left, greaterThan(0));
    expect(
      tester.getSize(find.byType(RawImage)),
      tester.getSize(find.byType(AppCrossfade)),
    );
    final overlay = tester.widget<AbsorbPointer>(
      find
          .ancestor(
            of: find.byType(RawImage),
            matching: find.byType(AbsorbPointer),
          )
          .first,
    );
    expect(overlay.child, isA<AnimatedBuilder>());

    await tester.pumpAndSettle();
    expect(find.byType(RawImage), findsNothing);
    expect(find.text('Привет'), findsOneWidget);
  });

  testWidgets('the new screen can reveal from right to left', (tester) async {
    final photo = (await tester.runAsync(
      () => createTestImage(width: 8, height: 8),
    ))!;
    AppCrossfadeState.debugCapture = () async => photo;
    addTearDown(() => AppCrossfadeState.debugCapture = null);

    await tester.pumpWidget(
      const _Host(transition: AppScreenTransition.revealFromRight),
    );
    await tester.tap(find.text('Hello'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump(AppConstants.themeFallbackAnimation);
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Привет'), findsOneWidget);
    final clip = tester.widget<ClipRect>(
      find
          .ancestor(of: find.byType(RawImage), matching: find.byType(ClipRect))
          .first,
    );
    final size = tester.getSize(find.byType(RawImage));
    expect(clip.clipper!.getClip(size).right, lessThan(size.width));
    expect(find.byType(RawImage), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(RawImage), findsNothing);
  });

  testWidgets('Reduce Motion changes at once, no photograph', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: const _Host(),
      ),
    );

    await tester.tap(find.text('Hello'));
    await tester.pump();

    expect(find.text('Привет'), findsOneWidget);
    expect(find.byType(RawImage), findsNothing);
  });
}
