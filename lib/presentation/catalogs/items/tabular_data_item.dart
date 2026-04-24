import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../widgets/tabular_data_widget.dart';

/// Catalog item for a scrollable data table.
///
/// Renders column headers and rows of string cells.  Wraps in a
/// [SingleChildScrollView] so wide tables scroll horizontally.
final tabularDataItem = CatalogItem(
  name: 'TabularData',
  dataSchema: S.object(
    description: 'A scrollable data table with named columns and string rows.',
    properties: {
      'title': S.string(description: 'Optional table title.'),
      'columns': S.list(
        description: 'Column header labels.',
        items: S.string(),
      ),
      'rows': S.list(
        description:
            'Table rows. Each row is an array of string cells matching '
            'the column order.',
        items: S.list(items: S.string()),
      ),
    },
    required: ['columns', 'rows'],
  ),
  widgetBuilder: (context) {
    final json = context.data as Map<String, Object?>;
    final title = json['title'] as String?;
    final columns = (json['columns'] as List<dynamic>).cast<String>();
    final rows = (json['rows'] as List<dynamic>)
        .cast<List<dynamic>>()
        .map((r) => r.cast<String>())
        .toList();
    return TabularData(title: title, columns: columns, rows: rows);
  },
);
