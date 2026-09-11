import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/page_size_dropdown.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/activity_log_entry.dart';
import '../cubit/activity_log_cubit.dart';
import '../cubit/activity_log_state.dart';

/// Activity Log: full audit trail of every action taken in the app.
/// Matches APP_CONTEXT.md's "7. More → Activity Log" spec (no reference
/// screenshot exists for this page). Single-user app, so no "User"
/// column, per the spec.
class ActivityLogPage extends StatelessWidget {
  const ActivityLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActivityLogCubit(),
      child: const _ActivityLogView(),
    );
  }
}

class _ActivityLogView extends StatelessWidget {
  const _ActivityLogView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<ActivityLogCubit, ActivityLogState>(
          builder: (context, state) {
            final cubit = context.read<ActivityLogCubit>();
            final visible = state.filteredEntries;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal).copyWith(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              children: [
                _Header(eventCount: state.entries.length),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  onChanged: cubit.searchChanged,
                  style: AppTextStyles.body(colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'activityLog.searchHint'.tr(),
                    hintStyle: AppTextStyles.hint(colors.textSecondary),
                    prefixIcon: Icon(Icons.search_rounded, color: colors.textSecondary, size: 20),
                    filled: true,
                    fillColor: colors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.button), borderSide: BorderSide(color: colors.border)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                      borderSide: BorderSide(color: colors.primaryAction, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('activityLog.matchCount'.tr(namedArgs: {'count': '${state.totalMatchCount}'}), style: AppTextStyles.body(colors.textSecondary)),
                    PageSizeDropdown(value: state.pageSize, onChanged: cubit.pageSizeChanged),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (visible.isEmpty)
                  EmptyState(
                    icon: Icons.show_chart_rounded,
                    title: 'activityLog.empty.title'.tr(),
                    description: 'activityLog.empty.description'.tr(),
                  )
                else
                  _ActivityTable(entries: visible),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int eventCount;

  const _Header({required this.eventCount});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'activityLog.title'.tr(),
                      style: AppTextStyles.pageTitle(colors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusBadge(label: 'activityLog.eventCount'.tr(namedArgs: {'count': '$eventCount'}), type: StatusBadgeType.neutral),
                ],
              ),
              const SizedBox(height: 4),
              Text('activityLog.subtitle'.tr(), style: AppTextStyles.body(colors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityTable extends StatelessWidget {
  final List<ActivityLogEntry> entries;

  const _ActivityTable({required this.entries});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(colors.background),
            headingTextStyle: AppTextStyles.body(colors.textSecondary).copyWith(fontWeight: FontWeight.w600),
            dataTextStyle: AppTextStyles.body(colors.textPrimary),
            dividerThickness: 1,
            columns: [
              DataColumn(label: Text('activityLog.table.timestamp'.tr())),
              DataColumn(label: Text('activityLog.table.actionType'.tr())),
              DataColumn(label: Text('activityLog.table.details'.tr())),
            ],
            rows: entries.map((entry) {
              return DataRow(cells: [
                DataCell(Text(formatDateTime(entry.timestamp))),
                DataCell(_actionBadge(entry.type)),
                DataCell(SizedBox(width: 260, child: Text(entry.details, softWrap: true))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _actionBadge(ActivityActionType type) {
    switch (type) {
      case ActivityActionType.login:
      case ActivityActionType.create:
        return StatusBadge(label: type.label, type: StatusBadgeType.neutral);
      case ActivityActionType.edit:
        return StatusBadge(label: type.label, type: StatusBadgeType.warning);
      case ActivityActionType.delete:
        return StatusBadge(label: type.label, type: StatusBadgeType.danger);
      case ActivityActionType.fullCollection:
        return StatusBadge(label: type.label, type: StatusBadgeType.success);
    }
  }
}
