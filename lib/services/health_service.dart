import 'package:health/health.dart';
import 'dart:io' show Platform;

/// Abstract interface for health data operations (Interface Segregation)
abstract class HealthDataService {
  Future<bool> initialize();
  Future<bool> requestPermissions();
  Future<bool> hasPermissions();
  Future<int> getTodaySteps();
  Future<int> getStepsToday(); // Alias for consistency
  Future<List<HealthStepData>> getStepsForDateRange(
    DateTime start,
    DateTime end,
  );
  Future<void> openHealthSettings();
  String get platformName;
  String get connectionMethod; // New: Track connection method
  bool get isAvailable; // New: Get availability status
}

/// Model for health step data
class HealthStepData {
  final DateTime date;
  final int stepCount;

  HealthStepData({required this.date, required this.stepCount});
}

/// Concrete implementation for Health Connect/HealthKit
class HealthService implements HealthDataService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();
  final List<HealthDataType> _types = [HealthDataType.STEPS];

  // Track connection method and status
  bool _isInitialized = false;
  String _connectionMethod = 'Unknown';
  bool _isAvailable = false;

  @override
  String get platformName => Platform.isIOS ? 'HealthKit' : 'Health Connect';

  /// Get the connection method that was successful
  String get connectionMethod => _connectionMethod;

  /// Get detailed connection status
  bool get isAvailable => _isAvailable;

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return _isAvailable;

    try {
      // Try to determine if health service is available by checking basic functionality
      _connectionMethod = 'Checking availability...';

      // Method 1: Try hasPermissions check
      try {
        bool? hasPerms = await _health.hasPermissions(_types);
        _connectionMethod = 'Basic hasPermissions() check';
        _isAvailable = true;
        _isInitialized = true;
        print(
          '✅ $platformName availability confirmed via hasPermissions() - result: $hasPerms',
        );
        return true;
      } catch (e) {
        print('hasPermissions() check failed: $e');
      }

      // Method 2: Try a basic data query
      try {
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);

        await _health.getHealthDataFromTypes(
          types: _types,
          startTime: startOfDay,
          endTime: now,
        );

        _connectionMethod = 'Direct data query test';
        _isAvailable = true;
        _isInitialized = true;
        print('✅ $platformName availability confirmed via data query test');
        return true;
      } catch (e) {
        print('Data query test failed: $e');
      }

      // If we get here, health service might not be available
      _connectionMethod = 'Service unavailable - no method succeeded';
      _isAvailable = false;
      _isInitialized = true;
      return false;
    } catch (e) {
      print('Error initializing $platformName: $e');
      _connectionMethod = 'Initialization error: $e';
      _isAvailable = false;
      _isInitialized = true;
      return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      bool? hasPermissions = await _health.hasPermissions(_types);
      return hasPermissions ?? false;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      // Try multiple permission request methods and track which one works
      return await _tryMultiplePermissionMethods();
    } catch (e) {
      print('Error requesting permissions: $e');
      _connectionMethod = 'Permission request failed: $e';
      return false;
    }
  }

  Future<bool> _tryMultiplePermissionMethods() async {
    // Method 1: Standard authorization request
    try {
      print('🔄 Trying Method 1: Standard requestAuthorization(READ)');
      bool requested = await _health.requestAuthorization(
        _types,
        permissions: [HealthDataAccess.READ],
      );
      if (requested) {
        _connectionMethod = 'Method 1: Standard requestAuthorization(READ)';
        print('✅ SUCCESS: Method 1 worked!');
        return true;
      }
    } catch (e) {
      print('Method 1 failed: $e');
    }

    // Method 2: Try with different permission setup
    try {
      print('🔄 Trying Method 2: requestAuthorization(READ_WRITE)');
      bool requested = await _health.requestAuthorization(
        _types,
        permissions: [HealthDataAccess.READ_WRITE],
      );
      if (requested) {
        _connectionMethod = 'Method 2: requestAuthorization(READ_WRITE)';
        print('✅ SUCCESS: Method 2 worked!');
        return true;
      }
    } catch (e) {
      print('Method 2 failed: $e');
    }

    // Method 3: Try direct data access to trigger permission dialog
    try {
      print('🔄 Trying Method 3: Direct data access trigger');
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      List<HealthDataPoint> testData = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: startOfDay,
        endTime: now,
      );

      _connectionMethod =
          'Method 3: Direct data access trigger (${testData.length} points)';
      print(
        '✅ SUCCESS: Method 3 worked - found ${testData.length} data points',
      );
      return true;
    } catch (e) {
      print('Method 3 failed: $e');
    }

    _connectionMethod = 'All permission methods failed';
    print('❌ All permission methods failed');
    return false;
  }

  @override
  Future<int> getTodaySteps() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: startOfDay,
        endTime: endOfDay,
      );

      int totalSteps = 0;
      for (var data in healthData) {
        if (data.type == HealthDataType.STEPS) {
          int stepValue = (data.value as NumericHealthValue).numericValue
              .toInt();
          totalSteps += stepValue;
        }
      }

      return totalSteps;
    } catch (e) {
      print('Error fetching today\'s steps: $e');
      return 0;
    }
  }

  @override
  Future<int> getStepsToday() async {
    return await getTodaySteps(); // Alias method
  }

  @override
  Future<void> openHealthSettings() async {
    // Note: The health plugin doesn't provide a direct method to open settings
    // This would need platform-specific implementation
    print('Opening health settings - feature not available in health plugin');

    // For future implementation, we could use url_launcher or app_settings
    // to open specific health settings pages
  }

  @override
  Future<List<HealthStepData>> getStepsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    List<HealthStepData> results = [];

    DateTime currentDate = start;
    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      try {
        final startOfDay = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );
        final endOfDay = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          23,
          59,
          59,
        );

        List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
          types: _types,
          startTime: startOfDay,
          endTime: endOfDay,
        );

        int dailySteps = 0;
        for (var data in healthData) {
          if (data.type == HealthDataType.STEPS) {
            int stepValue = (data.value as NumericHealthValue).numericValue
                .toInt();
            dailySteps += stepValue;
          }
        }

        results.add(HealthStepData(date: currentDate, stepCount: dailySteps));
      } catch (e) {
        print('Error processing date $currentDate: $e');
        results.add(HealthStepData(date: currentDate, stepCount: 0));
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return results;
  }
}
