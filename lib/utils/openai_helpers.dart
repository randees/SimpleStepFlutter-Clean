import 'package:intl/intl.dart';

class StepAnalyticsPrompts {
  static const String mostActiveDay =
      "What was my most active day in the last 30 days? Show me the date and step count.";
  static const String leastActiveDay =
      "What was my least active day in the last 30 days? Show me the date and step count.";
  static const String weeklyPattern =
      "What day of the week am I most active? Show me my weekly step pattern.";
  static const String monthlyTrends =
      "Analyze my step trends over the last month. What insights can you provide?";
  static const String activityConsistency =
      "How consistent am I with my daily steps? Show me my activity patterns.";
  static const String compareWeekdays =
      "Compare my weekday vs weekend activity levels. When am I more active?";
  static const String bestWorstWeek =
      "What was my best and worst week for steps in the last month?";

  static List<String> getAllPrompts() {
    return [
      mostActiveDay,
      leastActiveDay,
      weeklyPattern,
      monthlyTrends,
      activityConsistency,
      compareWeekdays,
      bestWorstWeek,
    ];
  }
}

class OpenAIHelpers {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  /// Generate a date range for the last N days
  static Map<String, String> getLastNDaysRange(int days) {
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day);
    final startDate = endDate.subtract(Duration(days: days - 1));

    return {
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
    };
  }

  /// Generate a date range for the current month
  static Map<String, String> getCurrentMonthRange() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);

    return {
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
    };
  }

  /// Generate a date range for the current week
  static Map<String, String> getCurrentWeekRange() {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: now.weekday - 1));
    final endDate = startDate.add(const Duration(days: 6));

    return {
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
    };
  }

  /// Create function call arguments for step summary
  static Map<String, dynamic> createStepSummaryArgs({
    required String userId,
    String? startDate,
    String? endDate,
    int? lastNDays,
  }) {
    late final Map<String, String> dateRange;

    if (startDate != null && endDate != null) {
      dateRange = {'startDate': startDate, 'endDate': endDate};
    } else if (lastNDays != null) {
      dateRange = getLastNDaysRange(lastNDays);
    } else {
      dateRange = getLastNDaysRange(30); // Default to last 30 days
    }

    return {
      'userId': userId,
      'startDate': dateRange['startDate']!,
      'endDate': dateRange['endDate']!,
    };
  }

  /// Create function call arguments for activity patterns
  static Map<String, dynamic> createActivityPatternsArgs({
    required String userId,
    int days = 30,
  }) {
    return {'userId': userId, 'days': days};
  }

  /// Validate OpenAI API key format
  static bool isValidApiKey(String? apiKey) {
    if (apiKey == null || apiKey.isEmpty) return false;
    return apiKey.startsWith('sk-') && apiKey.length > 20;
  }

  /// Validate MCP endpoint URL
  static bool isValidMcpEndpoint(String? endpoint) {
    if (endpoint == null || endpoint.isEmpty) return false;
    try {
      final uri = Uri.parse(endpoint);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Format step count with commas
  static String formatStepCount(int steps) {
    return steps.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Extract step count from text
  static int? extractStepCount(String text) {
    final regex = RegExp(
      r'(\d{1,3}(?:,\d{3})*)\s*steps?',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    if (match != null) {
      final stepText = match.group(1)?.replaceAll(',', '');
      return int.tryParse(stepText ?? '');
    }
    return null;
  }

  /// Generate system prompt for step analytics
  static String getSystemPrompt() {
    return '''
You are a health analytics assistant specialized in step count data analysis. 
You have access to detailed step count data and can provide insights about:
- Daily, weekly, and monthly step patterns
- Most and least active days
- Activity trends and consistency
- Comparative analysis of different time periods

When analyzing step data, always:
1. Provide specific dates and step counts
2. Highlight interesting patterns or trends
3. Give actionable insights when possible
4. Use clear, friendly language
5. Format numbers with commas for readability

Use the available functions to access step data and provide accurate, data-driven responses.
''';
  }
}
