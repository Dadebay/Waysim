import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/money.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/copy_field.dart';
import '../../../config/presentation/cubit/config_cubit.dart';
import '../../domain/entities/wallet_entities.dart';
import '../cubit/top_up_cubit.dart';
import '../cubit/wallet_cubit.dart';

/// Top up the balance: amount → PayPal or crypto → credited.
///
/// Pops `true` once the money has arrived, so a purchase that sent the
/// customer here can go straight back to its confirmation.
class BalanceTopUpPage extends StatelessWidget {
  const BalanceTopUpPage({super.key, this.initialCents});

  /// Pre-filled amount when a purchase was short of balance.
  final int? initialCents;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<TopUpCubit>(param1: initialCents),
    child: const _View(),
  );
}

class _View extends StatefulWidget {
  const _View();

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Back from the PayPal browser or a wallet app: check the payment now.
    _lifecycle = AppLifecycleListener(
      onResume: () => context.read<TopUpCubit>().checkNow(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phase = context.select((TopUpCubit c) => c.state.phase);
    final l10n = context.l10n;
    final c = context.colors;

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: l10n.searchBack,
            onPressed: () => context.pop(phase == TopUpPhase.credited),
            icon: HugeIcon(icon: AppIcons.back, size: 24, color: c.textPrimary),
          ),
          title: Text(
            phase == TopUpPhase.paying &&
                    context.read<TopUpCubit>().state.method ==
                        TopUpMethod.crypto
                ? l10n.cryptoTitle
                : l10n.topUpTitle,
            style: context.text.h2,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: switch (phase) {
              TopUpPhase.form ||
              TopUpPhase.creating => const _Form(key: ValueKey('form')),
              TopUpPhase.paying => const _Paying(key: ValueKey('paying')),
              TopUpPhase.credited => const _Credited(key: ValueKey('ok')),
              TopUpPhase.expired ||
              TopUpPhase.failed => const _Expired(key: ValueKey('expired')),
            },
          ),
        ),
      ),
    );
  }
}

/// `20`, `20.5`, `20.50` → cents. Null for anything else.
int? parseDollars(String input) {
  final text = input.trim().replaceAll(',', '.');
  final match = RegExp(r'^(\d{1,6})(?:\.(\d{1,2}))?$').firstMatch(text);
  if (match == null) return null;
  final dollars = int.parse(match.group(1)!);
  final cents = int.parse((match.group(2) ?? '0').padRight(2, '0'));
  return dollars * 100 + cents;
}

class _Form extends StatefulWidget {
  const _Form({super.key});

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final TextEditingController _custom;

  @override
  void initState() {
    super.initState();
    final initial = context.read<TopUpCubit>().state.amount;
    // A short-by amount from a purchase is rarely a round preset: show it in
    // the custom field.
    final custom = initial != null && !_presets.contains(initial.cents);
    _custom = TextEditingController(
      text: custom ? (initial.cents / 100).toStringAsFixed(2) : '',
    );
  }

  static const _presets = [1000, 2000, 5000, 10000];

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  Future<void> _openCheckout(Uri url) async {
    await launchUrl(url, mode: LaunchMode.inAppBrowserView);
  }

