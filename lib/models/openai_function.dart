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
          'Get detailed step count analytics including most/least active days and weekly patterns',
      parameters: {
        'type': 'object',
        'properties': {
          'startDate': {
            'type': 'string',
            'format': 'date',
            'description': 'Start date for analysis (YYYY-MM-DD)',
          },
          'endDate': {
            'type': 'string',
            'format': 'date',
            'description': 'End date for analysis (YYYY-MM-DD)',
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
          'Get activity patterns for the last 30 days including most/least active days of the week',
      parameters: {
        'type': 'object',
        'properties': {
          'userId': {'type': 'string', 'description': 'User ID to analyze'},
          'days': {
            'type': 'number',
            'default': 30,
            'description': 'Number of days to analyze (default: 30)',
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
