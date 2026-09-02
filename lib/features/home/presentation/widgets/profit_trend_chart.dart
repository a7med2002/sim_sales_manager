import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/chart_point.dart';

/// Simple single-series line chart drawn with CustomPaint — no external
/// chart package needed.
class ProfitTrendChart extends StatelessWidget {
  final List<ProfitTrendPoint> data;
  static const double _chartHeight = 140;

  const ProfitTrendChart({super.key, required this.data});

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
    final maxValue = data.fold<double>(0, (max, p) => p.profit > max ? p.profit : max);
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
                width: double.infinity,
                child: CustomPaint(
                  painter: _LineChartPainter(
                    values: data.map((p) => p.profit).toList(),
                    maxValue: niceMax,
                    lineColor: colors.success,
                    gridColor: colors.border,
                  ),
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

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double maxValue;
  final Color lineColor;
  final Color gridColor;

  _LineChartPainter({
    required this.values,
    required this.maxValue,
    required this.lineColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height - (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) return;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? 0.0 : (size.width / (values.length - 1)) * i;
      final y = maxValue == 0 ? size.height : size.height - (values[i] / maxValue) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.lineColor != lineColor;
  }
}
