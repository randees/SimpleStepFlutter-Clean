import 'env_config.dart';

/// OpenAI Configuration using environment variables
/// All sensitive data is loaded from .env file for security
class OpenAIConfig {
  static const String baseUrl = 'https://api.openai.com/v1';
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Get OpenAI API key from environment
  static String get apiKey => EnvConfig.openaiApiKey;

  /// Get MCP endpoint from environment
  static String get mcpEndpoint => EnvConfig.mcpEndpoint;

  /// Get MCP secret from environment
  static String get mcpSecret => EnvConfig.mcpSecret;

  /// Check if OpenAI is properly configured
  static bool get isConfigured => EnvConfig.isOpenAIConfigured;

  /// Check if MCP is properly configured
  static bool get isMCPConfigured => EnvConfig.isMCPConfigured;

  // Default model configurations
  static const String defaultModel = 'gpt-4';
  static const double defaultTemperature = 0.7;
  static const int defaultMaxTokens = 1000;

  /// Get configuration summary for debugging (with masked secrets)
  static Map<String, String> getConfigSummary() {
    return {
      'api_key': apiKey.isNotEmpty
          ? EnvConfig.getMaskedApiKey(apiKey)
          : 'Not configured',
      'mcp_endpoint': mcpEndpoint.isNotEmpty
          ? '${mcpEndpoint.substring(0, 30)}...'
          : 'Not configured',
      'mcp_secret': mcpSecret.isNotEmpty
          ? EnvConfig.getMaskedApiKey(mcpSecret)
          : 'Not configured',
      'openai_configured': isConfigured.toString(),
      'mcp_configured': isMCPConfigured.toString(),
    };
  }

  /// Validate if API key has correct format
  static bool get hasValidApiKeyFormat => EnvConfig.isValidApiKeyFormat(apiKey);
}
