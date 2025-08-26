import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Secure configuration manager that loads API keys and secrets from environment variables
/// This ensures sensitive data is never committed to version control
class EnvConfig {
  static bool _isInitialized = false;
  static Map<String, dynamic>? _webConfig;

  /// Initialize environment configuration
  /// Must be called before accessing any configuration values
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // For web deployment, fetch configuration from server API
      if (kIsWeb) {
        print(
          '🌐 Web platform detected, fetching configuration from server...',
        );
        await _loadWebConfig();
        _isInitialized = true;
        print('✅ Web configuration loaded successfully from server');
        return;
      }

      // Load environment variables from .env file (for local development)
      await dotenv.load(fileName: ".env");
      _isInitialized = true;
      print('✅ Environment configuration loaded successfully from .env file');
    } catch (e) {
      print('⚠️ Warning: Could not load configuration: $e');
      print('⚠️ Using fallback configuration...');
      _isInitialized = true; // Continue with fallbacks
    }
  }

  /// Load configuration from server API (web platform only)
  static Future<void> _loadWebConfig() async {
    try {
      print('🌐 Making request to /api/config...');
      final response = await http.get(Uri.parse('/api/config'));
      
      print('🌐 Server response status: ${response.statusCode}');
      print('🌐 Server response body: ${response.body}');
      
      if (response.statusCode == 200) {
        _webConfig = json.decode(response.body);
        print(
          '✅ Loaded configuration from server: ${_webConfig?.keys.join(', ')}',
        );
        print('🔍 Config values:');
        _webConfig?.forEach((key, value) {
          if (key.toLowerCase().contains('key') || key.toLowerCase().contains('secret')) {
            print('  $key: ${value.toString().length > 0 ? "[MASKED ${value.toString().length} chars]" : "[EMPTY]"}');
          } else {
            print('  $key: $value');
          }
        });
      } else {
        print('⚠️ Failed to load config from server: ${response.statusCode}');
        print('⚠️ Response body: ${response.body}');
        _webConfig = {}; // Empty config as fallback
      }
    } catch (e) {
      print('⚠️ Error loading web config: $e');
      _webConfig = {}; // Empty config as fallback
    }
  }

  /// Get environment variable with optional fallback
  static String _getEnv(String key, {String? fallback}) {
    if (!_isInitialized) {
      throw Exception(
        'EnvConfig not initialized. Call EnvConfig.initialize() first.',
      );
    }

    // For web, use server-provided configuration
    if (kIsWeb) {
      if (_webConfig == null) {
        print('⚠️ Web config is null for key: $key');
        return fallback ?? '';
      }
      
      // Map API keys to expected environment variable names
      String? value;
      switch (key) {
        case 'SUPABASE_URL':
          value = _webConfig!['supabaseUrl']?.toString();
          break;
        case 'SUPABASE_ANON_KEY':
          value = _webConfig!['supabaseAnonKey']?.toString();
          break;
        case 'FLUTTER_ENV':
          value = _webConfig!['environment']?.toString();
          break;
        case 'DEBUG_MODE':
          value = _webConfig!['debugMode']?.toString();
          break;
        default:
          value = null;
      }
      
      final result = value ?? fallback ?? '';
      print('🔍 _getEnv($key) -> ${result.isEmpty ? "[EMPTY]" : (key.toLowerCase().contains("key") ? "[MASKED ${result.length} chars]" : result)}');
      return result;
    }

    // For other platforms, use dotenv or provided fallback
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

  // OpenAI Configuration (Note: Not exposed to web for security)
  static String get openaiApiKey => kIsWeb ? '' : _getEnv('OPENAI_API_KEY');

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
      'platform': kIsWeb ? 'web' : 'native',
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
