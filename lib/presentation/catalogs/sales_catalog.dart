import 'package:genui/genui.dart';

import '../../tools/get_sales_data_client_function.dart';
import 'items/items.dart';

/// Builds the catalog for the Sales Analytics app.
Catalog buildCatalog() {
  return BasicCatalogItems.asCatalog(
        systemPromptFragments: [
          'Use ChoicePicker for all selection inputs (multi-select and single-select).',
          'Use TextField for free-text input such as the year field.',
          'Use a Row with two Buttons as the form submit actions: "Visualize" (for charts) and "View data" (for tabular data).',
          'Arrange form fields vertically using Column.',
        ],
      )
      .copyWithout(
        itemsToRemove: [
          // Remove built-in items that are not needed for this app.
          BasicCatalogItems.audioPlayer,
          BasicCatalogItems.card,
          BasicCatalogItems.checkBox,
          BasicCatalogItems.dateTimeInput,
          BasicCatalogItems.divider,
          BasicCatalogItems.icon,
          BasicCatalogItems.image,
          BasicCatalogItems.list,
          BasicCatalogItems.modal,
          BasicCatalogItems.slider,
          BasicCatalogItems.tabs,
          BasicCatalogItems.video,
        ],
      )
      .copyWith(
        catalogId: 'sales_analytics_catalog',
        newItems: [
          // Custom analytics widgets.
          metricCardItem,
          donutChartItem,
          barChartItem,
          tabularDataItem,
        ],
        newFunctions: [const GetSalesDataClientFunction()],
        systemPromptFragments: [
          'Use MetricCard to highlight a single KPI value with an optional trend.',
          'Use DonutChart to compare KPI values across regions — each slice is one region.',
          'Use BarChart to show KPI values per time period (quarters or months).',
          'Use TabularData for a full breakdown table (regions as rows, periods as columns).',
        ],
      );
}
