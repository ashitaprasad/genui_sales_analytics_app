import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../widgets/metric_card_widget.dart';

/// Catalog item for a KPI metric card.
///
/// Displays a headline value, a descriptive title, and an optional trend
/// indicator (e.g. "+12%" in green or "-3%" in red).
final metricCardItem = CatalogItem(
  name: 'MetricCard',
  dataSchema: S.object(
    description:
        'A card displaying a single KPI metric with title, value, and '
        'optional trend indicator.',
    properties: {
      'title': S.string(description: 'Label for the metric.'),
      'value': S.string(
        description: 'Formatted metric value (e.g. "₹3,10,000" or "4,100").',
      ),
      'trend': S.string(
        description:
            'Optional trend text. Prefix with "+" for positive (shown in '
            'green) or "-" for negative (shown in red). E.g. "+12%".',
      ),
    },
    required: ['title', 'value'],
  ),
  widgetBuilder: (context) {
    final json = context.data as Map<String, Object?>;
    final title = (json['title'] as String?) ?? 'Metric';
    final value = (json['value'] as String?) ?? '—';
    final trend = json['trend'] as String?;
    return MetricCard(title: title, value: value, trend: trend);
  },
);
