import 'package:equatable/equatable.dart';

class LegalDocument extends Equatable {
  const LegalDocument({
    required this.id,
    required this.title,
    required this.body,
  });

  /// `terms`, `privacy`, `refund`, `acceptable-use`, `cookies`, `general`.
  final String id;
  final String title;

  /// Plain text with blank lines between paragraphs.
  final String body;

  @override
  List<Object?> get props => [id, title, body];
}
