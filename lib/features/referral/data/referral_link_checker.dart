import 'package:dio/dio.dart';

/// Check the public landing page before including its URL in a shared invite.
Future<bool> referralLinkReturnsOk(Uri link, {Dio? client}) async {
  if (link.scheme != 'https' || link.host.isEmpty) return false;

  final dio =
      client ??
      Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (_) => true,
        ),
      );

  try {
    final response = await dio.getUri<ResponseBody>(
      link,
      options: Options(
        responseType: ResponseType.stream,
        validateStatus: (_) => true,
      ),
    );
    // The status is enough; the page body is not needed for sharing.
    await response.data?.stream.listen((_) {}).cancel();
    return response.statusCode == 200;
  } on DioException {
    return false;
  } finally {
    if (client == null) dio.close();
  }
}
