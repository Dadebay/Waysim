import 'package:equatable/equatable.dart';

import '../../../../core/utils/formatters/money.dart';

enum OrderType { purchase, topUp }

enum OrderOutcome { completed, failedRefunded }

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
    this.volumeBytes,
    this.days,
    this.unlimited = false,
    this.addOn = false,
    this.method,
  });

  final String number;
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

  String nameFor(String language) =>
      destinationNames[language] ?? destinationNames['en'] ?? '';

  @override
  List<Object?> get props => [
    number,
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
  ];
}

enum TopUpMethod { paypal, crypto }

enum TopUpStatus { waiting, confirming, credited, review, expired }

/// A balance top-up in flight.
class TopUpSession extends Equatable {
  const TopUpSession({
    required this.id,
    required this.method,
    required this.amount,
    this.checkoutUrl,
    this.crypto,
  });

  final String id;
  final TopUpMethod method;
  final Money amount;

  /// PayPal: the page to open in the in-app browser.
  final Uri? checkoutUrl;

  /// Crypto: the invoice to pay.
  final CryptoInvoice? crypto;

  @override
  List<Object?> get props => [id, method, amount, checkoutUrl, crypto];
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
  });

  final String coin;
  final String network;
  final String address;

  /// Exact amount to send, as a string ("20.00") — never a double.
  final String amountText;

  /// "1 USDT = $1.00".
  final String rateText;
  final DateTime expiresAt;
  final int requiredConfirmations;

  @override
  List<Object?> get props => [
    coin,
    network,
    address,
    amountText,
    rateText,
    expiresAt,
    requiredConfirmations,
  ];
}

/// Where a top-up stands.
class TopUpProgress extends Equatable {
  const TopUpProgress(this.status, {this.confirmations = 0});

  final TopUpStatus status;
  final int confirmations;

  @override
  List<Object?> get props => [status, confirmations];
}
