import '../../../core/network/api_client.dart';
import '../../../core/network/api_helpers.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/legal_document.dart';
import '../domain/repositories/legal_repository.dart';

class ApiLegalRepository implements LegalRepository {
  ApiLegalRepository(this.api);
  final ApiClient api;
  @override
  Future<Result<List<LegalDocument>>> documents(String language) =>
      apiResult(() async {
        final index = asMap(
          await api.get('/v1/legal', queryParameters: {'locale': language}),
        );
        return Future.wait(
          index.listOf('documents').map((entry) async {
            final j = asMap(
              await api.get(
                '/v1/legal/${Uri.encodeComponent(entry.str('key'))}',
                queryParameters: {'locale': language},
              ),
            );
            return LegalDocument(
              id: j.str('key').replaceAll('_', '-'),
              title: j.str('title'),
              body: j.str('body'),
              markdown: true,
            );
          }),
        );
      });
}
