import '../data/mock_sales_repository.dart';

/// The `toolConfig` payload passed to the Bedrock Converse / ConverseStream
/// API at request time.
///
/// Registers `get_sales_data` so the LLM can request sales analytics data
/// after the user submits the input form.
const Map<String, Object?> salesDataToolConfig = {
  'tools': [
    {
      'toolSpec': {
        'name': 'get_sales_data',
        'description':
            'Fetches sales analytics data for the selected Indian states. '
            'Call this after the user submits the analytics input form.',
        'inputSchema': {
          'json': {
            'type': 'object',
            'properties': {
              'states': {
                'type': 'array',
                'items': {
                  'type': 'string',
                  'description': 'Indian state name.',
                },
                'description': 'States selected by the user.',
              },
              'kpi': {
                'type': 'string',
                'description':
                    'Sales KPI to analyze. One of: Revenue, Profit, '
                    'Volume, CAC, LTV.',
              },
              'year': {
                'type': 'integer',
                'description': 'The year for the data (e.g. 2025).',
              },
              'period': {
                'type': 'string',
                'description':
                    'Time-period granularity. One of: quarterly, monthly.',
              },
            },
            'required': ['states', 'kpi', 'year', 'period'],
          },
        },
      },
    },
  ],
};

/// Parses the raw [args] map from a Bedrock `toolUse` block and delegates to
/// [fetchSalesData] in the data layer.
Future<Map<String, Object?>> handleGetSalesData(Map<String, Object?> args) {
  final year = args['year'];
  return fetchSalesData(
    states: (args['states'] as List<Object?>? ?? const []).cast<String>(),
    kpi: args['kpi'] as String? ?? 'Revenue',
    year: year is int ? year : int.tryParse('${year ?? ''}') ?? 2025,
    period: args['period'] as String? ?? 'quarterly',
  );
}
