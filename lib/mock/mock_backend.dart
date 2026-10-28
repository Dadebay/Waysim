import '../core/error/failure.dart';
import '../core/utils/formatters/money.dart';
import '../core/utils/result.dart';
import '../features/auth/domain/entities/user.dart';
import '../features/catalog/data/mock/catalog_fixtures.dart';
import '../features/catalog/domain/entities/destination.dart';
import '../features/catalog/domain/entities/esim_package.dart';
import '../features/config/domain/entities/app_config.dart';
import '../features/esim/domain/entities/esim.dart';
import '../features/purchase/domain/repositories/purchase_repository.dart';
import '../features/referral/domain/entities/referral.dart';
import '../features/wallet/domain/entities/wallet_entities.dart';
import 'demo_credentials.dart';

class MockBackend {
  MockBackend({
    DateTime Function()? now,
    this.latency = const Duration(milliseconds: 400),
    this.purchaseLatency = const Duration(milliseconds: 1600),
  }) : _now = now ?? DateTime.now {
    config = const AppConfig(
      contacts: AppContacts(
        website: ContactLink(label: 'waysim.co', url: 'https://waysim.co'),
        email: ContactLink(
          label: 'support@waysim.co',
          url: 'mailto:support@waysim.co',
        ),
        telegram: ContactLink(
          label: '@waysim_support',
          url: 'https://t.me/waysim_support',
        ),
      ),
    );
  }

  final DateTime Function() _now;
  final Duration latency;
  final Duration purchaseLatency;

  late AppConfig config;

  static const guestPublicId = 'A0000';

  User? _user;
  Money _balance = const Money(2450);
  final _esims = <Esim>[];
  final _orders = <WalletOrder>[];
  final _receipts = <String, PurchaseReceipt>{};
  final _topUps = <String, _TopUp>{};
  var _orderSeq = 10240;
  var _esimSeq = 0;
  var _topUpSeq = 0;

  User? get user => _user;
  bool get signedIn => _user != null;

  Future<void> _wait([Duration? d]) => latency == Duration.zero
      ? Future<void>.value()
      : Future<void>.delayed(d ?? latency);

  Failure get _unauthorized => const UnauthorizedFailure();

  Future<Result<void>> requestCode(String email) async {
    await _wait();
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
    if (!ok) {
      return const Error(ApiFailure(code: 'validation_error', statusCode: 400));
    }
    return const Success(null);
  }

  Future<Result<SignInResult>> verifyCode(String email, String code) async {
    await _wait();
    if (code == '000000') {
      return const Error(
        ApiFailure(code: ApiCodes.otpInvalid, statusCode: 400),
      );
    }
    final isNew = email.trim().toLowerCase() != DemoCredentials.existingEmail;
    _user = User(
      publicId: 'A0123',
      email: email.trim().toLowerCase(),
      name: isNew ? null : 'Anna',
    );
    _balance = const Money(2450);
    _esims.clear();
    _orders.clear();
    if (!isNew) _seedHistory();
    return Success(SignInResult(user: _user!, isNewUser: isNew));
  }

  Future<Result<User>> updateName(String name) async {
    await _wait();
    final u = _user;
    if (u == null) return Error(_unauthorized);
    return Success(_user = u.copyWith(name: name.trim()));
  }

  void signOut() {
    _user = null;
    _esims.clear();
    _orders.clear();
  }

  Future<Result<void>> deleteAccount(String code) async {
    await _wait();
    if (code == '000000') {
      return const Error(
        ApiFailure(code: ApiCodes.otpInvalid, statusCode: 400),
      );
    }
    signOut();
    return const Success(null);
  }

  Future<Result<Money>> balance() async {
    await _wait(const Duration(milliseconds: 150));
    return signedIn ? Success(_balance) : Error(_unauthorized);
  }

