import 'dart:convert';
import 'package:simple_step_flutter/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:retry/retry.dart';
import '../config/openai_config.dart';
import '../models/mcp_message.dart';
import '../models/openai_function.dart';
import '../models/step_analytics.dart';
import '../utils/mcp_logger.dart';
import '../utils/openai_helpers.dart';

class MCPClientService {
  late final Dio _dio;
  final String? _userId;

  MCPClientService({String? userId}) : _userId = userId {
    _dio = Dio(
      BaseOptions(
        connectTimeout: OpenAIConfig.defaultTimeout,
        receiveTimeout: OpenAIConfig.defaultTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptor for logging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => MCPLogger.debug(obj.toString(), tag: 'HTTP'),
      ),
    );
  }

  /// Initialize the MCP server connection
  Future<bool> initialize() async {
    if (!OpenAIConfig.isConfigured) {
      MCPLogger.error('OpenAI configuration is not complete');
      return false;
    }

    try {
      final message = MCPMessage(method: 'initialize');
      final response = await _sendMCPRequest(message);

      if (response.isSuccess) {
        MCPLogger.info('MCP server initialized successfully');
        return true;
      } else {
        MCPLogger.error(
          'Failed to initialize MCP server: ${response.error?.message}',
        );
        return false;
      }
    } catch (e, stackTrace) {
      MCPLogger.error(
        'Error initializing MCP server',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Get available tools from the MCP server
  Future<List<OpenAIFunction>> getAvailableTools() async {
    try {
      final message = MCPMessage(method: 'tools/list');
      final response = await _sendMCPRequest(message);

      if (response.isSuccess && response.result != null) {
        final tools = response.result!['tools'] as List?;
        if (tools != null) {
          return tools
              .map(
                (tool) => OpenAIFunction.fromJson(tool as Map<String, dynamic>),
              )
              .toList();
        }
      }

      MCPLogger.warning('Failed to get tools, using default functions');
      return StepAnalyticsFunctions.getAllFunctions();
    } catch (e) {
      MCPLogger.error('Error getting available tools', error: e);
      return StepAnalyticsFunctions.getAllFunctions();
    }
  }

  /// Get step summary for a date range
  Future<StepAnalytics?> getStepSummary({
    String? startDate,
    String? endDate,
    int? lastNDays,
  }) async {
    if (_userId == null) {
      MCPLogger.error('User ID is required for step analytics');
      return null;
    }

    try {
      final args = OpenAIHelpers.createStepSummaryArgs(
        userId: _userId,
        startDate: startDate,
        endDate: endDate,
        lastNDays: lastNDays,
      );

      final message = MCPMessage(
        method: 'tools/call',
        params: {'name': 'get_step_summary', 'arguments': args},
      );

      MCPLogger.logAPICall('get_step_summary', args);
      final response = await _sendMCPRequest(message);

      if (response.isSuccess && response.result != null) {
        MCPLogger.logResponse('get_step_summary', true);
        // Check if mock data is enabled in config
        if (AppConfig.enableMockData) {
          return _createMockStepAnalytics(args);
        } else {
          // No mock data - return null when real MCP server not available
          MCPLogger.info(
            'Mock data disabled - returning null for step analytics',
          );
          return null;
        }
      } else {
        MCPLogger.logResponse(
          'get_step_summary',
          false,
          errorMessage: response.error?.message,
        );
        return null;
      }
    } catch (e, stackTrace) {
      MCPLogger.error(
        'Error getting step summary',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Get activity patterns
  Future<ActivityPatterns?> getActivityPatterns({int days = 30}) async {
    if (_userId == null) {
      MCPLogger.error('User ID is required for activity patterns');
      return null;
    }

    try {
      final args = OpenAIHelpers.createActivityPatternsArgs(
        userId: _userId,
        days: days,
      );

      final message = MCPMessage(
        method: 'tools/call',
        params: {'name': 'get_activity_patterns', 'arguments': args},
      );

      MCPLogger.logAPICall('get_activity_patterns', args);
      final response = await _sendMCPRequest(message);

      if (response.isSuccess && response.result != null) {
        MCPLogger.logResponse('get_activity_patterns', true);
        // Check if mock data is enabled in config
        if (AppConfig.enableMockData) {
          return _createMockActivityPatterns();
        } else {
          // No mock data - return null when real MCP server not available
          MCPLogger.info(
            'Mock data disabled - returning null for activity patterns',
          );
          return null;
        }
      } else {
        MCPLogger.logResponse(
          'get_activity_patterns',
          false,
          errorMessage: response.error?.message,
        );
        return null;
      }
    } catch (e, stackTrace) {
      MCPLogger.error(
        'Error getting activity patterns',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Query step data with natural language
  Future<String?> queryStepData(String prompt) async {
    try {
      MCPLogger.logOpenAIRequest(prompt, [
        'get_step_summary',
        'get_activity_patterns',
      ]);

      // For this proof of concept, we'll simulate OpenAI responses based on the prompt
      final response = await _simulateOpenAIResponse(prompt);

      if (response != null) {
        MCPLogger.logOpenAIResponse(response, functionCalled: true);
      }

      return response;
    } catch (e, stackTrace) {
      MCPLogger.error(
        'Error querying step data',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Convenience methods for common queries
  Future<String?> getMostActiveDay() async {
    return await queryStepData(StepAnalyticsPrompts.mostActiveDay);
  }

  Future<String?> getLeastActiveDay() async {
    return await queryStepData(StepAnalyticsPrompts.leastActiveDay);
  }

  Future<String?> getWeeklyPattern() async {
    return await queryStepData(StepAnalyticsPrompts.weeklyPattern);
  }

  Future<String?> getMonthlyTrends() async {
    return await queryStepData(StepAnalyticsPrompts.monthlyTrends);
  }

  /// Send MCP request with retry logic
  Future<MCPResponse> _sendMCPRequest(MCPMessage message) async {
    return await retry(
      () async {
        final response = await _dio.post(
          OpenAIConfig.mcpEndpoint!,
          data: jsonEncode(message.toJson()),
          options: Options(
            headers: {
              'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
              'X-MCP-Secret': OpenAIConfig.mcpSecret,
            },
          ),
        );

        if (response.statusCode == 200) {
          return MCPResponse.fromJson(response.data as Map<String, dynamic>);
        } else {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            message: 'HTTP ${response.statusCode}',
          );
        }
      },
      retryIf: (e) => e is DioException && e.response?.statusCode != 401,
      maxAttempts: OpenAIHelpers.maxRetries,
      delayFactor: OpenAIHelpers.retryDelay,
    );
  }

  /// Simulate OpenAI response for testing (remove when real OpenAI integration is ready)
  Future<String?> _simulateOpenAIResponse(String prompt) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final lowerPrompt = prompt.toLowerCase();

    if (lowerPrompt.contains('most active day')) {
      final analytics = await getStepSummary(lastNDays: 30);
      if (analytics != null) {
        return "🏆 Your most active day in the last 30 days was ${analytics.mostActiveDay.date} with ${OpenAIHelpers.formatStepCount(analytics.mostActiveDay.steps)} steps! That's ${analytics.mostActiveDay.steps - analytics.averageSteps} steps above your daily average.";
      }
    } else if (lowerPrompt.contains('least active') ||
        lowerPrompt.contains('lowest')) {
      final analytics = await getStepSummary(lastNDays: 30);
      if (analytics != null) {
        return "😴 Your least active day in the last 30 days was ${analytics.leastActiveDay.date} with ${OpenAIHelpers.formatStepCount(analytics.leastActiveDay.steps)} steps. Even rest days are important for recovery!";
      }
    } else if (lowerPrompt.contains('weekly pattern') ||
        lowerPrompt.contains('day of the week')) {
      final patterns = await getActivityPatterns();
      if (patterns != null) {
        return "📅 Based on your weekly pattern, you're most active on ${patterns.mostActiveWeekday} with an average of ${OpenAIHelpers.formatStepCount(patterns.mostActiveWeekdayAverage)} steps. Your least active day is ${patterns.leastActiveWeekday} with ${OpenAIHelpers.formatStepCount(patterns.leastActiveWeekdayAverage)} steps on average.";
      }
    } else if (lowerPrompt.contains('trend') ||
        lowerPrompt.contains('analysis')) {
      final analytics = await getStepSummary(lastNDays: 30);
      if (analytics != null) {
        return analytics.getFormattedSummary();
      }
    }

    return "I can help you analyze your step data! Try asking about your most active day, weekly patterns, or monthly trends.";
  }

  /// Create mock step analytics for testing
  StepAnalytics _createMockStepAnalytics(Map<String, dynamic> args) {
    final startDate = DateTime.parse(args['startDate'] as String);
    final endDate = DateTime.parse(args['endDate'] as String);
    final days = endDate.difference(startDate).inDays + 1;

    // Generate realistic mock data
    final mockDailyData = <DailyStepData>[];
    int totalSteps = 0;

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final steps =
          5000 +
          (date.weekday <= 5 ? 3000 : 1000) +
          (DateTime.now().millisecond % 5000); // Simulate variation

      mockDailyData.add(
        DailyStepData(
          date: date.toIso8601String().substring(0, 10),
          steps: steps,
        ),
      );
      totalSteps += steps;
    }

    // Find most/least active days
    mockDailyData.sort((a, b) => b.steps.compareTo(a.steps));
    final mostActive = mockDailyData.first;
    final leastActive = mockDailyData.last;

    // Calculate weekly pattern
    final weeklyPattern = <String, int>{};
    final dayTotals = <String, List<int>>{};

    for (final day in mockDailyData) {
      final weekdayName = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ][DateTime.parse(day.date).weekday - 1];

      if (!dayTotals.containsKey(weekdayName)) {
        dayTotals[weekdayName] = [];
      }
      dayTotals[weekdayName]!.add(day.steps);
    }

    dayTotals.forEach((day, steps) {
      weeklyPattern[day] = (steps.reduce((a, b) => a + b) / steps.length)
          .round();
    });

    return StepAnalytics(
      totalSteps: totalSteps,
      averageSteps: (totalSteps / days).round(),
      mostActiveDay: MostActiveDay(
        date: mostActive.date,
        steps: mostActive.steps,
      ),
      leastActiveDay: LeastActiveDay(
        date: leastActive.date,
        steps: leastActive.steps,
      ),
      weeklyPattern: weeklyPattern,
      dailyData: mockDailyData,
      analysisStartDate: startDate,
      analysisEndDate: endDate,
    );
  }

  /// Create mock activity patterns for testing
  ActivityPatterns _createMockActivityPatterns() {
    final analytics = _createMockStepAnalytics({
      'startDate': OpenAIHelpers.getLastNDaysRange(30)['startDate']!,
      'endDate': OpenAIHelpers.getLastNDaysRange(30)['endDate']!,
    });

    // Find most/least active weekdays
    final sortedWeekdays = analytics.weeklyPattern.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ActivityPatterns(
      mostActiveWeekday: sortedWeekdays.first.key,
      leastActiveWeekday: sortedWeekdays.last.key,
      mostActiveWeekdayAverage: sortedWeekdays.first.value,
      leastActiveWeekdayAverage: sortedWeekdays.last.value,
      stepAnalytics: analytics,
    );
  }
}
