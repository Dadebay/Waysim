import '../../../core/utils/result.dart';
import '../domain/entities/legal_document.dart';
import '../domain/repositories/legal_repository.dart';

/// Six documents with placeholder text. The real ones are authored by the
/// customer and served from waysim.co (docs/07-open-questions.md).
class MockLegalRepository implements LegalRepository {
  const MockLegalRepository();

  static const _titles = <String, Map<String, String>>{
    'general': {
      'en': 'General provisions',
      'ru': 'Общие положения',
      'es': 'Disposiciones generales',
      'fr': 'Dispositions générales',
      'zh': '一般条款',
    },
    'terms': {
      'en': 'Terms of use',
      'ru': 'Условия использования',
      'es': 'Términos de uso',
      'fr': 'Conditions d’utilisation',
      'zh': '使用条款',
    },
    'refund': {
      'en': 'Refund policy',
      'ru': 'Политика возврата средств',
      'es': 'Política de reembolsos',
      'fr': 'Politique de remboursement',
      'zh': '退款政策',
    },
    'acceptable-use': {
      'en': 'Acceptable use policy',
      'ru': 'Политика допустимого использования',
      'es': 'Política de uso aceptable',
      'fr': 'Politique d’utilisation acceptable',
      'zh': '合理使用政策',
    },
    'privacy': {
      'en': 'Privacy policy',
      'ru': 'Политика конфиденциальности',
      'es': 'Política de privacidad',
      'fr': 'Politique de confidentialité',
      'zh': '隐私政策',
    },
    'cookies': {
      'en': 'Cookie policy',
      'ru': 'Политика cookie',
      'es': 'Política de cookies',
      'fr': 'Politique relative aux cookies',
      'zh': 'Cookie 政策',
    },
  };

  static const _body =
      'This is sample text. The final document is provided by Waysim and '
      'shown here as published on waysim.co.\n\n'
      'eSIM plans are for tourist use on a smartphone. Routers, IoT devices '
      'and long-term use in one country are not allowed.\n\n'
      'Your balance is spent only on eSIM plans and cannot be withdrawn.';

  @override
  Future<Result<List<LegalDocument>>> documents(String language) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return Success([
      for (final entry in _titles.entries)
        LegalDocument(
          id: entry.key,
          title: entry.value[language] ?? entry.value['en']!,
          body: _body,
        ),
    ]);
  }
}