  Future<Result<TopUpSession>> createTopUp({
    required Money amount,
    required TopUpMethod method,
    required String key,
    String? coin,
    String? network,
  }) async {
    await _wait();
    if (!signedIn) return Error(_unauthorized);
    if (config.maintenance) {
      return const Error(
        ApiFailure(code: ApiCodes.maintenance, statusCode: 503),
      );
    }
    if (amount.cents < config.minTopUpCents ||
        amount.cents > config.maxTopUpCents) {
      return const Error(ApiFailure(code: 'validation_error', statusCode: 400));
    }
    final existing = _topUps[key];
    if (existing != null) return Success(existing.session);

    final id = 'tu_${++_topUpSeq}';
    final invoice = method == TopUpMethod.crypto
        ? CryptoInvoice(
            coin: coin ?? 'USDT',
            network: network ?? 'TRC-20',
            address: 'TQ4h9Lm2xV7eRk3pW8nA5sYc1bZ6dFgHq',
            amountText:
                '${amount.cents ~/ 100}.${(amount.cents % 100).toString().padLeft(2, '0')}',
            rateText: '1 ${coin ?? 'USDT'} = \$1.00',
            expiresAt: _now().add(const Duration(minutes: 15)),
            requiredConfirmations: 20,
          )
        : null;
    final session = TopUpSession(
      id: id,
      method: method,
      amount: amount,
      crypto: invoice,
    );
    _topUps[key] = _TopUp(session, _now());
    _topUps[id] = _topUps[key]!;
    return Success(session);
  }

  Future<Result<TopUpProgress>> topUpProgress(String id) async {
    await _wait(const Duration(milliseconds: 150));
    final t = _topUps[id];
    if (t == null) return const Error(NotFoundFailure());
    final elapsed = _now().difference(t.createdAt);
    final progress = switch (t.session.method) {
      TopUpMethod.paypal =>
        elapsed < const Duration(seconds: 3)
            ? const TopUpProgress(TopUpStatus.waiting)
            : const TopUpProgress(TopUpStatus.credited),
      TopUpMethod.crypto => () {
        final need = t.session.crypto!.requiredConfirmations;
        if (elapsed < const Duration(seconds: 4)) {
          return const TopUpProgress(TopUpStatus.waiting);
        }
        final confirmations = ((elapsed.inMilliseconds - 4000) / 400)
            .floor()
            .clamp(0, need);
        return confirmations >= need
            ? TopUpProgress(TopUpStatus.credited, confirmations: need)
            : TopUpProgress(
                TopUpStatus.confirming,
                confirmations: confirmations,
              );
      }(),
    };
    if (progress.status == TopUpStatus.credited && !t.credited) {
      t.credited = true;
      _balance += t.session.amount;
      _orders.insert(
        0,
        WalletOrder(
          number: '${++_orderSeq}',
          type: OrderType.topUp,
          outcome: OrderOutcome.completed,
          amount: t.session.amount,
          createdAt: _now(),
          destinationNames: const {},
          method: t.session.method,
        ),
      );
    }
    return Success(progress);
  }

  Future<Result<TopUpSession>> payment(String id) async {
    await _wait();
    if (!signedIn) return Error(_unauthorized);
    final active = _topUps[id];
    if (active != null) {
      final progress = (await topUpProgress(id)).dataOrNull!;
      return Success(
        TopUpSession(
          id: id,
          method: active.session.method,
          amount: active.session.amount,
          crypto: active.session.crypto,
          status: progress.status,
          creditedAmount: progress.creditedAmount,
          createdAt: active.createdAt,
        ),
      );
    }
    final order = _orders
        .where(
          (item) =>
              item.type == OrderType.topUp &&
              item.method != null &&
              item.number == id,
        )
        .firstOrNull;
    if (order == null) return const Error(NotFoundFailure());
    final status = switch (order.outcome) {
      OrderOutcome.completed => TopUpStatus.credited,
      OrderOutcome.pending => TopUpStatus.waiting,
      OrderOutcome.review => TopUpStatus.review,
      OrderOutcome.failed || OrderOutcome.failedRefunded => TopUpStatus.failed,
    };
    return Success(
      TopUpSession(
        id: id,
        publicNo: int.tryParse(id),
        method: order.method ?? TopUpMethod.crypto,
        amount: order.amount,
        status: status,
        creditedAmount: status == TopUpStatus.credited ? order.amount : null,
        createdAt: order.createdAt,
        creditedAt: status == TopUpStatus.credited ? order.createdAt : null,
      ),
    );
  }

  Future<Result<WalletOrder>> order(String id) async {
    await _wait();
    if (!signedIn) return Error(_unauthorized);
    final found = _orders
        .where(
          (item) => item.method == null && (item.id == id || item.number == id),
        )
        .firstOrNull;
    return found == null ? const Error(NotFoundFailure()) : Success(found);
  }

