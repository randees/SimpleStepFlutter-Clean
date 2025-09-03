import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static SupabaseClient? _adminClient;

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase client not initialized. Call initialize() first.',
      );
    }
    return _client!;
  }

  static SupabaseClient get adminClient {
    if (_adminClient == null) {
      throw Exception(
        'Supabase admin client not initialized. Call initialize() first.',
      );
    }
    return _adminClient!;
  }

  /// Initialize Supabase client
  static Future<void> initialize() async {
    print('SupabaseService: Starting initialization...');
    print('SupabaseService: Using URL: ${SupabaseConfig.supabaseUrl}');

    // Debug configuration
    final configSummary = SupabaseConfig.getConfigSummary();
    print('🔍 Supabase Config Summary:');
    configSummary.forEach((key, value) {
      print('  $key: $value');
    });

    try {
      // Always create fresh clients to avoid singleton caching issues

      // Regular client with anon key for normal operations
      _client = SupabaseClient(
        SupabaseConfig.supabaseUrl,
        SupabaseConfig.supabaseAnonKey,
      );

      // Admin client with service role key for admin operations (bypasses RLS)
      final serviceRoleKey = SupabaseConfig.supabaseServiceRoleKey;
      print(
        '🔐 Service role key for admin client: ${serviceRoleKey.isNotEmpty ? "✅ ${serviceRoleKey.length} chars" : "❌ Empty"}',
      );

      if (serviceRoleKey.isEmpty) {
        throw Exception(
          'Service role key not configured. Check your .env file for SUPABASE_SERVICE_ROLE_KEY.',
        );
      }

      _adminClient = SupabaseClient(SupabaseConfig.supabaseUrl, serviceRoleKey);

      print('🔐 Admin client initialized successfully with service role key');
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

        // Still create admin client separately
        _adminClient = SupabaseClient(
          SupabaseConfig.supabaseUrl,
          SupabaseConfig.supabaseServiceRoleKey,
        );

        print(
          'SupabaseService: Fallback initialization completed successfully',
        );
      } catch (e2) {
        if (e2.toString().contains('This instance is already initialized')) {
          _client = Supabase.instance.client;

          // Still create admin client separately
          _adminClient = SupabaseClient(
            SupabaseConfig.supabaseUrl,
            SupabaseConfig.supabaseServiceRoleKey,
          );

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
    _adminClient = null;
    await initialize();
  }

  /// Generate a UUID v4 string
  static String _generateUuid() {
    // Simple UUID v4 implementation
    final Random random = Random();
    final List<int> bytes = List<int>.generate(16, (i) => random.nextInt(256));

    // Set version (4) and variant bits
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    // Format as UUID string
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
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

  /// Export all user data including profile and activity data
  static Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      print('🔄 Exporting comprehensive data for user: $userId');

      // Get user profile
      final userResponse = await client
          .from('users')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (userResponse == null) {
        throw Exception('User not found');
      }

      // Get all health data tables for the user
      final activityResponse = await client
          .from('activity_data')
          .select('*')
          .eq('user_id', userId)
          .order('start_time');

      final vitalSignsResponse = await client
          .from('vital_signs')
          .select('*')
          .eq('user_id', userId)
          .order('measured_at');

      final sleepDataResponse = await client
          .from('sleep_data')
          .select('*')
          .eq('user_id', userId)
          .order('sleep_date');

      final nutritionDataResponse = await client
          .from('nutrition_data')
          .select('*')
          .eq('user_id', userId)
          .order('logged_at');

      final bodyMeasurementsResponse = await client
          .from('body_measurements')
          .select('*')
          .eq('user_id', userId)
          .order('measured_at');

      final wellnessDataResponse = await client
          .from('wellness_data')
          .select('*')
          .eq('user_id', userId)
          .order('recorded_at');

      final healthInsightsResponse = await client
          .from('health_insights')
          .select('*')
          .eq('user_id', userId)
          .order('generated_at');

      final recommendationsResponse = await client
          .from('recommendations')
          .select('*')
          .eq('user_id', userId)
          .order('generated_at');

      final dailySummariesResponse = await client
          .from('daily_summaries')
          .select('*')
          .eq('user_id', userId)
          .order('summary_date');

      final userDevicesResponse = await client
          .from('user_devices')
          .select('*')
          .eq('user_id', userId)
          .order('created_at');

      final dataSyncLogResponse = await client
          .from('data_sync_log')
          .select('*')
          .eq('user_id', userId)
          .order('sync_started_at');

      final exportData = {
        'export_metadata': {
          'export_date': DateTime.now().toIso8601String(),
          'app_version': '1.0.0',
          'export_format_version':
              '2.0', // Updated to v2.0 for comprehensive export
          'exported_by': 'SimpleStep Flutter App',
          'total_tables': 11,
          'user_id': userId,
          'device_count': userDevicesResponse.length,
          'total_records':
              activityResponse.length +
              vitalSignsResponse.length +
              sleepDataResponse.length +
              nutritionDataResponse.length +
              bodyMeasurementsResponse.length +
              wellnessDataResponse.length +
              healthInsightsResponse.length +
              recommendationsResponse.length +
              dailySummariesResponse.length +
              userDevicesResponse.length +
              dataSyncLogResponse.length,
        },
        'user_profile': userResponse,
        'user_devices': userDevicesResponse,
        'activity_data': activityResponse,
        'vital_signs': vitalSignsResponse,
        'sleep_data': sleepDataResponse,
        'nutrition_data': nutritionDataResponse,
        'body_measurements': bodyMeasurementsResponse,
        'wellness_data': wellnessDataResponse,
        'health_insights': healthInsightsResponse,
        'recommendations': recommendationsResponse,
        'daily_summaries': dailySummariesResponse,
        'data_sync_log': dataSyncLogResponse,
      };

      // Log export summary
      print('✅ Export Summary for user $userId:');
      print('   - User Profile: 1 record');
      print('   - User Devices: ${userDevicesResponse.length} records');
      print('   - Activity Data: ${activityResponse.length} records');
      print('   - Vital Signs: ${vitalSignsResponse.length} records');
      print('   - Sleep Data: ${sleepDataResponse.length} records');
      print('   - Nutrition Data: ${nutritionDataResponse.length} records');
      print(
        '   - Body Measurements: ${bodyMeasurementsResponse.length} records',
      );
      print('   - Wellness Data: ${wellnessDataResponse.length} records');
      print('   - Health Insights: ${healthInsightsResponse.length} records');
      print('   - Recommendations: ${recommendationsResponse.length} records');
      print('   - Daily Summaries: ${dailySummariesResponse.length} records');
      print('   - Data Sync Log: ${dataSyncLogResponse.length} records');

      print('✅ Successfully exported comprehensive data for user: $userId');
      return exportData;
    } catch (e) {
      print('❌ Error exporting user data: $e');
      rethrow;
    }
  }

  /// Import user data from exported JSON
  static Future<bool> importUserData(Map<String, dynamic> importData) async {
    try {
      print('🔄 Starting comprehensive user data import...');
      print('🔐 Using admin client to bypass RLS policies');

      // Validate import data structure
      if (!importData.containsKey('user_profile')) {
        throw Exception('Invalid import data format: missing user_profile');
      }

      // Log import source information
      if (importData.containsKey('export_metadata')) {
        final metadata = importData['export_metadata'] as Map<String, dynamic>;
        final formatVersion = metadata['export_format_version'] ?? 'unknown';
        final exportedBy = metadata['exported_by'] ?? 'unknown';
        final exportDate = metadata['export_date'] ?? 'unknown';
        print('📋 Import Source Info:');
        print('   - Format Version: $formatVersion');
        print('   - Exported By: $exportedBy');
        print('   - Export Date: $exportDate');
      } else {
        print(
          '⚠️  No export metadata found - this may be test data or an older export format',
        );
      }

      print('🔍 Debug: Checking user_profile structure...');
      final userProfile = importData['user_profile'] as Map<String, dynamic>;
      print('🔍 Debug: user_profile keys: ${userProfile.keys.toList()}');
      print(
        '🔍 Debug: user_profile contains id: ${userProfile.containsKey('id')}',
      );

      // Handle case where user profile doesn't have an ID (clean import)
      String? originalUserId;
      if (userProfile.containsKey('id') && userProfile['id'] != null) {
        originalUserId = userProfile['id'] as String;
        print('🔍 Debug: Found existing user ID: $originalUserId');

        // Check if user already exists (using admin client)
        final existingUser = await adminClient
            .from('users')
            .select('id')
            .eq('id', originalUserId)
            .maybeSingle();

        if (existingUser != null) {
          throw Exception(
            'User with ID $originalUserId already exists. Please delete the existing user first or modify the import data.',
          );
        }
      } else {
        print('🔍 Debug: No user ID found in profile - this is a clean import');
        originalUserId = null;
      }

      print('🔄 Generating UUID mappings for device IDs...');

      // Generate UUID mappings for device IDs
      final Map<String, String> deviceIdMapping = {};

      // First, collect all unique device IDs from the import data
      final Set<String> oldDeviceIds = <String>{};

      try {
        // Check user_devices table for device IDs
        if (importData.containsKey('user_devices')) {
          print('🔍 Debug: Processing user_devices for device IDs...');
          final userDevices = importData['user_devices'] as List<dynamic>;
          print('🔍 Debug: Found ${userDevices.length} user devices');

          for (int i = 0; i < userDevices.length; i++) {
            try {
              final device = userDevices[i];
              print('🔍 Debug: Processing device $i: ${device.runtimeType}');
              final deviceMap = device as Map<String, dynamic>;
              print('🔍 Debug: Device $i keys: ${deviceMap.keys.toList()}');

              if (deviceMap.containsKey('id') && deviceMap['id'] != null) {
                final deviceId = deviceMap['id'].toString();
                oldDeviceIds.add(deviceId);
                print('🔍 Debug: Added device ID from user_devices: $deviceId');
              } else {
                print('🔍 Debug: Device $i has no id field or id is null');
              }
            } catch (e) {
              print('❌ Debug: Error processing device $i: $e');
              rethrow;
            }
          }
        } else {
          print('🔍 Debug: No user_devices found in import data');
        }

        // Check all other tables for device_id references
        final tablesWithDeviceId = [
          'activity_data',
          'vital_signs',
          'sleep_data',
          'nutrition_data',
          'body_measurements',
          'wellness_data',
          'health_insights',
          'recommendations',
          'daily_summaries',
          'data_sync_log',
        ];

        for (final tableName in tablesWithDeviceId) {
          if (importData.containsKey(tableName)) {
            print('🔍 Debug: Checking $tableName for device_id references...');
            final tableData = importData[tableName] as List<dynamic>;
            print('🔍 Debug: $tableName has ${tableData.length} records');

            for (int i = 0; i < tableData.length; i++) {
              try {
                final record = tableData[i];
                final recordMap = record as Map<String, dynamic>;

                if (recordMap.containsKey('device_id') &&
                    recordMap['device_id'] != null) {
                  final deviceId = recordMap['device_id'].toString();
                  oldDeviceIds.add(deviceId);
                  print(
                    '🔍 Debug: Added device_id from $tableName[$i]: $deviceId',
                  );
                }
              } catch (e) {
                print('❌ Debug: Error processing $tableName record $i: $e');
                rethrow;
              }
            }
          } else {
            print('🔍 Debug: Table $tableName not found in import data');
          }
        }
      } catch (e) {
        print('❌ Debug: Error during device ID collection: $e');
        rethrow;
      }

      // Generate new UUIDs for each old device ID
      for (final oldId in oldDeviceIds) {
        // Generate a UUID v4
        final newUuid = _generateUuid();
        deviceIdMapping[oldId] = newUuid;
        print('🔄 Mapping device ID: $oldId → $newUuid');
      }

      print('🔄 Importing user profile...');

      // Generate a new UUID for the user and update the profile
      final newUserId = _generateUuid();
      final updatedUserProfile = Map<String, dynamic>.from(userProfile);
      updatedUserProfile['id'] = newUserId;

      if (originalUserId != null) {
        print('🔄 Generated new user ID: $originalUserId → $newUserId');
      } else {
        print('🔄 Generated new user ID: $newUserId (clean import)');
      }

      // Insert user profile with new UUID (using admin client to bypass RLS)
      await adminClient.from('users').insert(updatedUserProfile);
      print(
        '✅ Imported user profile for: ${updatedUserProfile['email']} with ID: $newUserId',
      );

      // Use the new user ID for all subsequent operations
      final actualUserId = newUserId;

      // Import all health data tables
      final tables = [
        'user_devices',
        'activity_data',
        'vital_signs',
        'sleep_data',
        'nutrition_data',
        'body_measurements',
        'wellness_data',
        'health_insights',
        'recommendations',
        'daily_summaries',
        'data_sync_log',
      ];

      int totalRecordsImported = 0;

      for (final tableName in tables) {
        if (importData.containsKey(tableName)) {
          final tableData = importData[tableName] as List<dynamic>;
          if (tableData.isNotEmpty) {
            print('🔄 Importing $tableName: ${tableData.length} records...');

            // Apply device ID mapping and clean up IDs for the data
            final mappedTableData = <Map<String, dynamic>>[];
            for (final record in tableData) {
              final recordMap = Map<String, dynamic>.from(
                record as Map<String, dynamic>,
              );

              // For user_devices table, handle device ID mapping
              if (tableName == 'user_devices') {
                if (recordMap.containsKey('id') &&
                    deviceIdMapping.containsKey(recordMap['id'])) {
                  recordMap['id'] = deviceIdMapping[recordMap['id']]!;
                  print(
                    '🔄 Mapped device ID in $tableName: ${record['id']} → ${recordMap['id']}',
                  );
                }
              } else {
                // For all other tables, remove the id field to let database auto-generate UUIDs
                if (recordMap.containsKey('id')) {
                  print(
                    '🔄 Removing ID field from $tableName record: ${recordMap['id']} (will be auto-generated)',
                  );
                  recordMap.remove('id');
                }
              }

              // Replace device_id references with new UUIDs
              if (recordMap.containsKey('device_id') &&
                  recordMap['device_id'] != null &&
                  deviceIdMapping.containsKey(recordMap['device_id'])) {
                final oldDeviceId = recordMap['device_id'];
                recordMap['device_id'] = deviceIdMapping[oldDeviceId]!;
                print(
                  '🔄 Mapped device_id in $tableName: $oldDeviceId → ${recordMap['device_id']}',
                );
              }

              // Replace user_id with the actual new user ID
              if (recordMap.containsKey('user_id')) {
                recordMap['user_id'] = actualUserId;
              }

              mappedTableData.add(recordMap);
            }

            // Import in batches to handle large datasets
            const batchSize = 100;
            int imported = 0;

            for (int i = 0; i < mappedTableData.length; i += batchSize) {
              final batch = mappedTableData.skip(i).take(batchSize).toList();
              await adminClient.from(tableName).insert(batch);
              imported += batch.length;
            }

            print('✅ Imported $imported records to $tableName');
            totalRecordsImported += imported;
          } else {
            print('ℹ️  No data found for $tableName');
          }
        } else {
          print(
            'ℹ️  Table $tableName not found in import data (this is normal for older exports)',
          );
        }
      }

      // Log import summary
      print('✅ Import Summary:');
      if (originalUserId != null) {
        print('   - Original User ID: $originalUserId');
      } else {
        print('   - Original User ID: none (clean import)');
      }
      print('   - New User ID: $actualUserId');
      print('   - Email: ${updatedUserProfile['email']}');
      print('   - Total Records Imported: $totalRecordsImported');
      print('   - Tables Processed: ${tables.length}');
      print('   - Device IDs Mapped: ${deviceIdMapping.length}');

      if (deviceIdMapping.isNotEmpty) {
        print('   - Device ID Mappings:');
        deviceIdMapping.forEach((oldId, newId) {
          print('     * $oldId → $newId');
        });
      }

      // Check export format version for compatibility info
      if (importData.containsKey('export_metadata')) {
        final metadata = importData['export_metadata'] as Map<String, dynamic>;
        final formatVersion = metadata['export_format_version'] ?? 'unknown';
        final exportDate = metadata['export_date'] ?? 'unknown';
        final deviceCount = metadata['device_count'] ?? 'unknown';
        final totalRecords = metadata['total_records'] ?? 'unknown';
        print('   - Export Format Version: $formatVersion');
        print('   - Export Date: $exportDate');
        print('   - Original Device Count: $deviceCount');
        print('   - Original Total Records: $totalRecords');
      }

      print('✅ Successfully imported all user data');
      return true;
    } catch (e) {
      print('❌ Error importing user data: $e');
      rethrow;
    }
  }

  /// Delete user and all associated health data
  static Future<bool> deleteUserAndData(String userId) async {
    try {
      print('🔄 SupabaseService: Deleting user and all data for: $userId');
      print('🔄 SupabaseService: Using admin client with service role key');

      // Delete from all health data tables in proper order (foreign keys)
      final tablesToDelete = [
        'data_sync_log',
        'daily_summaries',
        'recommendations',
        'health_insights',
        'wellness_data',
        'body_measurements',
        'nutrition_data',
        'sleep_data',
        'vital_signs',
        'activity_data',
        'user_devices',
        'users', // Delete user record last
      ];

      bool hasErrors = false;

      for (String table in tablesToDelete) {
        try {
          PostgrestFilterBuilder query;
          if (table == 'users') {
            // Users table uses 'id' as primary key - use admin client
            query = adminClient.from(table).delete().eq('id', userId);
          } else {
            // All other tables use 'user_id' as foreign key - use admin client
            query = adminClient.from(table).delete().eq('user_id', userId);
          }

          final result = await query;
          print('✅ SupabaseService: Deleted from $table - Result: $result');

          // For users table, let's check if it actually deleted anything
          if (table == 'users') {
            final stillExists = await adminClient
                .from('users')
                .select('id')
                .eq('id', userId)
                .maybeSingle();
            print(
              '🔍 SupabaseService: After users delete, user exists check: ${stillExists != null ? "STILL EXISTS" : "DELETED"}',
            );
          }
        } catch (e) {
          print('❌ SupabaseService: Error deleting from $table: $e');
          hasErrors = true;
          // For the users table, this is critical - don't continue if it fails
          if (table == 'users') {
            print('❌ SupabaseService: Critical error deleting user record');
            return false;
          }
        }
      }

      if (hasErrors) {
        print('⚠️ SupabaseService: Completed with some errors');
        return false;
      }

      print('✅ SupabaseService: Successfully deleted user and all data');

      // Verify deletion by checking if user still exists
      final verifyResult = await adminClient
          .from('users')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (verifyResult != null) {
        print(
          '❌ SupabaseService: Verification failed - user still exists in database',
        );
        return false;
      } else {
        print(
          '✅ SupabaseService: Verification successful - user deleted from database',
        );
      }

      return true;
    } catch (e) {
      print('❌ SupabaseService: Error deleting user data: $e');
      return false;
    }
  }

  /// Get comprehensive health summary for a user
  static Future<Map<String, dynamic>> getHealthSummary(
    String userId, {
    int days = 7,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      // Get basic user info
      final userResponse = await client
          .from('users')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (userResponse == null) {
        return {'error': 'User not found'};
      }

      // Get recent activity data
      final activityResponse = await client
          .from('activity_data')
          .select('*')
          .eq('user_id', userId)
          .gte('start_time', startDate.toIso8601String())
          .lte('start_time', endDate.toIso8601String())
          .order('start_time', ascending: false);

      // Get recent vital signs
      final vitalsResponse = await client
          .from('vital_signs')
          .select('*')
          .eq('user_id', userId)
          .gte('measured_at', startDate.toIso8601String())
          .lte('measured_at', endDate.toIso8601String())
          .order('measured_at', ascending: false);

      // Get recent sleep data
      final sleepResponse = await client
          .from('sleep_data')
          .select('*')
          .eq('user_id', userId)
          .gte('sleep_date', DateFormat('yyyy-MM-dd').format(startDate))
          .lte('sleep_date', DateFormat('yyyy-MM-dd').format(endDate))
          .order('sleep_date', ascending: false);

      // Get recent nutrition data
      final nutritionResponse = await client
          .from('nutrition_data')
          .select('*')
          .eq('user_id', userId)
          .gte('logged_at', startDate.toIso8601String())
          .lte('logged_at', endDate.toIso8601String())
          .order('logged_at', ascending: false);

      // Get recent wellness data
      final wellnessResponse = await client
          .from('wellness_data')
          .select('*')
          .eq('user_id', userId)
          .gte('recorded_at', startDate.toIso8601String())
          .lte('recorded_at', endDate.toIso8601String())
          .order('recorded_at', ascending: false);

      // Get recent health insights
      final insightsResponse = await client
          .from('health_insights')
          .select('*')
          .eq('user_id', userId)
          .gte('generated_at', startDate.toIso8601String())
          .order('generated_at', ascending: false)
          .limit(5);

      return {
        'user_profile': userResponse,
        'activity_data': activityResponse,
        'vital_signs': vitalsResponse,
        'sleep_data': sleepResponse,
        'nutrition_data': nutritionResponse,
        'wellness_data': wellnessResponse,
        'health_insights': insightsResponse,
        'date_range': {
          'start_date': DateFormat('yyyy-MM-dd').format(startDate),
          'end_date': DateFormat('yyyy-MM-dd').format(endDate),
          'days': days,
        },
      };
    } catch (e) {
      print('❌ SupabaseService: Error getting health summary: $e');
      return {'error': 'Failed to get health summary: $e'};
    }
  }

  /// Get vital signs data for a user within a date range
  static Future<List<Map<String, dynamic>>> getVitalSigns(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
    String? measurementType,
  }) async {
    try {
      var query = client
          .from('vital_signs')
          .select('*')
          .eq('user_id', userId)
          .gte('measured_at', startDate.toIso8601String())
          .lte('measured_at', endDate.toIso8601String());

      if (measurementType != null) {
        query = query.eq('measurement_type', measurementType);
      }

      final response = await query.order('measured_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ SupabaseService: Error getting vital signs: $e');
      return [];
    }
  }

  /// Get sleep analysis data for a user
  static Future<Map<String, dynamic>> getSleepAnalysis(
    String userId, {
    int days = 7,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final response = await client
          .from('sleep_data')
          .select('*')
          .eq('user_id', userId)
          .gte('sleep_date', DateFormat('yyyy-MM-dd').format(startDate))
          .lte('sleep_date', DateFormat('yyyy-MM-dd').format(endDate))
          .order('sleep_date', ascending: false);

      if (response.isEmpty) {
        return {
          'sleep_records': [],
          'summary': {
            'message': 'No sleep data found for the specified period',
          },
        };
      }

      // Calculate sleep statistics
      final sleepRecords = List<Map<String, dynamic>>.from(response);
      final totalRecords = sleepRecords.length;
      final avgSleepMinutes =
          sleepRecords
              .map((record) => record['total_sleep_minutes'] as int? ?? 0)
              .reduce((a, b) => a + b) /
          totalRecords;
      final avgSleepQuality =
          sleepRecords
              .map((record) => record['sleep_quality_score'] as double? ?? 0.0)
              .reduce((a, b) => a + b) /
          totalRecords;
      final avgSleepEfficiency =
          sleepRecords
              .map((record) => record['sleep_efficiency'] as double? ?? 0.0)
              .reduce((a, b) => a + b) /
          totalRecords;

      return {
        'sleep_records': sleepRecords,
        'summary': {
          'total_nights': totalRecords,
          'avg_sleep_hours': (avgSleepMinutes / 60).round(),
          'avg_sleep_quality': avgSleepQuality.round(),
          'avg_sleep_efficiency': avgSleepEfficiency.round(),
          'date_range': {
            'start_date': DateFormat('yyyy-MM-dd').format(startDate),
            'end_date': DateFormat('yyyy-MM-dd').format(endDate),
          },
        },
      };
    } catch (e) {
      print('❌ SupabaseService: Error getting sleep analysis: $e');
      return {'error': 'Failed to get sleep analysis: $e'};
    }
  }

  /// Get nutrition analysis data for a user
  static Future<Map<String, dynamic>> getNutritionAnalysis(
    String userId, {
    int days = 7,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final response = await client
          .from('nutrition_data')
          .select('*')
          .eq('user_id', userId)
          .gte('logged_at', startDate.toIso8601String())
          .lte('logged_at', endDate.toIso8601String())
          .order('logged_at', ascending: false);

      if (response.isEmpty) {
        return {
          'nutrition_records': [],
          'summary': {
            'message': 'No nutrition data found for the specified period',
          },
        };
      }

      final nutritionRecords = List<Map<String, dynamic>>.from(response);

      // Calculate nutrition statistics
      final totalCalories = nutritionRecords
          .map((record) => record['calories'] as double? ?? 0.0)
          .reduce((a, b) => a + b);
      final totalProtein = nutritionRecords
          .map((record) => record['protein_g'] as double? ?? 0.0)
          .reduce((a, b) => a + b);
      final totalCarbs = nutritionRecords
          .map((record) => record['carbs_g'] as double? ?? 0.0)
          .reduce((a, b) => a + b);
      final totalFat = nutritionRecords
          .map((record) => record['fat_g'] as double? ?? 0.0)
          .reduce((a, b) => a + b);
      final totalWater = nutritionRecords
          .map((record) => record['water_ml'] as double? ?? 0.0)
          .reduce((a, b) => a + b);

      return {
        'nutrition_records': nutritionRecords,
        'summary': {
          'total_days': days,
          'total_calories': totalCalories.round(),
          'avg_daily_calories': (totalCalories / days).round(),
          'total_protein_g': totalProtein.round(),
          'total_carbs_g': totalCarbs.round(),
          'total_fat_g': totalFat.round(),
          'total_water_ml': totalWater.round(),
          'avg_daily_water_ml': (totalWater / days).round(),
          'date_range': {
            'start_date': DateFormat('yyyy-MM-dd').format(startDate),
            'end_date': DateFormat('yyyy-MM-dd').format(endDate),
          },
        },
      };
    } catch (e) {
      print('❌ SupabaseService: Error getting nutrition analysis: $e');
      return {'error': 'Failed to get nutrition analysis: $e'};
    }
  }

  /// Get wellness metrics for a user
  static Future<Map<String, dynamic>> getWellnessMetrics(
    String userId, {
    int days = 7,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final response = await client
          .from('wellness_data')
          .select('*')
          .eq('user_id', userId)
          .gte('recorded_at', startDate.toIso8601String())
          .lte('recorded_at', endDate.toIso8601String())
          .order('recorded_at', ascending: false);

      if (response.isEmpty) {
        return {
          'wellness_records': [],
          'summary': {
            'message': 'No wellness data found for the specified period',
          },
        };
      }

      final wellnessRecords = List<Map<String, dynamic>>.from(response);

      // Group by wellness type and calculate averages
      final Map<String, List<double>> wellnessTypes = {};
      for (final record in wellnessRecords) {
        final type = record['wellness_type'] as String;
        final value = record['value_numeric'] as double? ?? 0.0;
        if (!wellnessTypes.containsKey(type)) {
          wellnessTypes[type] = [];
        }
        wellnessTypes[type]!.add(value);
      }

      final Map<String, double> averages = {};
      wellnessTypes.forEach((type, values) {
        averages[type] = values.reduce((a, b) => a + b) / values.length;
      });

      return {
        'wellness_records': wellnessRecords,
        'summary': {
          'total_entries': wellnessRecords.length,
          'wellness_averages': averages,
          'date_range': {
            'start_date': DateFormat('yyyy-MM-dd').format(startDate),
            'end_date': DateFormat('yyyy-MM-dd').format(endDate),
          },
        },
      };
    } catch (e) {
      print('❌ SupabaseService: Error getting wellness metrics: $e');
      return {'error': 'Failed to get wellness metrics: $e'};
    }
  }

  /// Test if we can actually delete from users table (for debugging RLS issues)
  static Future<void> testDeletePermissions(String userId) async {
    try {
      print('🔍 Testing delete permissions for user: $userId');

      // First, check if user exists
      final userExists = await client
          .from('users')
          .select('id, email')
          .eq('id', userId)
          .maybeSingle();

      print(
        '🔍 User exists check: ${userExists != null ? "YES - ${userExists}" : "NO"}',
      );

      if (userExists != null) {
        // Try a direct delete and see what happens
        try {
          final deleteResult = await client
              .from('users')
              .delete()
              .eq('id', userId);

          print('🔍 Direct delete result: $deleteResult');

          // Check if still exists after delete
          final stillExists = await client
              .from('users')
              .select('id')
              .eq('id', userId)
              .maybeSingle();

          print(
            '🔍 After delete, still exists: ${stillExists != null ? "YES" : "NO"}',
          );
        } catch (e) {
          print('🔍 Delete failed with error: $e');
        }
      }
    } catch (e) {
      print('❌ Test delete permissions error: $e');
    }
  }

  /// Get health insights for a user
  static Future<List<Map<String, dynamic>>> getHealthInsights(
    String userId, {
    String? category,
    int limit = 5,
  }) async {
    try {
      var query = client
          .from('health_insights')
          .select('*')
          .eq('user_id', userId);

      if (category != null) {
        query = query.eq('category', category);
      }

      final response = await query
          .order('generated_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ SupabaseService: Error getting health insights: $e');
      return [];
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
