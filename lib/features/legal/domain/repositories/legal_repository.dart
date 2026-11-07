import '../../../../core/utils/result.dart';
import '../entities/legal_document.dart';

abstract interface class LegalRepository {
  Future<Result<List<LegalDocument>>> documents(String language);
}
