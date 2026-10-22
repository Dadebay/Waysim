import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.publicId,
    required this.email,
    this.name,
    this.notifyEsim,
    this.notifyMarketing,
    this.supportUnread = 0,
  });

  /// `A0123` — shown in the profile and sent to support.
  final String publicId;
  final String email;
  final String? name;
  final bool? notifyEsim;
  final bool? notifyMarketing;
  final int supportUnread;

  User copyWith({String? name, int? supportUnread}) => User(
    publicId: publicId,
    email: email,
    name: name ?? this.name,
    notifyEsim: notifyEsim,
    notifyMarketing: notifyMarketing,
    supportUnread: supportUnread ?? this.supportUnread,
  );

  @override
  List<Object?> get props => [
    publicId,
    email,
    name,
    notifyEsim,
    notifyMarketing,
    supportUnread,
  ];
}

class SignInResult extends Equatable {
  const SignInResult({required this.user, required this.isNewUser});

  final User user;

  /// Drives the optional "What should we call you?" step.
  final bool isNewUser;

  @override
  List<Object?> get props => [user, isNewUser];
}

class DeviceInfo extends Equatable {
  const DeviceInfo({
    required this.id,
    required this.model,
    required this.os,
    required this.isCurrent,
    this.lastSeen,
  });

  final String id;
  final String model;
  final String os;
  final bool isCurrent;
  final DateTime? lastSeen;

  @override
  List<Object?> get props => [id, model, os, isCurrent, lastSeen];
}