  Future<Result<List<WalletOrder>>> orders(OrderType type) async {
    await _wait();
    if (!signedIn) return Error(_unauthorized);
    return Success([
      for (final o in _orders)
        if ((type == OrderType.topUp) == (o.type == OrderType.topUp)) o,
    ]);
  }

  Future<Result<List<Esim>>> esims() async {
    await _wait();
    if (!signedIn) return Error(_unauthorized);
    return Success(List.unmodifiable(_esims));
  }

  Future<Result<Esim>> esim(String id) async {
    await _wait(const Duration(milliseconds: 150));
    final found = _esims.where((e) => e.id == id);
    return found.isEmpty
        ? const Error(NotFoundFailure())
        : Success(found.first);
  }

  Future<Result<Esim>> bindToDevice(String id, String deviceName) async {
    await _wait();
    final i = _esims.indexWhere((e) => e.id == id);
    if (i < 0) return const Error(NotFoundFailure());
    final current = _esims[i];
    if (current.deviceName != null && current.deviceName != deviceName) {
      return const Error(
        ApiFailure(code: 'esim-bound-to-another-device', statusCode: 409),
      );
    }
    return Success(
      _esims[i] = current.copyWith(deviceName: deviceName, updatedAt: _now()),
    );
  }

  String? destinationOfEsim(String id) {
    for (final e in _esims) {
      if (e.id == id) return e.destinationCode;
    }
    return null;
  }

  Future<Result<PurchaseReceipt>> buy(
    String packageId,
    String key,
    Money expected,
  ) async {
    await _wait(purchaseLatency);
    final cached = _receipts[key];
    if (cached != null) return Success(cached);
    if (!signedIn) return Error(_unauthorized);
    if (config.maintenance) {
      return const Error(
        ApiFailure(code: ApiCodes.maintenance, statusCode: 503),
      );
    }

    final package = _findPackage(packageId);
    if (package == null) {
      return const Error(
        ApiFailure(code: ApiCodes.packageUnavailable, statusCode: 409),
      );
    }
    final priceFailure = _checkPrice(package, expected);
    if (priceFailure != null) return Error(priceFailure);

    final destination = _destination(package.destinationCode);

    if (packageId == 'TH_3_30') {
      _orders.insert(
        0,
        _order(package, destination, OrderOutcome.failedRefunded),
      );
      return const Error(ApiFailure(code: 'order-failed', statusCode: 502));
    }

    _balance -= package.price;
    final esim = _newEsim(package, destination);
    _esims.insert(0, esim);
    final order = _order(package, destination, OrderOutcome.completed);
    _orders.insert(0, order);
    return Success(
      _receipts[key] = PurchaseReceipt(
        orderId: order.id!,
        charged: order.amount,
        esim: esim,
        balanceAfter: _balance,
      ),
    );
  }

  Future<Result<PurchaseReceipt>> topUp(
    String esimId,
    String packageId,
    String key,
    Money expected,
  ) async {
    await _wait(purchaseLatency);
    final cached = _receipts[key];
    if (cached != null) return Success(cached);
    if (!signedIn) return Error(_unauthorized);
    final i = _esims.indexWhere((e) => e.id == esimId);
    if (i < 0) return const Error(NotFoundFailure());
    final current = _esims[i];
    if (current.status == EsimStatus.expired) {
      return const Error(
        ApiFailure(code: ApiCodes.packageUnavailable, statusCode: 409),
      );
    }
    final package = CatalogFixtures.topUps(
      current.destinationCode,
    ).where((p) => p.id == packageId).firstOrNull;
    if (package == null) {
      return const Error(
        ApiFailure(code: ApiCodes.packageUnavailable, statusCode: 409),
      );
    }
    final priceFailure = _checkPrice(package, expected);
    if (priceFailure != null) return Error(priceFailure);

    _balance -= package.price;
    final base = current.expiresAt ?? _now();
    final updated = current.copyWith(
      volumeBytes: (current.volumeBytes ?? 0) + (package.volumeBytes ?? 0),
      days: current.days + package.days,
      expiresAt: current.expiresAt == null
          ? null
          : base.add(Duration(days: package.days)),
      status: current.status == EsimStatus.usedUp
          ? EsimStatus.active
          : current.status,
      updatedAt: _now(),
    );
    _esims[i] = updated;
    final order = _order(
      package,
      _destination(package.destinationCode),
      OrderOutcome.completed,
      addOn: true,
    );
    _orders.insert(0, order);
    return Success(
      _receipts[key] = PurchaseReceipt(
        orderId: order.id!,
        charged: order.amount,
        esim: updated,
        balanceAfter: _balance,
      ),
    );
  }

