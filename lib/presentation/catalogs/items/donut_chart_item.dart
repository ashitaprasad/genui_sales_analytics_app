import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../widgets/donut_chart_widget.dart';

final _seriesItemSchema = S.object(
  properties: {
    'label': S.string(description: 'Series label.'),
    'value': S.number(description: 'Numeric value.'),
  },
  required: ['label', 'value'],
);

/// Catalog item for a donut chart comparing proportional values by category.
final donutChartItem = CatalogItem(
  name: 'DonutChart',
  dataSchema: S.object(
    description:
        'A donut chart comparing proportional KPI values across categories '
        '(e.g., regional revenue share).',
    properties: {
      'title': S.string(description: 'Chart title.'),
      'series': S.list(
        description: 'Data series — one slice per entry.',
        items: _seriesItemSchema,
      ),
    },
    required: ['series'],
  ),
  widgetBuilder: (context) {
    final json = context.data as Map<String, Object?>;
    final title = json['title'] as String?;
    final series = (json['series'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return DonutChart(title: title, series: series);
  },
);
