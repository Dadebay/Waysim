import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/utils/result.dart';
import '../../../../app/router/app_routes.dart';
import '../../domain/repositories/catalog_repository.dart';

class PackageLinkPage extends StatefulWidget {
  const PackageLinkPage({super.key, required this.id});
  final String id;
  @override
  State<PackageLinkPage> createState() => _PackageLinkPageState();
}

class _PackageLinkPageState extends State<PackageLinkPage> {
  Failure? _failure;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failure = null);
    final result = await getIt<CatalogRepository>().package(widget.id);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        context.replace(
          '${AppRoute.destination.withParams({'code': data.destinationCode})}?packageId=${Uri.encodeComponent(data.id)}',
        );
      case Error(:final failure):
        setState(() => _failure = failure);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: _failure == null
        ? const Center(child: CircularProgressIndicator())
        : ErrorView(failure: _failure!, onRetry: _load),
  );
}
