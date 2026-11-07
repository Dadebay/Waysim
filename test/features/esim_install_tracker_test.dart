import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/storage/local_storage.dart';
import 'package:waysim/features/catalog/domain/entities/esim_package.dart';
import 'package:waysim/features/esim/domain/entities/esim.dart';
import 'package:waysim/features/esim/presentation/esim_install_tracker.dart';

import '../helpers/test_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'an already active plan does not prove a new install succeeded',
    () async {
      await setUpTestDependencies();
      await EsimInstallTracker.start(
        'already-active',
        method: 'one_tap',
        statusAtStart: EsimStatus.active,
      );

      expect(
        EsimInstallTracker.completedSinceStart(
          'already-active',
          EsimStatus.active,
        ),
        isFalse,
      );
      await EsimInstallTracker.clear('already-active', reason: 'test');
    },
  );

  test('a new plan moving to installed or active confirms progress', () async {
    await setUpTestDependencies();
    await EsimInstallTracker.start(
      'new-plan',
      method: 'one_tap',
      statusAtStart: EsimStatus.notInstalled,
    );

    expect(
      EsimInstallTracker.completedSinceStart(
        'new-plan',
        EsimStatus.notInstalled,
      ),
      isFalse,
    );
    expect(
      EsimInstallTracker.completedSinceStart('new-plan', EsimStatus.installed),
      isTrue,
    );
    expect(
      EsimInstallTracker.completedSinceStart('new-plan', EsimStatus.active),
      isTrue,
    );
    await EsimInstallTracker.clear('new-plan', reason: 'test');
  });

  test(
    'one-tap flags a stuck install after one minute, QR after three',
    () async {
      await setUpTestDependencies();
      final storage = getIt<LocalStorage>();
      final now = DateTime.now();
      const esim = Esim(
        id: 'pending-plan',
        destinationCode: 'AE',
        destinationNames: {'en': 'United Arab Emirates'},
        kind: PackageKind.limited,
        days: 7,
        status: EsimStatus.notInstalled,
        smdpAddress: 'smdp.test',
        activationCode: 'code',
        iccid: '123',
      );

      await EsimInstallTracker.start(
        esim.id,
        method: 'one_tap',
        statusAtStart: esim.status,
      );
      await storage.setString(
        'esim_install_started_${esim.id}',
        now.subtract(const Duration(seconds: 70)).toIso8601String(),
      );
      expect(EsimInstallTracker.stuckFor(esim, now), isNotNull);
      const cancelled = Esim(
        id: 'pending-plan',
        destinationCode: 'AE',
        destinationNames: {'en': 'United Arab Emirates'},
        kind: PackageKind.limited,
        days: 7,
        status: EsimStatus.cancelled,
        smdpAddress: 'smdp.test',
        activationCode: 'code',
        iccid: '123',
      );
      expect(EsimInstallTracker.stuckFor(cancelled, now), isNotNull);

      await EsimInstallTracker.start(
        esim.id,
        method: 'qr',
        statusAtStart: esim.status,
      );
      await storage.setString(
        'esim_install_started_${esim.id}',
        now.subtract(const Duration(seconds: 70)).toIso8601String(),
      );
      expect(EsimInstallTracker.stuckFor(esim, now), isNull);
      await EsimInstallTracker.clear(esim.id, reason: 'test');
    },
  );
}
