import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/theme/app_theme.dart';
import 'package:waysim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:waysim/features/config/presentation/cubit/config_cubit.dart';
import 'package:waysim/features/support/presentation/view/chat_page.dart';
import 'package:waysim/l10n/app_localizations.dart';

import '../helpers/load_fonts.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(loadAppFonts);
  setUp(setUpTestDependencies);

  testWidgets('chat placeholder is centered in its input capsule', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: getIt<AuthCubit>()),
          BlocProvider<ConfigCubit>.value(value: getIt<ConfigCubit>()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChatPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final field = tester.getRect(find.byType(TextField));
    final hint = tester.getRect(find.text('Type a message'));
    final decorator = tester.getRect(find.byType(InputDecorator));
    final editable = tester.getRect(
      find.descendant(
        of: find.byType(TextField),
        matching: find.byType(EditableText),
      ),
    );
    expect(
      (hint.center.dy - field.center.dy).abs(),
      lessThan(4),
      reason:
          'field: $field, decorator: $decorator, editable: $editable, hint: $hint',
    );
  });
}
