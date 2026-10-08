import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/theme/app_theme.dart';
import 'package:waysim/core/widgets/otp_field.dart';

import '../helpers/load_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('six code cells fit a narrow phone and submit once complete', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? submitted;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: OtpField(
              controller: controller,
              onCompleted: (code) => submitted = code,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    expect(submitted, '123456');
    expect(tester.takeException(), isNull);
  });
}
