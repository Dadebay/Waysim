import 'package:equatable/equatable.dart';

import '../../../../core/utils/formatters/money.dart';

enum InviteStatus { credited, pending, rejected }

class Invite extends Equatable {
  const Invite({
    required this.maskedEmail,
    required this.registeredAt,
    required this.status,
    this.reward,
  });

  /// `a***@gmail.com` — the server masks it.
  final String maskedEmail;
  final DateTime registeredAt;
  final InviteStatus status;
  final Money? reward;

  @override
  List<Object?> get props => [maskedEmail, registeredAt, status, reward];
}

class ReferralInfo extends Equatable {
  const ReferralInfo({
    required this.code,
    required this.link,
    required this.reward,
    required this.invited,
    required this.credited,
    required this.pending,
    required this.rejected,
    required this.invites,
    this.enabled = true,
    this.rulesText,
  });

  final bool enabled;
  final String? rulesText;
  final String code;
  final Uri link;

  /// What a friend is worth to the customer, fixed server-side.
  final Money reward;
  final int invited;
  final Money credited;
  final int pending;
  final int rejected;
  final List<Invite> invites;

  @override
  List<Object?> get props => [
    code,
    link,
    reward,
    invited,
    credited,
    pending,
    rejected,
    invites,
  ];
}