  Failure? _checkPrice(EsimPackage package, Money expected) {
    if (package.price != expected) {
      return ApiFailure(
        code: ApiCodes.priceChanged,
        statusCode: 409,
        details: {'newPriceCents': package.price.cents},
      );
    }
    if (_balance < package.price) {
      return ApiFailure(
        code: ApiCodes.insufficientBalance,
        statusCode: 402,
        details: {'missingCents': package.price.cents - _balance.cents},
      );
    }
    return null;
  }

  EsimPackage? _findPackage(String id) {
    final code = id.split('_').first;
    return CatalogFixtures.packages(code).where((p) => p.id == id).firstOrNull;
  }

  Destination _destination(String code) =>
      CatalogFixtures.destinations().firstWhere((d) => d.code == code);

  WalletOrder _order(
    EsimPackage p,
    Destination d,
    OrderOutcome outcome, {
    bool addOn = false,
  }) => WalletOrder(
    number: '${++_orderSeq}',
    id: 'mock-order-$_orderSeq',
    type: addOn ? OrderType.topUp : OrderType.purchase,
    outcome: outcome,
    amount: p.price,
    createdAt: _now(),
    destinationNames: d.names,
    volumeBytes: p.volumeBytes,
    days: p.days,
    unlimited: p.isUnlimited,
    addOn: addOn,
  );

  Esim _newEsim(EsimPackage p, Destination d) {
    final n = ++_esimSeq;
    return Esim(
      id: 'esim_$n',
      destinationCode: d.code,
      destinationNames: d.names,
      countryCount: d.countryCount,
      kind: p.kind,
      days: p.days,
      volumeBytes: p.volumeBytes,
      dailyBytes: p.dailyBytes,
      status: EsimStatus.notInstalled,
      smdpAddress: 'smdp.example.com',
      activationCode: _activationCode(n),
      iccid: '8999000000001234${(567 + n).toString().padLeft(3, '0')}',
      installBy: _now().add(Duration(days: p.installWithinDays)),
      updatedAt: _now(),
      topUpSupported: p.topUp,
    );
  }

