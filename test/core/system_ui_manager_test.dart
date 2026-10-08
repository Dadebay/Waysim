import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/utils/system_ui_manager.dart';

class _Counting extends SystemUiManager {
  _Counting() : super(hideDelay: const Duration(seconds: 3));

  var applied = 0;

  @override
  Future<void> apply() async => applied++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('hides the navigation bar and keeps the status bar', () async {
    final calls = <MethodCall>[];
    final androidCalls = <MethodCall>[];
    const androidUi = MethodChannel('com.waysim.app/system_ui');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(androidUi, (call) async {
          androidCalls.add(call);
          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(androidUi, null);
    });

    await SystemUiManager().apply();

    // Manual mode is sent as "enable only these overlays": just the top one
    // (the status bar), so the navigation bar is the one that goes.
    final call = calls.singleWhere(
      (c) => c.method == 'SystemChrome.setEnabledSystemUIOverlays',
    );
    expect(call.arguments, ['SystemUiOverlay.top']);
    expect(androidCalls.single.method, 'hideNavigationBar');
  });

  test(
    'an older Android install without the native channel does not crash',
    () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            calls.add(call);
            return null;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      final manager = SystemUiManager();
      await manager.apply();
      await manager.apply();

      expect(
        calls.where(
          (call) => call.method == 'SystemChrome.setEnabledSystemUIOverlays',
        ),
        hasLength(2),
      );
    },
  );

  testWidgets('the bar swiped back in is hidden again after a delay', (
    tester,
  ) async {
    final manager = _Counting();

    manager.handleBottomPadding(48); // the bar is on screen again
    await tester.pump(const Duration(seconds: 2));
    expect(manager.applied, 0);

    await tester.pump(const Duration(seconds: 2));
    expect(manager.applied, 1);

    manager.dispose();
  });

  testWidgets('a bar that is already gone schedules nothing', (tester) async {
    final manager = _Counting();

    manager.handleBottomPadding(0);
    await tester.pump(const Duration(seconds: 10));

    expect(manager.applied, 0);
    manager.dispose();
  });

  testWidgets('repeated metrics ticks do not restart the countdown', (
    tester,
  ) async {
    final manager = _Counting();

    manager.handleBottomPadding(48);
    await tester.pump(const Duration(seconds: 2));
    manager.handleBottomPadding(48); // another tick mid-countdown
    await tester.pump(const Duration(seconds: 1, milliseconds: 100));

    expect(manager.applied, 1);
    manager.dispose();
  });
}
