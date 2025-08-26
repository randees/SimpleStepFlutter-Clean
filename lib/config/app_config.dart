/// Application configuration settings
class AppConfig {
  /// Set to false to completely disable any mock/temporary data creation
  /// When false, the app will only use real data from database/health services
  static const bool enableMockData = false;

  /// Enable debug mode for additional logging
  static const bool debugMode = true;

  /// Default to health services disabled to avoid permission issues
  static const bool defaultHealthServicesEnabled = false;
}
