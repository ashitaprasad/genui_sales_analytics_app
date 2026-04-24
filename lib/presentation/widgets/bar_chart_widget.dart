import 'dart:math' as math;

import 'package:flutter/material.dart';

const _chartColors = [
  Color(0xFF6200EE),
  Color(0xFF03DAC6),
  Color(0xFFFF6D00),
  Color(0xFF2979FF),
  Color(0xFFD50000),
  Color(0xFF00BFA5),
];

class BarChart extends StatelessWidget {
  const BarChart({super.key, this.title, required this.series});

  final String? title;
  final List<Map<String, dynamic>> series;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) return const SizedBox.shrink();

    final values = series.map((s) => (s['value'] as num).toDouble()).toList();
    final maxValue = values.reduce(math.max);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 480),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              for (var i = 0; i < series.length; i++) ...[
                _BarRow(
                  label: series[i]['label'].toString(),
                  value: values[i],
                  maxValue: maxValue,
                  color: _chartColors[i % _chartColors.length],
                ),
                if (i < series.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final String label;
  final double value;
  final double maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = maxValue == 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);
    final displayValue = value >= 1000
        ? '${(value / 1000).toStringAsFixed(1)}K'
        : value.toStringAsFixed(0);

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: fraction,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          child: Text(
            displayValue,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