  String _activationCode(int n) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    String block(int seed) => String.fromCharCodes([
      for (var i = 0; i < 4; i++)
        chars.codeUnitAt((seed * 7 + i * 11 + n * 5) % chars.length),
    ]);
    return 'K$n-${block(3)}-${block(5)}-${block(9)}';
  }

  Future<Result<ReferralInfo>> referral() async {
    await _wait();
    if (!signedIn) return Error(_unauthorized);
    final reward = Money(config.referralRewardCents);
    final now = _now();
    return Success(
      ReferralInfo(
        code: 'WAY7K2Q',
        link: Uri.parse('https://waysim.co/r/WAY7K2Q'),
        reward: reward,
        invited: 5,
        credited: const Money(900),
        pending: 1,
        rejected: 1,
        invites: [
          Invite(
            maskedEmail: 'a***@gmail.com',
            registeredAt: DateTime(now.year, 10, 2),
            status: InviteStatus.credited,
            reward: reward,
          ),
          Invite(
            maskedEmail: 'm***@mail.ru',
            registeredAt: DateTime(now.year, 9, 30),
            status: InviteStatus.pending,
          ),
          Invite(
            maskedEmail: 'd***@icloud.com',
            registeredAt: DateTime(now.year, 9, 26),
            status: InviteStatus.credited,
            reward: reward,
          ),
          Invite(
            maskedEmail: 'k***@yandex.ru',
            registeredAt: DateTime(now.year, 9, 21),
            status: InviteStatus.rejected,
          ),
        ],
      ),
    );
  }

  void _seedHistory() {
    final now = _now();
    final names = {for (final d in CatalogFixtures.destinations()) d.code: d};
    const gb = 1024 * 1024 * 1024;

    Esim seed(
      String id,
      String code,
      PackageKind kind,
      int days,
      EsimStatus status, {
      int? volume,
      int? daily,
      int used = 0,
      DateTime? expires,
      DateTime? installBy,
      String? device,
      Duration? updated,
    }) {
      final d = names[code]!;
      return Esim(
        id: id,
        destinationCode: code,
        destinationNames: d.names,
        countryCount: d.countryCount,
        kind: kind,
        days: days,
        volumeBytes: volume,
        dailyBytes: daily,
        usedBytes: used,
        status: status,
        expiresAt: expires,
        installBy: installBy,
        deviceName: device,
        updatedAt: updated == null ? null : now.subtract(updated),
        smdpAddress: 'smdp.example.com',
        activationCode: _activationCode(_esimSeq++ + 40),
        iccid: '8999000000001234${(500 + _esimSeq).toString().padLeft(3, '0')}',
      );
    }

    _esims.addAll([
      seed(
        'esim_seed_tr',
        'TR',
        PackageKind.limited,
        30,
        EsimStatus.active,
        volume: 5 * gb,
        used: (1.8 * gb).round(),
        expires: now.add(const Duration(days: 18, hours: 3)),
        device: 'iPhone 15',
        updated: const Duration(minutes: 12),
      ),
      seed(
        'esim_seed_ge',
        'GE',
        PackageKind.unlimited,
        7,
        EsimStatus.notInstalled,
        daily: gb,
        installBy: DateTime(now.year + 1, 4, 1),
      ),
      seed(
        'esim_seed_eu',
        'EU',
        PackageKind.limited,
        30,
        EsimStatus.installed,
        volume: 10 * gb,
        installBy: DateTime(now.year + 1, 3, 20),
        device: 'iPhone 15',
        updated: const Duration(hours: 5),
      ),
      seed(
        'esim_seed_th',
        'TH',
        PackageKind.limited,
        30,
        EsimStatus.expired,
        volume: 3 * gb,
        used: (2.4 * gb).round(),
        expires: now.subtract(const Duration(days: 40)),
        device: 'iPhone 15',
      ),
      seed(
        'esim_seed_jp',
        'JP',
        PackageKind.limited,
        7,
        EsimStatus.usedUp,
        volume: 1 * gb,
        used: 1 * gb,
        expires: now.add(const Duration(days: 2)),
        device: 'iPhone 15',
      ),
    ]);

    WalletOrder order(
      String n,
      OrderType type,
      OrderOutcome outcome,
      int cents,
      DateTime at, {
      String? code,
      int? gbs,
      int? days,
      bool unlimited = false,
      bool addOn = false,
      TopUpMethod? method,
    }) => WalletOrder(
      number: n,
      type: type,
      outcome: outcome,
      amount: Money(cents),
      createdAt: at,
      destinationNames: code == null ? const {} : names[code]!.names,
      volumeBytes: gbs == null ? null : gbs * gb,
      days: days,
      unlimited: unlimited,
      addOn: addOn,
      method: method,
    );

    final y = now.year;
    _orders.addAll([
      order(
        '10234',
        OrderType.purchase,
        OrderOutcome.completed,
        599,
        DateTime(y, 10, 3, 14, 20),
        code: 'TR',
        gbs: 5,
        days: 30,
      ),
      order(
        '10229',
        OrderType.topUp,
        OrderOutcome.completed,
        399,
        DateTime(y, 10, 1, 9, 5),
        code: 'TR',
        gbs: 3,
        days: 30,
        addOn: true,
      ),
      order(
        '10211',
        OrderType.purchase,
        OrderOutcome.completed,
        1699,
        DateTime(y, 9, 28, 19, 42),
        code: 'GE',
        days: 7,
        unlimited: true,
      ),
      order(
        '10198',
        OrderType.purchase,
        OrderOutcome.failedRefunded,
        499,
        DateTime(y, 9, 21, 11, 15),
        code: 'TH',
        gbs: 3,
        days: 30,
      ),
      order(
        '10187',
        OrderType.purchase,
        OrderOutcome.completed,
        1499,
        DateTime(y, 9, 15, 8, 30),
        code: 'EU',
        gbs: 10,
        days: 30,
      ),
      order(
        '10176',
        OrderType.topUp,
        OrderOutcome.completed,
        2000,
        DateTime(y, 10, 2, 10, 12),
        method: TopUpMethod.paypal,
      ),
      order(
        '10150',
        OrderType.topUp,
        OrderOutcome.completed,
        1000,
        DateTime(y, 9, 12, 16, 40),
        method: TopUpMethod.crypto,
      ),
    ]);
  }
}

class _TopUp {
  _TopUp(this.session, this.createdAt);

  final TopUpSession session;
  final DateTime createdAt;
  bool credited = false;
}