  Future<void> _chooseCrypto(TopUpCubit cubit, CryptoOption current) async {
    final l10n = context.l10n;
    final selected = await showAppSheet<CryptoOption>(
      context,
      title: l10n.topUpCryptoTitle,
      subtitle: l10n.topUpCryptoBody,
      closeLabel: l10n.actionClose,
      builder: (sheetContext) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in TopUpCubit.cryptoOptions) ...[
              if (option != TopUpCubit.cryptoOptions.first)
                const SizedBox(height: AppSpacing.md),
              _CryptoChoice(
                option: option,
                selected: option == current,
                onTap: () => Navigator.of(sheetContext).pop(option),
              ),
            ],
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    cubit
      ..setMethod(TopUpMethod.crypto)
      ..setCrypto(selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final state = context.watch<TopUpCubit>().state;
    final cubit = context.read<TopUpCubit>();
    final config = context.watch<ConfigCubit>().state;
    final balance = context.watch<WalletCubit>().state.balance;
    final min = Money(config.minTopUpCents);
    final max = Money(config.maxTopUpCents);

    final amount = state.amount;
    final inRange =
        amount != null &&
        amount.cents >= config.minTopUpCents &&
        amount.cents <= config.maxTopUpCents;
    final customText = _custom.text.trim();
    final customInvalid = customText.isNotEmpty && (amount == null || !inRange);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        AppCard(
          color: c.surface,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.topUpCurrentBalance,
                  style: context.text.bodyMed.copyWith(color: c.textSecondary),
                ),
              ),
              Text(balance?.format() ?? '—', style: context.text.h1),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.topUpChooseAmount.toUpperCase(),
          style: context.text.caption.copyWith(
            color: c.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 2.6,
          children: [
            for (final cents in _presets)
              _AmountChip(
                label: Money(cents).format(withCents: false),
                selected: amount?.cents == cents && customText.isEmpty,
                onTap: () {
                  _custom.clear();
                  cubit.setAmount(Money(cents));
                  setState(() {});
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: l10n.topUpOtherAmount,
          hint: l10n.topUpAmountHint,
          controller: _custom,
          prefix: Text(r'$', style: context.text.bodyMed),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          helperText: l10n.topUpAmountRange(
            min.format(withCents: false),
            max.format(withCents: false),
          ),
          errorText: customInvalid
              ? l10n.topUpAmountInvalid(
                  min.format(withCents: false),
                  max.format(withCents: false),
                )
              : null,
          onChanged: (text) {
            final cents = parseDollars(text);
            cubit.setAmount(cents == null ? null : Money(cents));
            setState(() {});
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.topUpMethod.toUpperCase(),
          style: context.text.caption.copyWith(
            color: c.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (config.paypalEnabled)
          _MethodCard(
            key: const ValueKey('payment-paypal'),
            icon: AppIcons.paypal,
            title: l10n.topUpPaypalTitle,
            body: l10n.topUpPaypalBody,
            selected: state.method == TopUpMethod.paypal,
            onTap: () => cubit.setMethod(TopUpMethod.paypal),
          ),
        if (config.paypalEnabled && config.cryptoEnabled)
          const SizedBox(height: AppSpacing.sm),
        if (config.cryptoEnabled)
          _MethodCard(
            key: const ValueKey('payment-crypto'),
            icon: AppIcons.crypto,
            title: l10n.topUpCryptoTitle,
            body: state.method == TopUpMethod.crypto
                ? state.crypto.label
                : l10n.topUpCryptoBody,
            selected: state.method == TopUpMethod.crypto,
            onTap: () => _chooseCrypto(cubit, state.crypto),
          ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.topUpNote,
          style: context.text.caption.copyWith(color: c.textSecondary),
        ),
        if (state.failure != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text(
              state.failure!.localize(l10n),
              style: context.text.bodySm.copyWith(color: c.error),
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: inRange
              ? l10n.topUpButton(
                  amount.format(withCents: amount.cents % 100 != 0),
                )
              : l10n.topUpTitle,
          loading: state.phase == TopUpPhase.creating,
          onPressed: inRange && !config.maintenance
              ? () => cubit.submit(openUrl: _openCheckout)
              : null,
        ),
        if (config.maintenance)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              l10n.maintenanceBanner,
              textAlign: TextAlign.center,
              style: context.text.bodySm.copyWith(color: c.warning),
            ),
          ),
      ],
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AppCard(
        selected: selected,
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Center(
          child: Text(
            label,
            style: context.text.h2.copyWith(
              color: selected ? c.primary : c.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final AppIconData icon;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $body',
      excludeSemantics: true,
      child: AppCard(
        selected: selected,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: c.background,
                border: Border.all(color: c.border),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              alignment: Alignment.center,
              child: HugeIcon(icon: icon, size: 22, color: c.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.bodyMed.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: context.text.bodySm.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.background,
                border: Border.all(
                  color: selected ? c.primary : c.border,
                  width: selected ? 6.5 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The coins' own brand colours, so the list reads at a glance.
Color _coinColor(String coin) => switch (coin) {
  'USDT' => const Color(0xFF26A17B),
  'USDC' => const Color(0xFF2775CA),
  _ => const Color(0xFF6B7280),
};

class _CryptoChoice extends StatelessWidget {
  const _CryptoChoice({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final CryptoOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: option.label,
      excludeSemantics: true,
      child: AppCard(
        selected: selected,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _coinColor(option.coin),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                option.coin.substring(0, 1),
                style: context.text.h3.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.coin,
                    style: context.text.bodyMed.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? c.background : c.surface,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: c.border),
                    ),
                    child: Text(
                      option.network,
                      style: context.text.caption.copyWith(
                        color: c.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.background,
                border: Border.all(
                  color: selected ? c.primary : c.border,
                  width: selected ? 6.5 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The payment is open: PayPal waiting screen or the crypto invoice.
class _Paying extends StatelessWidget {
  const _Paying({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TopUpCubit>().state;
    final session = state.session;
    if (session == null) return const SizedBox.shrink();
    return session.crypto == null
        ? _PaypalWaiting(session: session)
        : _CryptoInvoice(session: session, progress: state.progress);
  }
}

class _PaypalWaiting extends StatelessWidget {
  const _PaypalWaiting({required this.session});

  final TopUpSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final url = session.checkoutUrl;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        children: [
          const Spacer(),
          const SizedBox.square(
            dimension: 64,
            child: CircularProgressIndicator(strokeWidth: 4),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            l10n.topUpPaypalWaitingTitle,
            style: context.text.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.topUpPaypalWaitingBody,
            style: context.text.body.copyWith(color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          if (url != null)
            AppButton(
              label: l10n.topUpReopenPaypal,
              variant: AppButtonVariant.secondary,
              onPressed: () =>
                  launchUrl(url, mode: LaunchMode.inAppBrowserView),
            ),
        ],
      ),
    );
  }
}

class _CryptoInvoice extends StatefulWidget {
  const _CryptoInvoice({required this.session, required this.progress});

  final TopUpSession session;
  final TopUpProgress progress;

  @override
  State<_CryptoInvoice> createState() => _CryptoInvoiceState();
}

class _CryptoInvoiceState extends State<_CryptoInvoice> {
  late final Timer _tick;

  @override
  void initState() {
    super.initState();
    // Redraws the countdown once a second.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final invoice = widget.session.crypto!;
    final progress = widget.progress;
    final left = invoice.expiresAt.difference(DateTime.now());
    final clock = left.isNegative
        ? '0:00'
        : '${left.inMinutes}:${(left.inSeconds % 60).toString().padLeft(2, '0')}';

    final step = switch (progress.status) {
      TopUpStatus.waiting => 0,
      TopUpStatus.confirming => 1,
      _ => 2,
    };

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoBox(label: l10n.cryptoCoin, value: invoice.coin),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _InfoBox(
                label: l10n.cryptoNetwork,
                value: invoice.network,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.primarySubtle,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.cryptoWaitingPayment,
                    style: context.text.bodyMed.copyWith(
                      color: c.link,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  clock,
                  style: context.text.bodyMed.copyWith(
                    color: c.link,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            _Step(
              label: l10n.cryptoStepWaiting,
              active: step >= 0,
              current: step == 0,
            ),
            _Step(
              label: l10n.cryptoStepConfirmations,
              detail: step == 1
                  ? l10n.cryptoConfirmationsOf(
                      progress.confirmations,
                      invoice.requiredConfirmations,
                    )
                  : null,
              active: step >= 1,
              current: step == 1,
            ),
            _Step(
              label: l10n.cryptoStepCredited,
              active: step >= 2,
              current: step == 2,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.cryptoSendExactly,
          style: context.text.bodySm.copyWith(color: c.textSecondary),
        ),
        Text(
          '${invoice.amountText} ${invoice.coin}',
          style: context.text.display,
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: c.border),
            ),
            child: QrImageView(
              data: invoice.address,
              size: 160,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF161D2B),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF161D2B),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        CopyField(label: l10n.cryptoToAddress, value: invoice.address),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.cryptoRateLocked(
            invoice.rateText,
            widget.session.amount.format(),
          ),
          style: context.text.caption.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.warningSubtle,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HugeIcon(icon: AppIcons.info, size: 20, color: c.warning),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.cryptoWarning(invoice.coin, invoice.network),
                    style: context.text.bodySm,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.cryptoCloseNote,
          textAlign: TextAlign.center,
          style: context.text.bodySm.copyWith(color: c.textSecondary),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.text.caption.copyWith(color: c.textSecondary),
            ),
            Text(value, style: context.text.h3),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.active,
    required this.current,
    this.detail,
  });

  final String label;
  final String? detail;
  final bool active;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: active ? c.primary : c.border,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.text.caption.copyWith(
              color: current ? c.textPrimary : c.textSecondary,
              fontWeight: current ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          if (detail != null)
            Text(detail!, style: context.text.caption.copyWith(color: c.link)),
        ],
      ),
    );
  }
}

class _Credited extends StatelessWidget {
  const _Credited({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final amount = context.read<TopUpCubit>().state.session?.amount;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: c.successSubtle,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: HugeIcon(icon: AppIcons.check, size: 44, color: c.success),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            l10n.topUpDoneTitle,
            style: context.text.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.topUpDoneBody(amount?.format() ?? ''),
            style: context.text.body.copyWith(color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          AppButton(label: l10n.actionDone, onPressed: () => context.pop(true)),
        ],
      ),
    );
  }
}

class _Expired extends StatelessWidget {
  const _Expired({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: c.warningSubtle,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: HugeIcon(icon: AppIcons.info, size: 44, color: c.warning),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            l10n.topUpExpiredTitle,
            style: context.text.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.topUpExpiredBody,
            style: context.text.body.copyWith(color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          AppButton(
            label: l10n.actionTryAgain,
            onPressed: () => context.read<TopUpCubit>().reset(),
          ),
        ],
      ),
    );
  }
}
