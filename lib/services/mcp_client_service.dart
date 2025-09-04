import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:retry/retry.dart';
import '../config/openai_config.dart';
import '../config/env_config.dart';
import '../models/mcp_message.dart';
import '../models/openai_function.dart';
import '../models/step_analytics.dart';
import '../utils/mcp_logger.dart';
import '../utils/openai_helpers.dart';
import 'supabase_service.dart';

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
    MCPLogger.info('🔄 Starting MCP server initialization...');

    // Log configuration status
    final configSummary = OpenAIConfig.getConfigSummary();
    MCPLogger.info('📋 Configuration Summary:');
    configSummary.forEach((key, value) {
      MCPLogger.info('   - $key: $value');
    });

    if (!OpenAIConfig.isConfigured) {
      MCPLogger.error('❌ OpenAI configuration is not complete');
      MCPLogger.error(
        '   - API Key present: ${OpenAIConfig.apiKey.isNotEmpty}',
      );
      MCPLogger.error('   - MCP Endpoint: ${OpenAIConfig.mcpEndpoint}');
      MCPLogger.error(
        '   - MCP Secret present: ${OpenAIConfig.mcpSecret.isNotEmpty}',
      );
      return false;
    }

    MCPLogger.info('✅ OpenAI configuration is complete');
    MCPLogger.info('   - MCP Endpoint: ${OpenAIConfig.mcpEndpoint}');
    MCPLogger.info('   - API Key length: ${OpenAIConfig.apiKey.length}');
    MCPLogger.info('   - MCP Secret length: ${OpenAIConfig.mcpSecret.length}');

    try {
      final message = MCPMessage(method: 'initialize');
      MCPLogger.info('📤 Sending MCP initialization request...');
      final response = await _sendMCPRequest(message);

      if (response.isSuccess) {
        MCPLogger.info('✅ MCP server initialized successfully');
        return true;
      } else {
        MCPLogger.error('❌ Failed to initialize MCP server');
        MCPLogger.error('   - Error code: ${response.error?.code}');
        MCPLogger.error('   - Error message: ${response.error?.message}');
        MCPLogger.error('   - Response data: ${response.result}');
        return false;
      }
    } catch (e, stackTrace) {
      MCPLogger.error('❌ Exception during MCP server initialization');
      MCPLogger.error('   - Exception type: ${e.runtimeType}');
      MCPLogger.error('   - Exception message: $e');
      if (e is DioException) {
        MCPLogger.error('   - HTTP Status: ${e.response?.statusCode}');
        MCPLogger.error('   - HTTP Message: ${e.message}');
        MCPLogger.error('   - Response data: ${e.response?.data}');
      }
      MCPLogger.error('   - Stack trace: $stackTrace');
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
      return HealthDataFunctions.getAllFunctions();
    } catch (e) {
      MCPLogger.error('Error getting available tools', error: e);
      return HealthDataFunctions.getAllFunctions();
    }
  }

  /// Get step summary for a date range
  Future<StepAnalytics?> getStepSummary({
    String? startDate,
    String? endDate,
    int? lastNDays,
  }) async {
    MCPLogger.info('🔄 Getting step summary...');

    if (_userId == null) {
      MCPLogger.error('❌ User ID is required for step analytics');
      return null;
    }

    MCPLogger.info('   - User ID: $_userId');
    MCPLogger.info('   - Start Date: $startDate');
    MCPLogger.info('   - End Date: $endDate');
    MCPLogger.info('   - Last N Days: $lastNDays');

    try {
      final args = OpenAIHelpers.createStepSummaryArgs(
        userId: _userId,
        startDate: startDate,
        endDate: endDate,
        lastNDays: lastNDays,
      );

      MCPLogger.info('📋 Created function args: $args');

      final message = MCPMessage(
        method: 'tools/call',
        params: {'name': 'get_step_summary', 'arguments': args},
      );

      MCPLogger.logAPICall('get_step_summary', args);
      final response = await _sendMCPRequest(message);

      if (response.isSuccess && response.result != null) {
        MCPLogger.logResponse('get_step_summary', true);
        MCPLogger.info('✅ Real MCP data received for step summary');
        MCPLogger.info('   - Response result: ${response.result}');
        // TODO: Parse actual step analytics from server response
        return null; // Return null until real parsing is implemented
      } else {
        MCPLogger.logResponse(
          'get_step_summary',
          false,
          errorMessage: response.error?.message,
        );
        MCPLogger.error('❌ MCP server failed to provide step summary');
        MCPLogger.error('   - Error code: ${response.error?.code}');
        MCPLogger.error('   - Error message: ${response.error?.message}');
        MCPLogger.error('   - Response data: ${response.result}');
        return null;
      }
    } catch (e, stackTrace) {
      MCPLogger.error('❌ Exception getting step summary');
      MCPLogger.error('   - Exception type: ${e.runtimeType}');
      MCPLogger.error('   - Exception message: $e');
      MCPLogger.error('   - Stack trace: $stackTrace');
      return null;
    }
  }

  /// Get activity patterns
  Future<ActivityPatterns?> getActivityPatterns({int days = 30}) async {
    MCPLogger.info('🔄 Getting activity patterns...');

    if (_userId == null) {
      MCPLogger.error('❌ User ID is required for activity patterns');
      return null;
    }

    MCPLogger.info('   - User ID: $_userId');
    MCPLogger.info('   - Days: $days');

    try {
      final args = OpenAIHelpers.createActivityPatternsArgs(
        userId: _userId,
        days: days,
      );

      MCPLogger.info('📋 Created function args: $args');

      final message = MCPMessage(
        method: 'tools/call',
        params: {'name': 'get_activity_patterns', 'arguments': args},
      );

      MCPLogger.logAPICall('get_activity_patterns', args);
      final response = await _sendMCPRequest(message);

      if (response.isSuccess && response.result != null) {
        MCPLogger.logResponse('get_activity_patterns', true);
        MCPLogger.info('✅ Real MCP data received for activity patterns');
        MCPLogger.info('   - Response result: ${response.result}');
        // TODO: Parse actual activity patterns from server response
        return null; // Return null until real parsing is implemented
      } else {
        MCPLogger.logResponse(
          'get_activity_patterns',
          false,
          errorMessage: response.error?.message,
        );
        MCPLogger.error('❌ MCP server failed to provide activity patterns');
        MCPLogger.error('   - Error code: ${response.error?.code}');
        MCPLogger.error('   - Error message: ${response.error?.message}');
        MCPLogger.error('   - Response data: ${response.result}');
        return null;
      }
    } catch (e, stackTrace) {
      MCPLogger.error('❌ Exception getting activity patterns');
      MCPLogger.error('   - Exception type: ${e.runtimeType}');
      MCPLogger.error('   - Exception message: $e');
      MCPLogger.error('   - Stack trace: $stackTrace');
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
    MCPLogger.info('🔄 Sending MCP request: ${message.method}');
    MCPLogger.debug('   - Message: ${jsonEncode(message.toJson())}');

    return await retry(
      () async {
        try {
          MCPLogger.info(
            '📤 Making HTTP POST request to: ${OpenAIConfig.mcpEndpoint}',
          );

          final requestData = jsonEncode(message.toJson());
          final headers = {
            'Authorization': 'Bearer ${EnvConfig.supabaseAnonKey}',
            'X-MCP-Secret': OpenAIConfig.mcpSecret,
          };

          MCPLogger.debug('   - Request headers: ${headers.keys.join(', ')}');
          MCPLogger.debug('   - Request body: $requestData');

          final response = await _dio.post(
            OpenAIConfig.mcpEndpoint,
            data: requestData,
            options: Options(headers: headers),
          );

          MCPLogger.info('📥 Received HTTP response: ${response.statusCode}');
          MCPLogger.debug('   - Response headers: ${response.headers}');
          MCPLogger.debug('   - Response data: ${response.data}');

          if (response.statusCode == 200) {
            final mcpResponse = MCPResponse.fromJson(
              response.data as Map<String, dynamic>,
            );
            MCPLogger.info('✅ Successfully parsed MCP response');
            return mcpResponse;
          } else {
            MCPLogger.error('❌ HTTP error: ${response.statusCode}');
            throw DioException(
              requestOptions: response.requestOptions,
              response: response,
              message: 'HTTP ${response.statusCode}',
            );
          }
        } catch (e) {
          MCPLogger.error('❌ Exception in HTTP request');
          MCPLogger.error('   - Exception type: ${e.runtimeType}');
          MCPLogger.error('   - Exception message: $e');

          if (e is DioException) {
            MCPLogger.error('   - DioException type: ${e.type}');
            MCPLogger.error('   - HTTP Status: ${e.response?.statusCode}');
            MCPLogger.error('   - HTTP Message: ${e.message}');
            MCPLogger.error('   - Response data: ${e.response?.data}');
            MCPLogger.error('   - Request URL: ${e.requestOptions.uri}');
            MCPLogger.error(
              '   - Request headers: ${e.requestOptions.headers}',
            );
          }

          rethrow;
        }
      },
      retryIf: (e) {
        final shouldRetry = e is DioException && e.response?.statusCode != 401;
        MCPLogger.info('🔄 Retry decision: $shouldRetry (${e.runtimeType})');
        return shouldRetry;
      },
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

  /// Call MCP function directly and return text response for OpenAI
  Future<String> callMCPFunctionForOpenAI(
    String functionName,
    Map<String, dynamic> args,
  ) async {
    if (_userId == null) {
      return 'ERROR: User ID is required for MCP functions';
    }

    // Resolve userId if it's an email or other identifier
    final resolvedUserId = await _resolveUserId(args['userId']);
    if (resolvedUserId == null) {
      return 'ERROR: Could not resolve user ID from provided identifier: ${args['userId']}';
    }

    // Update args with resolved UUID
    final resolvedArgs = Map<String, dynamic>.from(args);
    resolvedArgs['userId'] = resolvedUserId;

    try {
      final message = MCPMessage(
        method: 'tools/call',
        params: {'name': functionName, 'arguments': resolvedArgs},
      );

      MCPLogger.info('🔄 Calling MCP function for OpenAI: $functionName');
      MCPLogger.info('   - Original Args: $args');
      MCPLogger.info('   - Resolved Args: $resolvedArgs');

      final response = await _sendMCPRequest(message);

      if (response.isSuccess && response.result != null) {
        MCPLogger.info('✅ MCP function call successful');

        // Extract the text content from MCP response
        final result = response.result as Map<String, dynamic>;
        if (result['content'] != null && result['content'] is List) {
          final contentList = result['content'] as List;
          if (contentList.isNotEmpty && contentList[0]['text'] != null) {
            final textResponse = contentList[0]['text'] as String;
            MCPLogger.info('✅ Extracted MCP text response for OpenAI');
            return textResponse;
          }
        }
        return 'MCP function executed but could not extract text content';
      } else {
        MCPLogger.error('❌ MCP function call failed');
        MCPLogger.error('   - Error: ${response.error?.message}');
        return 'ERROR: MCP function call failed: ${response.error?.message ?? "Unknown error"}';
      }
    } catch (e, stackTrace) {
      MCPLogger.error('❌ Exception calling MCP function');
      MCPLogger.error('   - Exception: $e');
      MCPLogger.error('   - Stack trace: $stackTrace');
      return 'ERROR: Exception calling MCP function: $e';
    }
  }

  /// Resolve user ID from various identifiers (UUID, email, etc.)
  Future<String?> _resolveUserId(dynamic userIdentifier) async {
    if (userIdentifier == null) {
      return _userId; // Use default user ID
    }

    final identifier = userIdentifier.toString();

    // If it's already a valid UUID format, return it
    if (_isValidUuid(identifier)) {
      MCPLogger.info('✅ User identifier is already a valid UUID: $identifier');
      return identifier;
    }

    // If it looks like an email, try to find the user by email
    if (identifier.contains('@')) {
      MCPLogger.info('🔍 Resolving user ID from email: $identifier');
      try {
        final users = await SupabaseService.fetchUsers();
        final user = users.firstWhere(
          (u) => u.email.toLowerCase() == identifier.toLowerCase(),
          orElse: () => throw StateError('User not found'),
        );
        MCPLogger.info('✅ Resolved email $identifier to UUID: ${user.id}');
        return user.id;
      } catch (e) {
        MCPLogger.error('❌ Could not resolve email to user ID: $e');
        return null;
      }
    }

    // If it's a simple string, try to find by name
    if (identifier.isNotEmpty && !identifier.contains(' ')) {
      MCPLogger.info('🔍 Resolving user ID from name fragment: $identifier');
      try {
        final users = await SupabaseService.fetchUsers();
        final user = users.firstWhere(
          (u) =>
              u.friendlyName.toLowerCase().contains(identifier.toLowerCase()) ||
              u.email.toLowerCase().contains(identifier.toLowerCase()),
          orElse: () => throw StateError('User not found'),
        );
        MCPLogger.info(
          '✅ Resolved name fragment $identifier to UUID: ${user.id}',
        );
        return user.id;
      } catch (e) {
        MCPLogger.error('❌ Could not resolve name fragment to user ID: $e');
        return null;
      }
    }

    // If all else fails, use the current user ID
    MCPLogger.warning(
      '⚠️ Could not resolve identifier "$identifier", using current user ID: $_userId',
    );
    return _userId;
  }

  /// Check if a string is a valid UUID format
  bool _isValidUuid(String str) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(str);
  }
}
