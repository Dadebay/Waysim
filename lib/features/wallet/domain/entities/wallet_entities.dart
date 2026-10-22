import 'package:equatable/equatable.dart';

import '../../../../core/utils/formatters/money.dart';

enum OrderType { purchase, topUp }

enum OrderOutcome { completed, failedRefunded, pending, review, failed }

/// One line of order history: a package purchase, a package top-up or a
/// balance top-up.
class WalletOrder extends Equatable {
  const WalletOrder({
    required this.number,
    required this.type,
    required this.outcome,
    required this.amount,
    required this.createdAt,
    required this.destinationNames,
    this.id,
    this.slug,
    this.esimId,
    this.failedReason,
    this.doneAt,
    this.volumeBytes,
    this.days,
    this.unlimited = false,
    this.addOn = false,
    this.method,
    this.serverTitle,
  });

  final String number;
  final String? id;
  final String? slug;
  final String? esimId;
  final String? failedReason;
  final DateTime? doneAt;
  final OrderType type;
  final OrderOutcome outcome;

  /// Always positive; the sign is drawn from [type].
  final Money amount;
  final DateTime createdAt;
  final Map<String, String> destinationNames;
  final int? volumeBytes;
  final int? days;
  final bool unlimited;

  /// A package added to an existing eSIM rather than a new one.
  final bool addOn;

  /// Balance top-ups: how it was paid.
  final TopUpMethod? method;
  final String? serverTitle;

  String nameFor(String language) =>
      destinationNames[language] ?? destinationNames['en'] ?? '';

  @override
  List<Object?> get props => [
    number,
    id,
    slug,
    esimId,
    failedReason,
    doneAt,
    type,
    outcome,
    amount,
    createdAt,
    destinationNames,
    volumeBytes,
    days,
    unlimited,
    addOn,
    method,
    serverTitle,
  ];
}

enum TopUpMethod { paypal, crypto }

enum TopUpStatus { waiting, confirming, credited, review, expired, failed }

/// A balance top-up in flight.
class TopUpSession extends Equatable {
  const TopUpSession({
    required this.id,
    required this.method,
    required this.amount,
    this.publicNo,
    this.rawStatus,
    this.createdAt,
    this.creditedAt,
    this.checkoutUrl,
    this.crypto,
    this.status = TopUpStatus.waiting,
    this.creditedAmount,
  });

  final String id;
  final int? publicNo;
  final TopUpMethod method;
  final Money amount;
  final String? rawStatus;
  final DateTime? createdAt;
  final DateTime? creditedAt;

  /// PayPal: the page to open in the in-app browser.
  final Uri? checkoutUrl;

  /// Crypto: the invoice to pay.
  final CryptoInvoice? crypto;
  final TopUpStatus status;
  final Money? creditedAmount;

  @override
  List<Object?> get props => [
    id,
    publicNo,
    method,
    amount,
    rawStatus,
    createdAt,
    creditedAt,
    checkoutUrl,
    crypto,
    status,
    creditedAmount,
  ];

  @override
  String toString() =>
      'TopUpSession(id: $id, publicNo: $publicNo, status: ${status.name}, amount: $amount)';
}

class CryptoInvoice extends Equatable {
  const CryptoInvoice({
    required this.coin,
    required this.network,
    required this.address,
    required this.amountText,
    required this.rateText,
    required this.expiresAt,
    required this.requiredConfirmations,
    this.paidAmountText,
    this.providerStatus,
    this.feeCents,
    this.totalCents,
    this.txid,
    this.memo,
    this.qrValue,
  });

  final String coin;
  final String network;
  final String address;

  /// Exact amount to send, as a string ("20.00") — never a double.
  final String amountText;
  final String? paidAmountText;
  final String? providerStatus;
  final int? feeCents;
  final int? totalCents;
  final String? txid;

  /// "1 USDT = $1.00".
  final String rateText;
  final DateTime expiresAt;
  final int requiredConfirmations;
  final String? memo;
  final String? qrValue;

  @override
  List<Object?> get props => [
    coin,
    network,
    address,
    amountText,
    paidAmountText,
    providerStatus,
    feeCents,
    totalCents,
    txid,
    rateText,
    expiresAt,
    requiredConfirmations,
    memo,
    qrValue,
  ];

  @override
  String toString() =>
      'CryptoInvoice(coin: $coin, network: $network, amount: $amountText, paid: $paidAmountText)';
}

/// Where a top-up stands.
class TopUpProgress extends Equatable {
  const TopUpProgress(
    this.status, {
    this.confirmations = 0,
    this.creditedAmount,
  });

  final TopUpStatus status;
  final Money? creditedAmount;
  final int confirmations;

  @override
  List<Object?> get props => [status, confirmations, creditedAmount];
}

/// A coin + network the customer can pay in.
class CryptoOption extends Equatable {
  const CryptoOption(
    this.coin,
    this.network, {
    this.code,
    this.minCents,
    this.logoUrl,
  });

  final String coin;
  final String network;
  final String? code;
  final int? minCents;
  final String? logoUrl;

  static const usdtTrc20 = CryptoOption('USDT', 'TRC-20');
  static const usdtBep20 = CryptoOption('USDT', 'BEP-20');

  String get label => '$coin · $network';

  @override
  List<Object?> get props => [coin, network, code, minCents, logoUrl];
}

class WalletOptions {
  const WalletOptions({
    this.minCents = 500,
    this.maxCents = 50000,
    this.methods = const [TopUpMethod.paypal, TopUpMethod.crypto],
    this.currencies = const [
      CryptoOption.usdtTrc20,
      CryptoOption('USDT', 'ERC-20'),
      CryptoOption('USDC', 'ERC-20'),
    ],
    this.pending,
  });
  final int minCents;
  final int maxCents;
  final List<TopUpMethod> methods;
  final List<CryptoOption> currencies;
  final TopUpSession? pending;
}
