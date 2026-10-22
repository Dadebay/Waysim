import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waysim/features/referral/data/referral_link_checker.dart';

class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.statuses);

  final List<int> statuses;
  final methods = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    methods.add(options.method);
    return ResponseBody.fromString('', statuses.removeAt(0));
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  final link = Uri.parse('https://waysim.co/r/A000000');

  test('accepts only a 200 response from the landing page', () async {
    final ok = _StatusAdapter([200]);
    final missing = _StatusAdapter([404]);

    expect(
      await referralLinkReturnsOk(link, client: Dio()..httpClientAdapter = ok),
      isTrue,
    );
    expect(ok.methods, ['GET']);
    expect(
      await referralLinkReturnsOk(
        link,
        client: Dio()..httpClientAdapter = missing,
      ),
      isFalse,
    );
    expect(missing.methods, ['GET']);
  });

  test('rejects links without HTTPS without contacting the server', () async {
    final adapter = _StatusAdapter([200]);
    expect(
      await referralLinkReturnsOk(
        Uri.parse('http://waysim.co/r/A000000'),
        client: Dio()..httpClientAdapter = adapter,
      ),
      isFalse,
    );
    expect(adapter.methods, isEmpty);
  });
}
