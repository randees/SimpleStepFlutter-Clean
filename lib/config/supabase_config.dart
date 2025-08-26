import 'env_config.dart';

/// Supabase Configuration using environment variables
/// All sensitive data is loaded from .env file for security
class SupabaseConfig {
  /// Supabase project URL from environment
  static String get supabaseUrl => EnvConfig.supabaseUrl;

  /// Supabase anon key from environment
  static String get supabaseAnonKey => EnvConfig.supabaseAnonKey;

  /// Supabase service role key from environment (for server operations)
  static String get supabaseServiceRoleKey => EnvConfig.supabaseServiceRoleKey;

  /// Check if configuration is available
  static bool get isConfigured => EnvConfig.isSupabaseConfigured;

  /// Get configuration summary for debugging (with masked keys)
  static Map<String, String> getConfigSummary() {
    return {
      'url': supabaseUrl.isNotEmpty
          ? '${supabaseUrl.substring(0, 30)}...'
          : 'Not configured',
      'anon_key': supabaseAnonKey.isNotEmpty
          ? EnvConfig.getMaskedApiKey(supabaseAnonKey)
          : 'Not configured',
      'service_key': supabaseServiceRoleKey.isNotEmpty
          ? EnvConfig.getMaskedApiKey(supabaseServiceRoleKey)
          : 'Not configured',
      'configured': isConfigured.toString(),
    };
  }
}
