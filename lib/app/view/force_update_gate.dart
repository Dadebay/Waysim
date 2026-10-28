import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/app_version.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../core/utils/safe_url.dart';
import '../../core/widgets/app_button.dart';
import '../../features/config/domain/entities/app_config.dart';
import '../../features/config/presentation/cubit/config_cubit.dart';

class ForceUpdateGate extends StatefulWidget {
  const ForceUpdateGate({super.key, required this.child, this.currentVersion});

  final Widget child;

  final String? currentVersion;

  @override
  State<ForceUpdateGate> createState() => _ForceUpdateGateState();
}

class _ForceUpdateGateState extends State<ForceUpdateGate> {
  late final Future<String> _version = widget.currentVersion != null
      ? Future.value(widget.currentVersion)
      : PackageInfo.fromPlatform().then((i) => i.version);

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigCubit>().state;
    final minimum = config.minSupportedVersion;
    if (minimum == null) return widget.child;

    return FutureBuilder<String>(
      future: _version,
      builder: (context, snapshot) {
        final current = snapshot.data;
        if (current != null && AppVersion.isOlder(current, minimum)) {
          return _UpdateScreen(config: config);
        }
        return widget.child;
      },
    );
  }
}

class _UpdateScreen extends StatelessWidget {
  const _UpdateScreen({required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: c.primarySubtle,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: HugeIcon(
                    icon: AppIcons.sparkles,
                    size: 44,
                    color: c.link,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.updateRequiredTitle,
                style: context.text.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.updateRequiredBody,
                style: context.text.body.copyWith(color: c.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppButton(
                label: l10n.updateRequiredAction,
                onPressed: () => launchUrl(
                  safeHttpsUri(config.storeUrl) ??
                      Uri.https(AppConstants.webHost, '/app'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
