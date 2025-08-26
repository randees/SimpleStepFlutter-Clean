import 'dart:developer' as developer;

class MCPLogger {
  static const String _prefix = 'MCP';

  static void info(String message, {String? tag}) {
    final logTag = tag != null ? '$_prefix.$tag' : _prefix;
    developer.log(
      message,
      name: logTag,
      level: 800, // Info level
    );
  }

  static void warning(String message, {String? tag}) {
    final logTag = tag != null ? '$_prefix.$tag' : _prefix;
    developer.log(
      message,
      name: logTag,
      level: 900, // Warning level
    );
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    final logTag = tag != null ? '$_prefix.$tag' : _prefix;
    developer.log(
      message,
      name: logTag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void debug(String message, {String? tag}) {
    final logTag = tag != null ? '$_prefix.$tag' : _prefix;
    developer.log(
      message,
      name: logTag,
      level: 700, // Debug level
    );
  }

  // Specific logging methods for MCP operations
  static void logAPICall(String endpoint, Map<String, dynamic>? params) {
    info(
      'API Call: $endpoint${params != null ? ' with params: $params' : ''}',
      tag: 'API',
    );
  }

  static void logResponse(
    String endpoint,
    bool success, {
    String? errorMessage,
  }) {
    if (success) {
      info('API Response: $endpoint - Success', tag: 'API');
    } else {
      error('API Response: $endpoint - Failed: $errorMessage', tag: 'API');
    }
  }

  static void logStepAnalytics(
    String operation,
    int stepCount, {
    String? additionalInfo,
  }) {
    info(
      'Step Analytics: $operation - $stepCount steps${additionalInfo != null ? ' - $additionalInfo' : ''}',
      tag: 'Analytics',
    );
  }

  static void logOpenAIRequest(String prompt, List<String> functions) {
    info(
      'OpenAI Request: "$prompt" with functions: ${functions.join(', ')}',
      tag: 'OpenAI',
    );
  }

  static void logOpenAIResponse(String response, {bool? functionCalled}) {
    info(
      'OpenAI Response: ${response.length > 100 ? '${response.substring(0, 100)}...' : response}${functionCalled == true ? ' (Function called)' : ''}',
      tag: 'OpenAI',
    );
  }
}
