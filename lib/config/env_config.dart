import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Secure configuration manager that loads API keys and secrets from environment variables
/// This ensures sensitive data is never committed to version control
class EnvConfig {
  static bool _isInitialized = false;

  /// Initialize environment configuration
  /// Must be called before accessing any configuration values
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load environment variables from .env file
      await dotenv.load(fileName: ".env");
      _isInitialized = true;
      print('✅ Environment configuration loaded successfully');
    } catch (e) {
      print('⚠️ Warning: Could not load .env file: $e');
      print('⚠️ Using default/fallback configuration');
      _isInitialized = true; // Continue with defaults
    }
  }

  /// Get environment variable with optional fallback
  static String _getEnv(String key, {String? fallback}) {
    if (!_isInitialized) {
      throw Exception(
        'EnvConfig not initialized. Call EnvConfig.initialize() first.',
      );
    }
    return dotenv.env[key] ?? fallback ?? '';
  }

  /// Check if running in development mode
  static bool get isDevelopment =>
      _getEnv('FLUTTER_ENV', fallback: 'production') == 'development';

  /// Check if debug mode is enabled
  static bool get debugMode =>
      _getEnv('DEBUG_MODE', fallback: 'false').toLowerCase() == 'true';

  // Supabase Configuration
  static String get supabaseUrl => _getEnv('SUPABASE_URL');
  static String get supabaseAnonKey => _getEnv('SUPABASE_ANON_KEY');
  static String get supabaseServiceRoleKey =>
      _getEnv('SUPABASE_SERVICE_ROLE_KEY');

  /// Check if Supabase is properly configured
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  // OpenAI Configuration
  static String get openaiApiKey => _getEnv('OPENAI_API_KEY');

  /// Check if OpenAI is properly configured
  static bool get isOpenAIConfigured =>
      openaiApiKey.isNotEmpty &&
      openaiApiKey != 'REPLACE_WITH_YOUR_OPENAI_API_KEY';

  // MCP Configuration
  static String get mcpEndpoint => _getEnv('MCP_ENDPOINT');
  static String get mcpSecret => _getEnv('MCP_SECRET');

  /// Check if MCP is properly configured
  static bool get isMCPConfigured =>
      mcpEndpoint.isNotEmpty && mcpSecret.isNotEmpty;

  // Security helpers

  /// Get masked version of API key for logging (shows only first/last 4 characters)
  static String getMaskedApiKey(String apiKey) {
    if (apiKey.length <= 8) return '***';
    return '${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}';
  }

  /// Validate API key format (basic validation)
  static bool isValidApiKeyFormat(String apiKey, {String prefix = 'sk-'}) {
    return apiKey.isNotEmpty &&
        apiKey.startsWith(prefix) &&
        apiKey.length > prefix.length + 10;
  }

  /// Get configuration summary for debugging (with masked secrets)
  static Map<String, dynamic> getConfigSummary() {
    return {
      'environment': isDevelopment ? 'development' : 'production',
      'debug_mode': debugMode,
      'supabase_configured': isSupabaseConfigured,
      'supabase_url': supabaseUrl.isNotEmpty
          ? '${supabaseUrl.substring(0, 20)}...'
          : 'Not set',
      'openai_configured': isOpenAIConfigured,
      'openai_api_key': openaiApiKey.isNotEmpty
          ? getMaskedApiKey(openaiApiKey)
          : 'Not set',
      'mcp_configured': isMCPConfigured,
      'mcp_endpoint': mcpEndpoint.isNotEmpty
          ? '${mcpEndpoint.substring(0, 30)}...'
          : 'Not set',
    };
  }
}
