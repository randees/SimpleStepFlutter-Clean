class OpenAIFunction {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  OpenAIFunction({
    required this.name,
    required this.description,
    required this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description, 'parameters': parameters};
  }

  factory OpenAIFunction.fromJson(Map<String, dynamic> json) {
    return OpenAIFunction(
      name: json['name'] as String,
      description: json['description'] as String,
      parameters: json['parameters'] as Map<String, dynamic>,
    );
  }
}

class StepAnalyticsFunctions {
  static OpenAIFunction getStepSummary() {
    return OpenAIFunction(
      name: 'get_step_summary',
      description:
          'Get detailed step count analytics including most/least active days and weekly patterns. Use current date ranges - for recent queries default to last 30 days from today, for historical queries use earliest available data to today.',
      parameters: {
        'type': 'object',
        'properties': {
          'startDate': {
            'type': 'string',
            'format': 'date',
            'description':
                'Start date for analysis (YYYY-MM-DD). For recent data, use 30 days ago from current date. For historical data, use earliest available date.',
          },
          'endDate': {
            'type': 'string',
            'format': 'date',
            'description':
                'End date for analysis (YYYY-MM-DD). Should typically be current date unless user specifies otherwise.',
          },
          'userId': {'type': 'string', 'description': 'User ID to analyze'},
        },
        'required': ['startDate', 'endDate', 'userId'],
      },
    );
  }

  static OpenAIFunction getActivityPatterns() {
    return OpenAIFunction(
      name: 'get_activity_patterns',
      description:
          'Get activity patterns for the specified number of days including most/least active days of the week. Defaults to last 30 days from current date.',
      parameters: {
        'type': 'object',
        'properties': {
          'userId': {'type': 'string', 'description': 'User ID to analyze'},
          'days': {
            'type': 'number',
            'default': 30,
            'description':
                'Number of days to analyze from current date backwards (default: 30)',
          },
        },
        'required': ['userId'],
      },
    );
  }

  static List<OpenAIFunction> getAllFunctions() {
    return [getStepSummary(), getActivityPatterns()];
  }
}
