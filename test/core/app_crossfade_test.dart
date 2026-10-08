import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/widgets/app_crossfade.dart';

/// A screen whose text can be swapped from a button, standing in for a
/// language change.
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
    await tester.pump(); // photograph goes on
    await tester.pump(); // language changes underneath
    await tester.pump(); // the fade's ticker starts
    await tester.pump(); // first frame after the new screen paints
    await tester.pump(const Duration(milliseconds: 150)); // mid-fade

    // The new language is already drawn under the old picture.
    expect(find.text('Привет'), findsOneWidget);
    expect(find.byType(RawImage), findsOneWidget);
    // The nearest fade above the picture is the one that dissolves it.
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

    // Under the fake clock toImage never completes; the timeout takes over.
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
    await tester.pump(const Duration(milliseconds: 200));
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
    await tester.pump(const Duration(milliseconds: 200));
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
