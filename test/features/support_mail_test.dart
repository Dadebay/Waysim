import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/services/crash_report.dart';
import 'package:waysim/core/theme/app_theme.dart';
import 'package:waysim/features/support/presentation/support_mail.dart';
import 'package:waysim/features/support/presentation/view/support_sheet.dart';
import 'package:waysim/l10n/app_localizations.dart';
import 'package:waysim/l10n/app_localizations_en.dart';

void main() {
  const device = DeviceContext(
    platform: 'android',
    osVersion: 'Android 16 (API 36)',
    model: 'Samsung SM-A346E',
    appVersion: '1.0.0',
    buildNumber: '1',
    locale: 'en-US',
    flavor: 'production',
    timezone: 'Asia/Ashgabat',
    isEmulator: false,
    isRooted: false,
  );
  final l10n = AppLocalizationsEn();

  test('support mail puts the message first and complete diagnostics last', () {
    final body = buildSupportMailBody(
      message: '  My eSIM is not connecting.  ',
      localizedTemplate: l10n.supportMailTemplate(
        'A000000',
        '1.0.0 (1)',
        device.osVersion,
      ),
      device: device,
      osBuild: 'BP4A.251205.006.A346EXXUEFZE6',
      deviceId: 'server-device-id',
      installId: 'installation-id',
      appLanguage: 'en',
      createdAt: DateTime.utc(2026, 10, 21, 11, 30),
    );

    expect(body, startsWith('My eSIM is not connecting.\n\n'));
    expect(body, isNot(contains('Describe your question here.')));
    expect(body, contains('— Technical details —\nID: A000000'));
    expect(body, contains('App: 1.0.0 (1)'));
    expect(body, contains('System: Android 16 (API 36)'));
    expect(body, contains('Device ID: server-device-id'));
    expect(body, contains('Install ID: installation-id'));
    expect(body, contains('Platform: android'));
    expect(body, contains('Model: Samsung SM-A346E'));
    expect(body, contains('OS build: BP4A.251205.006.A346EXXUEFZE6'));
    expect(body, contains('Device locale: en-US'));
    expect(body, contains('App language: en'));
    expect(body, contains('Time zone: Asia/Ashgabat'));
    expect(body, contains('Emulator: false'));
    expect(body, contains('Rooted / jailbroken: false'));
    expect(body, contains('Environment: production'));
    expect(body, endsWith('Created (UTC): 2026-10-21T11:30:00.000Z'));
  });

  testWidgets('question editor does not show diagnostics while typing', (
    tester,
  ) async {
    await getIt.reset();
    getIt.registerSingleton<DeviceContext>(device);
    addTearDown(() async => getIt.reset());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => writeToSupport(
                context,
                email: 'support@waysim.co',
                id: 'A000000',
              ),
              child: const Text('Open support'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open support'));
    await tester.pumpAndSettle();

    expect(find.text('Describe your question here.'), findsOneWidget);
    expect(find.textContaining('Technical details'), findsNothing);
    expect(find.textContaining('Device ID'), findsNothing);

    await tester.enterText(
      find.byType(TextField),
      'My eSIM is not connecting.',
    );
    await tester.pump();
    expect(find.text('My eSIM is not connecting.'), findsOneWidget);
    expect(find.textContaining('Technical details'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });
}
