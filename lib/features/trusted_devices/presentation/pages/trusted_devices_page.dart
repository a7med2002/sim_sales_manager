import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/trusted_device.dart';
import '../cubit/trusted_devices_cubit.dart';

/// Trusted Devices: devices/browsers that skip the verification code
/// until their session expires. Matches APP_CONTEXT.md's "6. Trusted
/// Devices" spec (no reference screenshot exists for this page).
class TrustedDevicesPage extends StatelessWidget {
  const TrustedDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrustedDevicesCubit(),
      child: const _TrustedDevicesView(),
    );
  }
}

class _TrustedDevicesView extends StatelessWidget {
  const _TrustedDevicesView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<TrustedDevicesCubit, List<TrustedDevice>>(
          builder: (context, devices) {
            final cubit = context.read<TrustedDevicesCubit>();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              children: [
                AppTopBar(title: 'trustedDevices.title'.tr(), showBack: true),
                const SizedBox(height: 4),
                Text(
                  'trustedDevices.description'.tr(),
                  style: AppTextStyles.body(colors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                if (devices.isEmpty)
                  EmptyState(
                    icon: Icons.devices_other_outlined,
                    title: 'trustedDevices.empty.title'.tr(),
                    description: 'trustedDevices.empty.description'.tr(),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 600;
                      if (!isWide) {
                        return Column(
                          children: devices
                              .map((d) => Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                                    child: _DeviceCard(device: d, onRevoke: () => _confirmRevoke(context, cubit, d)),
                                  ))
                              .toList(),
                        );
                      }
                      return Wrap(
                        spacing: AppSpacing.cardGap,
                        runSpacing: AppSpacing.cardGap,
                        children: devices
                            .map((d) => SizedBox(
                                  width: (constraints.maxWidth - AppSpacing.cardGap) / 2,
                                  child: _DeviceCard(device: d, onRevoke: () => _confirmRevoke(context, cubit, d)),
                                ))
                            .toList(),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmRevoke(BuildContext context, TrustedDevicesCubit cubit, TrustedDevice device) {
    showConfirmDialog(
      context,
      title: 'trustedDevices.revokeDialog.title'.tr(namedArgs: {'name': device.name}),
      message: 'trustedDevices.revokeDialog.message'.tr(),
      confirmLabel: 'trustedDevices.revokeDialog.confirm'.tr(),
      onConfirm: () => cubit.revoke(device.id),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final TrustedDevice device;
  final VoidCallback onRevoke;

  const _DeviceCard({required this.device, required this.onRevoke});

  IconData get _icon {
    switch (device.type) {
      case DeviceType.mobile:
        return Icons.phone_iphone_outlined;
      case DeviceType.desktop:
        return Icons.desktop_windows_outlined;
      case DeviceType.tablet:
        return Icons.tablet_mac_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle, border: Border.all(color: colors.border)),
                alignment: Alignment.center,
                child: Icon(_icon, size: 20, color: colors.textPrimary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name, style: AppTextStyles.cardTitle(colors.textPrimary)),
                    if (device.isThisDevice) ...[
                      const SizedBox(height: 4),
                      StatusBadge(label: 'trustedDevices.thisDevice'.tr(), type: StatusBadgeType.success),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: onRevoke,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colors.border)),
                  alignment: Alignment.center,
                  child: Icon(Icons.delete_outline_rounded, size: 16, color: colors.danger),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(height: 1, color: colors.border),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'trustedDevices.info.ipAddress'.tr(), value: device.ipAddress),
          _InfoRow(label: 'trustedDevices.info.firstLogin'.tr(), value: formatDateTime(device.firstLogin)),
          _InfoRow(label: 'trustedDevices.info.lastLogin'.tr(), value: formatDateTime(device.lastLogin)),
          _InfoRow(label: 'trustedDevices.info.lastVerification'.tr(), value: formatDateTime(device.lastVerification)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body(colors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.body(colors.textPrimary).copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
