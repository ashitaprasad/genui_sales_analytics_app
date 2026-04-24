// TODO: Replace with 'package:genui/genui.dart' once genui publishes the latest release
// that exports ClientFunction. Tracked in flutter/genui#866.
import 'package:genui/src/model/client_function.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import 'sales_data_tool.dart';

/// A GenUI [ClientFunction] that exposes `get_sales_data` as a client-side
/// callable from within UI JSON data bindings like -
/// { "call": "get_sales_data", "args": { "states": [...], "kpi": "Revenue", ... } }
class GetSalesDataClientFunction implements ClientFunction {
  const GetSalesDataClientFunction();

  @override
  String get name => 'get_sales_data';

  @override
  String get description =>
      'Fetches sales analytics data for the selected Indian states. '
      'Provide states (list), kpi (string), year (int), and period (string).';

  @override
  ClientFunctionReturnType get returnType => ClientFunctionReturnType.object;

  @override
  S get argumentSchema => S.object(
    properties: {
      'states': S.list(
        items: S.string(description: 'Indian state name.'),
        description: 'States selected by the user.',
      ),
      'kpi': S.string(
        description:
            'Sales KPI to analyze. One of: Revenue, Profit, Volume, CAC, LTV.',
      ),
      'year': S.integer(description: 'The year for the data (e.g. 2024).'),
      'period': S.string(
        description: 'Time-period granularity. One of: quarterly, monthly.',
      ),
    },
  );

  @override
  Stream<Object?> execute(Map<String, Object?> args, ExecutionContext context) {
    return Stream.fromFuture(handleGetSalesData(args));
  }
}
