import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/error/failure.dart';
import 'package:waysim/core/theme/app_theme.dart';
import 'package:waysim/core/utils/result.dart';
import 'package:waysim/features/auth/domain/entities/user.dart';
import 'package:waysim/features/auth/domain/repositories/auth_repository.dart';
import 'package:waysim/features/auth/presentation/view/devices_page.dart';
import 'package:waysim/l10n/app_localizations.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

class _DevicesRepository implements AuthRepository {
  final removed = <String>[];
  final removal = Completer<Result<void>>();
  var items = const [
    DeviceInfo(
      id: 'current',
      model: 'Samsung SM-A346E',
      os: 'Android 16',
      isCurrent: true,
    ),
    DeviceInfo(
      id: 'old',
      model: 'Samsung SM-A346E',
      os: 'Android 16',
      isCurrent: false,
    ),
    DeviceInfo(
      id: 'iphone',
      model: 'iPhone11,6',
      os: 'iOS 18.7.10',
      isCurrent: false,
    ),
  ];
  @override
  Future<Result<List<DeviceInfo>>> devices() async => Success(items);
  @override
  Future<Result<void>> revokeDevice(String id) async {
    removed.add(id);
    final result = await removal.future;
    if (result.isSuccess) items = items.where((d) => d.id != id).toList();
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(loadAppFonts);
  setUp(setUpTestDependencies);

  for (final fail in [false, true]) {
    testWidgets(
      'device removal confirms, waits and preserves failures ($fail)',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final repository = _DevicesRepository();
        await getIt.unregister<AuthRepository>();
        getIt.registerSingleton<AuthRepository>(repository);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DevicesPage(),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Galaxy A34'), findsNWidgets(2));
        expect(find.text('iPhone XS Max'), findsOneWidget);
        expect(find.text('This device'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('remove-device-current')),
          findsNothing,
        );
        final remove = find.byKey(const ValueKey('remove-device-old'));
        await tester.tap(remove);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(repository.removed, isEmpty);
        await tester.tap(remove);
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Remove device'),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(repository.removed, ['old']);
        expect(find.byKey(const ValueKey('device-old')), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(
          tester
              .widget<IconButton>(
                find.byKey(const ValueKey('remove-device-iphone')),
              )
              .onPressed,
          isNull,
        );
        repository.removal.complete(
          fail ? const Error(NetworkFailure()) : const Success(null),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('device-old')),
          fail ? findsOneWidget : findsNothing,
        );
        expect(find.byKey(const ValueKey('device-current')), findsOneWidget);
        expect(find.byKey(const ValueKey('device-iphone')), findsOneWidget);
        if (!fail) {
          await tester.drag(find.byType(ListView), const Offset(0, 400));
          await tester.pumpAndSettle();
          expect(find.byKey(const ValueKey('device-old')), findsNothing);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
