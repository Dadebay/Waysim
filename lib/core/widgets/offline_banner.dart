import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../di/injector.dart';
import '../network/network_info.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

/// "No connection" strip that slides in when the device goes offline.
/// Catalog and eSIM lists keep showing cached data underneath.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this._networkInfo});

  final NetworkInfo? _networkInfo;

  @override
  Widget build(BuildContext context) {
    final info = _networkInfo ?? getIt<NetworkInfo>();
    return StreamBuilder<bool>(
      stream: info.onConnectivityChanged,
      builder: (context, snapshot) {
        final offline = snapshot.data == false;
        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.topCenter,
          child: offline
              ? const _Strip()
              : const SizedBox(width: double.infinity),
        );
      },
    );
  }
}

class _Strip extends StatelessWidget {
  const _Strip();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      color: c.warningSubtle,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.sm,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            HugeIcon(icon: AppIcons.offline, size: 18, color: c.warning),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                context.l10n.offlineBanner,
                style: context.text.bodySm.copyWith(
                  color: c.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
