import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/chart_point.dart';

/// Simple two-series bar chart (sales = ink, profit = green) with no
/// external chart package — built from plain Containers.
class SalesProfitChart extends StatelessWidget {
  final List<SalesProfitPoint> data;
  static const double _chartHeight = 140;

  const SalesProfitChart({super.key, required this.data});

  double _niceMax(double value) {
    if (value <= 0) return 100;
    final magnitude = pow(10, (log(value) / ln10).floor()).toDouble();
    final residual = value / magnitude;
    double niceResidual;
    if (residual <= 1) {
      niceResidual = 1;
    } else if (residual <= 2) {
      niceResidual = 2;
    } else if (residual <= 5) {
      niceResidual = 5;
    } else {
      niceResidual = 10;
    }
    return niceResidual * magnitude;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxValue = data.fold<double>(0, (max, p) => [max, p.sales, p.profit].reduce((a, b) => a > b ? a : b));
    final niceMax = _niceMax(maxValue);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          height: _chartHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(5, (i) {
              final v = niceMax - (niceMax / 4) * i;
              return Text(
                formatCurrencyCompact(v),
                style: AppTextStyles.body(colors.textSecondary).copyWith(height: 1),
              );
            }),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            children: [
              SizedBox(
                height: _chartHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: data.map((point) {
                    final salesHeight = (point.sales / niceMax) * _chartHeight;
                    final profitHeight = (point.profit / niceMax) * _chartHeight;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 10,
                          height: salesHeight,
                          decoration: BoxDecoration(
                            color: colors.textPrimary,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 10,
                          height: profitHeight,
                          decoration: BoxDecoration(
                            color: colors.success,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: data
                    .map((p) => Text(p.label, style: AppTextStyles.body(colors.textSecondary)))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
