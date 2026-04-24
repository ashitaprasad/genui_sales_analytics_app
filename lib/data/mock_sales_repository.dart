/// Mock Annual base KPI values for regions
const annualSalesValues = <String, Map<String, double>>{
  'Kerala': {
    'Revenue': 120000,
    'Profit': 40000,
    'Volume': 1500,
    'CAC': 25,
    'LTV': 300,
  },
  'Tamil Nadu': {
    'Revenue': 250000,
    'Profit': 85000,
    'Volume': 3200,
    'CAC': 18,
    'LTV': 450,
  },
  'Karnataka': {
    'Revenue': 310000,
    'Profit': 110000,
    'Volume': 4100,
    'CAC': 22,
    'LTV': 420,
  },
  'Andhra Pradesh': {
    'Revenue': 180000,
    'Profit': 60000,
    'Volume': 2200,
    'CAC': 28,
    'LTV': 350,
  },
  'Telangana': {
    'Revenue': 280000,
    'Profit': 95000,
    'Volume': 3500,
    'CAC': 20,
    'LTV': 500,
  },
  'Goa': {
    'Revenue': 90000,
    'Profit': 35000,
    'Volume': 1100,
    'CAC': 35,
    'LTV': 380,
  },
};

/// Mock seasonal distribution factors for quarterly and monthly breakdowns.
const quarterlyFactors = [0.22, 0.25, 0.28, 0.25];
const monthlyFactors = [
  0.07,
  0.07,
  0.08,
  0.08,
  0.09,
  0.09,
  0.08,
  0.08,
  0.09,
  0.09,
  0.08,
  0.10,
];

/// Simulates fetching sales analytics data from a remote API.
/// Returns a structured map with a regional summary and a period breakdown,
/// ready to be serialised as a Bedrock tool-use result.
Future<Map<String, Object?>> fetchSalesData({
  required List<String> states,
  required String kpi,
  required int year,
  required String period,
}) async {
  // Simulate network latency.
  await Future<void>.delayed(const Duration(milliseconds: 800));

  final isQuarterly = period.toLowerCase() == 'quarterly';
  final labels = isQuarterly
      ? ['Q1', 'Q2', 'Q3', 'Q4']
      : [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
  final factors = isQuarterly ? quarterlyFactors : monthlyFactors;

  // Regional summary: total annual KPI value per state.
  final regionalSummary = <String, Object?>{};
  for (final state in states) {
    final value = annualSalesValues[state]?[kpi];
    if (value != null) regionalSummary[state] = value.round();
  }

  // Period breakdown: value per label per state.
  final periodData = <String, Object?>{};
  for (final state in states) {
    final annual = annualSalesValues[state]?[kpi] ?? 0.0;
    final breakdown = <String, Object?>{};
    for (var i = 0; i < labels.length; i++) {
      breakdown[labels[i]] = (annual * factors[i]).round();
    }
    periodData[state] = breakdown;
  }

  return {
    'kpi': kpi,
    'year': year,
    'period': period,
    'states': states,
    'regional_summary': regionalSummary,
    'period_data': periodData,
  };
}
