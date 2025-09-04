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

class HealthDataFunctions {
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

  static OpenAIFunction getHealthSummary() {
    return OpenAIFunction(
      name: 'get_health_summary',
      description:
          'Get comprehensive health data summary including vital signs, sleep, nutrition, wellness metrics, and recent health insights for a user.',
      parameters: {
        'type': 'object',
        'properties': {
          'userId': {'type': 'string', 'description': 'User ID to analyze'},
          'days': {
            'type': 'number',
            'default': 7,
            'description':
                'Number of days to analyze from current date backwards (default: 7)',
          },
        },
        'required': ['userId'],
      },
    );
  }

  static OpenAIFunction getVitalSigns() {
    return OpenAIFunction(
      name: 'get_vital_signs',
      description:
          'Get vital signs data including heart rate, blood pressure, and other physiological measurements for a specific time period.',
      parameters: {
        'type': 'object',
        'properties': {
          'userId': {'type': 'string', 'description': 'User ID to analyze'},
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
          'measurementType': {
            'type': 'string',
            'description':
                'Specific vital sign type to filter by (optional): heart_rate, blood_pressure, temperature, etc.',
          },
        },
        'required': ['userId', 'startDate', 'endDate'],
      },
    );
  }

  static OpenAIFunction getSleepAnalysis() {
    return OpenAIFunction(
      name: 'get_sleep_analysis',
      description:
          'Get detailed sleep analysis including sleep duration, quality, patterns, and insights for better sleep hygiene.',
      parameters: {
        'type': 'object',
        'properties': {
          'userId': {'type': 'string', 'description': 'User ID to analyze'},
          'days': {
            'type': 'number',
            'default': 7,
            'description':
                'Number of days to analyze from current date backwards (default: 7)',
          },
        },
        'required': ['userId'],
      },
    );
  }

  static OpenAIFunction getNutritionAnalysis() {
    return OpenAIFunction(
      name: 'get_nutrition_analysis',
      description:
          'Get nutrition analysis including calorie intake, macronutrient breakdown, hydration, and meal patterns.',
      parameters: {
        'type': 'object',
        'properties': {
          'userId': {'type': 'string', 'description': 'User ID to analyze'},
          'days': {
            'type': 'number',
            'default': 7,
            'description':
                'Number of days to analyze from current date backwards (default: 7)',
          },
        },
        'required': ['userId'],
      },
    );
  }

  static OpenAIFunction getWellnessMetrics() {
    return OpenAIFunction(
      name: 'get_wellness_metrics',
      description:
          'Get wellness and mental health metrics including mood, stress levels, meditation, and overall wellness trends.',
      parameters: {
        'type': 'object',
        'properties': {
          'userId': {'type': 'string', 'description': 'User ID to analyze'},
          'days': {
            'type': 'number',
            'default': 7,
            'description':
                'Number of days to analyze from current date backwards (default: 7)',
          },
        },
        'required': ['userId'],
      },
    );
  }

  static OpenAIFunction getHealthInsights() {
    return OpenAIFunction(
      name: 'get_health_insights',
      description:
          'Get recent health insights, patterns, recommendations, and personalized health advice generated from the user\'s health data.',
      parameters: {
        'type': 'object',
        'properties': {
          'userId': {'type': 'string', 'description': 'User ID to analyze'},
          'category': {
            'type': 'string',
            'description':
                'Filter insights by category (optional): activity, sleep, nutrition, wellness, vital_signs',
          },
          'limit': {
            'type': 'number',
            'default': 5,
            'description': 'Maximum number of insights to return (default: 5)',
          },
        },
        'required': ['userId'],
      },
    );
  }

  static OpenAIFunction getGeneticInsights() {
    return OpenAIFunction(
      name: 'get_genetic_insights',
      description:
          'Get genetic insights and personalized health recommendations based on genetic data analysis. Includes genetic factors affecting metabolism, fitness response, nutrition needs, and health predispositions.',
      parameters: {
        'type': 'object',
        'properties': {
          'userId': {'type': 'string', 'description': 'User ID to analyze'},
          'insightType': {
            'type': 'string',
            'description':
                'Specific type of genetic insight to retrieve (optional): metabolism, fitness, nutrition, health_risks, all',
          },
          'limit': {
            'type': 'number',
            'default': 10,
            'description': 'Maximum number of genetic insights to return (default: 10)',
          },
        },
        'required': ['userId'],
      },
    );
  }

  static List<OpenAIFunction> getAllFunctions() {
    return [
      getStepSummary(),
      getActivityPatterns(),
      getHealthSummary(),
      getVitalSigns(),
      getSleepAnalysis(),
      getNutritionAnalysis(),
      getWellnessMetrics(),
      getHealthInsights(),
      getGeneticInsights(),
    ];
  }
}
