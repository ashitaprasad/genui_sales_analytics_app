import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../widgets/bar_chart_widget.dart';

final _seriesItemSchema = S.object(
  properties: {
    'label': S.string(description: 'Series label.'),
    'value': S.number(description: 'Numeric value.'),
  },
  required: ['label', 'value'],
);

/// Catalog item for a horizontal bar chart comparing discrete values.
final barChartItem = CatalogItem(
  name: 'BarChart',
  dataSchema: S.object(
    description:
        'A horizontal bar chart comparing discrete KPI values across categories.',
    properties: {
      'title': S.string(description: 'Chart title.'),
      'series': S.list(
        description: 'Data series — one entry per bar.',
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
    return BarChart(title: title, series: series);
  },
);
