import 'package:equatable/equatable.dart';

class LegalDocument extends Equatable {
  const LegalDocument({
    required this.id,
    required this.title,
    required this.body,
    this.markdown = false,
  });

  final String id;
  final String title;

  final String body;
  final bool markdown;

  @override
  List<Object?> get props => [id, title, body];
}
