import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waysim/core/di/injector.dart';
import 'package:waysim/core/network/network_info.dart';
import 'package:waysim/core/services/analytics_service.dart';
import 'package:waysim/core/services/esim_compatibility.dart';
import 'package:waysim/core/storage/secure_storage.dart';
import 'package:waysim/mock/mock_backend.dart';

class MemoryStorage implements Storage {
  final _data = <String, dynamic>{};

  @override
  dynamic read(String key) => _data[key];

  @override
  Future<void> write(String key, dynamic value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);

  @override
  Future<void> clear() async => _data.clear();

  @override
  Future<void> close() async {}
}

class MemorySecureStorage implements SecureStorage {
  String? deviceToken;
  @override
  Future<String?> readDeviceToken() async => deviceToken;
  @override
  Future<void> saveDeviceToken(String token) async {
    deviceToken = token;
  }

  String? _access;
  String? _refresh;
  String? _device;

  @override
  Future<String?> readAccessToken() async => _access;

  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
  }

  @override
  Future<String?> readDeviceId() async => _device;

  @override
  Future<void> saveDeviceId(String id) async => _device = id;

  @override
  Future<void> clearSession() async {
    _access = null;
    _refresh = null;
  }
}

/// Remembers every event, so a test can say what was reported.
class RecordingAnalytics implements AnalyticsService {
  final events = <(String, Map<String, Object>)>[];
  final screens = <String>[];
  final properties = <String, String?>{};
  String? userId;

  Iterable<Map<String, Object>> named(String name) =>
      events.where((e) => e.$1 == name).map((e) => e.$2);

  @override
  void logEvent(String name, [Map<String, Object> parameters = const {}]) =>
      events.add((name, parameters));

  @override
  void logScreen(String name) => screens.add(name);

  @override
  void setUserId(String? publicId) => userId = publicId;

  @override
  void setUserProperty(String name, String? value) => properties[name] = value;
}

/// Reports whatever it is told; no platform channels.
class FakeCompatibility implements EsimCompatibility {
  FakeCompatibility({this.support = EsimSupport.yes, this.oneTap = false});

  EsimSupport support;
  bool oneTap;

  @override
  Future<EsimSupport> check() async => support;

  @override
  Future<bool> supportsOneTapInstall() async => oneTap;

  @override
  Future<String> deviceName() async => 'Test phone';
}

/// A connection the test controls; online unless told otherwise.
class FakeNetworkInfo implements NetworkInfo {
  FakeNetworkInfo({this.connected = true});

  bool connected;
  final _changes = StreamController<bool>.broadcast();

  void set(bool value) {
    connected = value;
    _changes.add(value);
  }

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onConnectivityChanged => _changes.stream;
}

/// The real dependency graph, on the mock backend with no latency and no
/// platform plugins.
Future<MockBackend> setUpTestDependencies({
  MockBackend? backend,
  FakeCompatibility? compatibility,
  RecordingAnalytics? analytics,
  NetworkInfo? network,
}) async {
  HydratedBloc.storage = MemoryStorage();
  SharedPreferences.setMockInitialValues({});

  await getIt.reset();
  await configureDependencies(useMockApi: true);

  // Registered lazily, so none of these has been resolved yet.
  getIt
    ..unregister<SecureStorage>()
    ..registerSingleton<SecureStorage>(MemorySecureStorage())
    ..unregister<MockBackend>()
    ..unregister<EsimCompatibility>()
    ..unregister<AnalyticsService>()
    ..unregister<NetworkInfo>();

  final mock =
      backend ??
      MockBackend(latency: Duration.zero, purchaseLatency: Duration.zero);
  getIt
    ..registerSingleton<MockBackend>(mock)
    ..registerSingleton<EsimCompatibility>(compatibility ?? FakeCompatibility())
    ..registerSingleton<AnalyticsService>(analytics ?? RecordingAnalytics())
    ..registerSingleton<NetworkInfo>(network ?? FakeNetworkInfo());
  return mock;
}
