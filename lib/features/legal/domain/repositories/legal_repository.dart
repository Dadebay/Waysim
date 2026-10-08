import '../../../../core/utils/result.dart';
import '../entities/legal_document.dart';

abstract interface class LegalRepository {
  /// The six documents, titled in [language].
  Future<Result<List<LegalDocument>>> documents(String language);
}
