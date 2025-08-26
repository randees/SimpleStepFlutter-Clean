import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase client not initialized. Call initialize() first.',
      );
    }
    return _client!;
  }

  /// Initialize Supabase client
  static Future<void> initialize() async {
    print('SupabaseService: Starting initialization...');
    print('SupabaseService: Using URL: ${SupabaseConfig.supabaseUrl}');

    try {
      // Always create a fresh client to avoid singleton caching issues
      _client = SupabaseClient(
        SupabaseConfig.supabaseUrl,
        SupabaseConfig.supabaseAnonKey,
      );
      print(
        'SupabaseService: Direct client initialization completed successfully',
      );
    } catch (e) {
      print('SupabaseService: Direct client initialization error: $e');

      // Fallback to singleton if direct client fails
      try {
        await Supabase.initialize(
          url: SupabaseConfig.supabaseUrl,
          anonKey: SupabaseConfig.supabaseAnonKey,
        );
        _client = Supabase.instance.client;
        print(
          'SupabaseService: Fallback initialization completed successfully',
        );
      } catch (e2) {
        if (e2.toString().contains('This instance is already initialized')) {
          _client = Supabase.instance.client;
          print('SupabaseService: Using existing Supabase instance');
        } else {
          rethrow;
        }
      }
    }
  }

  /// Force re-initialization (for configuration changes)
  static Future<void> forceReinitialize() async {
    print('SupabaseService: Force re-initializing...');
    _client = null;
    await initialize();
  }

  /// Fetch all users from the database
  static Future<List<UserModel>> fetchUsers() async {
    try {
      print('🔄 SupabaseService: Fetching users from database...');
      print(
        '🔄 SupabaseService: Using Supabase URL: ${SupabaseConfig.supabaseUrl}',
      );

      final response = await client.from('users').select('*');

      print('📊 SupabaseService: Database response: $response');
      final users = response
          .map((userData) => UserModel.fromJson(userData))
          .toList();
      print('✅ SupabaseService: Converted ${users.length} users successfully');
      return users;
    } catch (e) {
      print('❌ SupabaseService: Error fetching users: $e');
      return [];
    }
  }

  /// Fetch step count for a specific user from activity_data table
  static Future<int> fetchUserStepCount(String userId, {DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final startOfDay = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(microseconds: 1));

      final response = await client
          .from('activity_data')
          .select('steps')
          .eq('user_id', userId)
          .eq('activity_type', 'steps')
          .gte('start_time', startOfDay.toIso8601String())
          .lte('end_time', endOfDay.toIso8601String())
          .order('start_time')
          .limit(1)
          .maybeSingle();

      if (response != null && response['steps'] != null) {
        return response['steps'] as int;
      }

      // If no data found, return 0 (no mock/fallback data)
      return 0; // No fallback data
    } catch (e) {
      print('Error fetching user step count: $e');
      return 0; // No fallback data
    }
  }

  /// Check if activity data exists for a specific date and user
  static Future<bool> activityDataExists(
    String userId,
    DateTime date,
    String activityType,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(microseconds: 1));

      final response = await client
          .from('activity_data')
          .select('id')
          .eq('user_id', userId)
          .eq('activity_type', activityType)
          .gte('start_time', startOfDay.toIso8601String())
          .lte('end_time', endOfDay.toIso8601String())
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking if activity data exists: $e');
      return false;
    }
  }

  /// Insert activity data for a specific user and date
  static Future<bool> insertActivityData({
    required String userId,
    required DateTime date,
    required int stepCount,
    required String platform,
  }) async {
    try {
      // Check if data already exists
      if (await activityDataExists(userId, date, 'steps')) {
        print(
          'Activity data for ${DateFormat('yyyy-MM-dd').format(date)} already exists, skipping...',
        );
        return true; // Return true since data exists (not an error)
      }

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      await client.from('activity_data').insert({
        'user_id': userId,
        'data_source': platform,
        'activity_type': 'steps',
        'start_time': startOfDay.toIso8601String(),
        'end_time': endOfDay.toIso8601String(),
        'steps': stepCount,
      });

      print(
        'Successfully inserted activity data for ${DateFormat('yyyy-MM-dd').format(date)}: $stepCount steps',
      );
      return true;
    } catch (e) {
      print('Error inserting activity data: $e');
      return false;
    }
  }

  /// Insert multiple activity data entries (requires userId)
  static Future<int> insertMultipleActivityData(
    String userId,
    List<StepDataEntry> entries,
  ) async {
    int successCount = 0;

    for (final entry in entries) {
      final success = await insertActivityData(
        userId: userId,
        date: entry.date,
        stepCount: entry.stepCount,
        platform: entry.platform,
      );

      if (success) {
        successCount++;
      }
    }

    return successCount;
  }

  /// Get activity data for a date range for a specific user
  static Future<List<StepDataEntry>> getActivityDataRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final endDateTime = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );

      final response = await client
          .from('activity_data')
          .select('start_time, steps, data_source, created_at')
          .eq('user_id', userId)
          .eq('activity_type', 'steps')
          .gte('start_time', startDateTime.toIso8601String())
          .lte('start_time', endDateTime.toIso8601String())
          .order('start_time');

      return response
          .map<StepDataEntry>((item) => StepDataEntry.fromActivityData(item))
          .toList();
    } catch (e) {
      print('Error getting activity data range: $e');
      return [];
    }
  }

  /// Get total step count for a date range for a specific user
  static Future<int> getTotalStepsInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final entries = await getActivityDataRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return entries.fold<int>(0, (total, entry) => total + entry.stepCount);
    } catch (e) {
      print('Error getting total steps in range: $e');
      return 0;
    }
  }

  /// Delete old activity data (older than specified days)
  static Future<bool> cleanupOldActivityData(int daysToKeep) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      await client
          .from('activity_data')
          .delete()
          .lt('start_time', cutoffDate.toIso8601String());

      print(
        'Successfully cleaned up activity data older than $daysToKeep days',
      );
      return true;
    } catch (e) {
      print('Error cleaning up old activity data: $e');
      return false;
    }
  }

  /// Test database connection
  static Future<bool> testConnection() async {
    try {
      // Try to read one record to test connection using activity_data table
      await client.from('activity_data').select('id').limit(1);

      return true;
    } catch (e) {
      print('Database connection test failed: $e');
      return false;
    }
  }
}

/// Data model for step entries
class StepDataEntry {
  final DateTime date;
  final int stepCount;
  final String platform;
  final DateTime? createdAt;

  StepDataEntry({
    required this.date,
    required this.stepCount,
    required this.platform,
    this.createdAt,
  });

  factory StepDataEntry.fromMap(Map<String, dynamic> map) {
    return StepDataEntry(
      date: DateTime.parse(map['date']),
      stepCount: map['step_count'] ?? 0,
      platform: map['platform'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  factory StepDataEntry.fromActivityData(Map<String, dynamic> map) {
    return StepDataEntry(
      date: DateTime.parse(map['start_time']).toLocal(),
      stepCount: map['steps'] ?? 0,
      platform: map['data_source'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': DateFormat('yyyy-MM-dd').format(date),
      'step_count': stepCount,
      'platform': platform,
    };
  }

  @override
  String toString() {
    return 'StepDataEntry(date: ${DateFormat('yyyy-MM-dd').format(date)}, steps: $stepCount, platform: $platform)';
  }
}
