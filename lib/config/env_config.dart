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
      // For web deployment, try dart-define values first (from --dart-define-from-file)
      if (kIsWeb) {
        print('🌐 Web platform detected, checking for dart-define values...');

        // Check if we have dart-define values (from --dart-define-from-file)
        if (_hasDartDefineValues()) {
          print('✅ Using dart-define environment variables');
          _isInitialized = true;
          return;
        }

        // Fallback to server API for production
        print('🌐 No dart-define values found, fetching from server...');
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

  /// Check if dart-define values are available (from --dart-define-from-file)
  static bool _hasDartDefineValues() {
    try {
      print('🔍 Checking all dart-define environment variables...');

      final supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
      final supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
      final openaiKey = const String.fromEnvironment('OPENAI_API_KEY');
      final mcpEndpoint = const String.fromEnvironment('MCP_ENDPOINT');
      final mcpSecret = const String.fromEnvironment('MCP_SECRET');
      final flutterEnv = const String.fromEnvironment('FLUTTER_ENV');
      final debugMode = const String.fromEnvironment('DEBUG_MODE');

      print('🔍 dart-define environment variable check:');
      print(
        '  SUPABASE_URL: ${supabaseUrl.isNotEmpty ? "✅ Set (${supabaseUrl.length} chars)" : "❌ Empty"}',
      );
      print(
        '  SUPABASE_ANON_KEY: ${supabaseAnonKey.isNotEmpty ? "✅ Set (${supabaseAnonKey.length} chars)" : "❌ Empty"}',
      );
      print(
        '  OPENAI_API_KEY: ${openaiKey.isNotEmpty ? "✅ Set (${openaiKey.length} chars)" : "❌ Empty"}',
      );
      print(
        '  MCP_ENDPOINT: ${mcpEndpoint.isNotEmpty ? "✅ Set (${mcpEndpoint.length} chars)" : "❌ Empty"}',
      );
      print(
        '  MCP_SECRET: ${mcpSecret.isNotEmpty ? "✅ Set (${mcpSecret.length} chars)" : "❌ Empty"}',
      );
      print(
        '  FLUTTER_ENV: ${flutterEnv.isNotEmpty ? "✅ Set ($flutterEnv)" : "❌ Empty"}',
      );
      print(
        '  DEBUG_MODE: ${debugMode.isNotEmpty ? "✅ Set ($debugMode)" : "❌ Empty"}',
      );

      if (supabaseUrl.isNotEmpty || openaiKey.isNotEmpty) {
        print(
          '✅ dart-define values detected - using direct environment loading',
        );
        return true;
      }

      print('❌ No dart-define values found');
      return false;
    } catch (e) {
      print('⚠️ Error checking dart-define values: $e');
      return false;
    }
  }

  /// Get dart-define value for a specific key
  static String _getDartDefineValue(String key) {
    switch (key) {
      case 'SUPABASE_URL':
        return const String.fromEnvironment('SUPABASE_URL');
      case 'SUPABASE_ANON_KEY':
        return const String.fromEnvironment('SUPABASE_ANON_KEY');
      case 'OPENAI_API_KEY':
        return const String.fromEnvironment('OPENAI_API_KEY');
      case 'MCP_ENDPOINT':
        return const String.fromEnvironment('MCP_ENDPOINT');
      case 'MCP_SECRET':
        return const String.fromEnvironment('MCP_SECRET');
      case 'FLUTTER_ENV':
        return const String.fromEnvironment('FLUTTER_ENV');
      case 'DEBUG_MODE':
        return const String.fromEnvironment('DEBUG_MODE');
      default:
        return const String.fromEnvironment('');
    }
  }

  /// Load configuration from server API (web platform only)
  static Future<void> _loadWebConfig() async {
    try {
      // Use localhost:3000 for debug mode, relative path for production
      final configUrl = kDebugMode
          ? 'http://localhost:3000/api/config'
          : '/api/config';

      print('🌐 Making request to $configUrl...');
      final response = await http.get(Uri.parse(configUrl));

      print('🌐 Server response status: ${response.statusCode}');
      print('🌐 Server response body: ${response.body}');

      if (response.statusCode == 200) {
        _webConfig = json.decode(response.body);
        print(
          '✅ Loaded configuration from server: ${_webConfig?.keys.join(', ')}',
        );
        print('🔍 Config values:');
        _webConfig?.forEach((key, value) {
          if (key.toLowerCase().contains('key') ||
              key.toLowerCase().contains('secret')) {
            print(
              '  $key: ${value.toString().length > 0 ? "[MASKED ${value.toString().length} chars]" : "[EMPTY]"}',
            );
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

    // For web, try dart-define values first, then server config
    if (kIsWeb) {
      // First try dart-define values (from --dart-define-from-file)
      final dartDefineValue = _getDartDefineValue(key);
      if (dartDefineValue.isNotEmpty) {
        print(
          '🔍 _getEnv($key) -> ${dartDefineValue.length > 20 ? "[MASKED ${dartDefineValue.length} chars]" : dartDefineValue} (from dart-define)',
        );
        return dartDefineValue;
      }

      // Fallback to server-provided configuration
      if (_webConfig == null) {
        print('🔍 _getEnv($key) -> [EMPTY]');
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
        case 'OPENAI_API_KEY':
          value = _webConfig!['openaiApiKey']?.toString();
          break;
        case 'MCP_ENDPOINT':
          value = _webConfig!['mcpEndpoint']?.toString();
          break;
        case 'MCP_SECRET':
          value = _webConfig!['mcpSecret']?.toString();
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
      print(
        '🔍 _getEnv($key) -> ${result.isEmpty ? "[EMPTY]" : (key.toLowerCase().contains("key") ? "[MASKED ${result.length} chars]" : result)}',
      );
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
