import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/services/supabase_service.dart';

void main() async {
  if (kDebugMode) {
    print('🧪 Testing Export Function with Genetic Insights');
  }

  // Initialize Supabase (you'll need to set these environment variables)
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  try {
    // First, let's check if we have any users in the database
    if (kDebugMode) {
      print('🔍 Checking for existing users...');
    }
    final usersResponse = await Supabase.instance.client
        .from('users')
        .select('id, email')
        .limit(5);

    if (usersResponse.isEmpty) {
      if (kDebugMode) {
        print('⚠️ No users found in database. Let\'s import test data first...');
      }

      // Read the test data file
      final testDataFile = File(
        'test_data/user_data_Sarah Martinez_1756999481008.json',
      );
      if (!testDataFile.existsSync()) {
        if (kDebugMode) {
          print('❌ Test data file not found!');
        }
        return;
      }

      final testDataContent = testDataFile.readAsStringSync();
      final testData = json.decode(testDataContent) as Map<String, dynamic>;

      if (kDebugMode) {
        print('📥 Importing test data...');
      }
      final importResult = await SupabaseService.importUserData(testData);

      if (!importResult) {
        if (kDebugMode) {
          print('❌ Failed to import test data');
        }
        return;
      }
      if (kDebugMode) {
        print('✅ Test data imported successfully');
      }

      // Get the newly imported user ID
      final newUsers = await Supabase.instance.client
          .from('users')
          .select('id, email')
          .eq('email', 'sarah.college.athlete@university.edu')
          .maybeSingle();

      if (newUsers == null) {
        if (kDebugMode) {
          print('❌ Could not find imported user');
        }
        return;
      }

      final userId = newUsers['id'] as String;
      if (kDebugMode) {
        print('🔍 Found imported user: $userId');
      }

      // Now test the export
      await testExport(userId);
    } else {
      if (kDebugMode) {
        print('✅ Found existing users:');
        for (final user in usersResponse) {
          print('   - ${user['id']}: ${user['email']}');
        }
      }

      // Use the first user for testing
      final userId = usersResponse[0]['id'] as String;
      await testExport(userId);
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error during testing: $e');
    }
  }
}

Future<void> testExport(String userId) async {
  if (kDebugMode) {
    print('📤 Testing export for user: $userId');
  }

  try {
    final exportData = await SupabaseService.exportUserData(userId);

    if (kDebugMode) {
      print('✅ Export completed successfully');
    }

    // Check the genetic_insights structure
    if (exportData.containsKey('genetic_insights')) {
      final geneticInsights = exportData['genetic_insights'] as List<dynamic>;

      if (kDebugMode) {
        print('🔍 Genetic Insights Analysis:');
        print('   - Type: ${geneticInsights.runtimeType}');
        print('   - Length: ${geneticInsights.length}');
      }

      if (geneticInsights.isNotEmpty) {
        final firstInsight = geneticInsights[0] as Map<String, dynamic>;
        if (kDebugMode) {
          print('   - First insight keys: ${firstInsight.keys.toList()}');
        }

        if (firstInsight.containsKey('data')) {
          if (kDebugMode) {
            print('   ✅ Contains "data" field');
          }
        } else {
          if (kDebugMode) {
            print('   ❌ Missing "data" field');
          }
        }

        if (firstInsight.containsKey('meta_data')) {
          if (kDebugMode) {
            print('   ✅ Contains "meta_data" field');
          }
        } else {
          if (kDebugMode) {
            print('   ❌ Missing "meta_data" field');
          }
        }

        // Check if it has the database fields that should be removed
        if (firstInsight.containsKey('id')) {
          if (kDebugMode) {
            print('   ❌ Still contains "id" field (should be removed)');
          }
        } else {
          if (kDebugMode) {
            print('   ✅ "id" field properly removed');
          }
        }

        if (firstInsight.containsKey('user_id')) {
          if (kDebugMode) {
            print('   ❌ Still contains "user_id" field (should be removed)');
          }
        } else {
          if (kDebugMode) {
            print('   ✅ "user_id" field properly removed');
          }
        }
      }
    } else {
      if (kDebugMode) {
        print('❌ Export data missing genetic_insights key');
      }
    }

    // Check export metadata
    if (exportData.containsKey('export_metadata')) {
      final metadata = exportData['export_metadata'] as Map<String, dynamic>;
      if (kDebugMode) {
        print('📋 Export Metadata:');
        print('   - Format Version: ${metadata['export_format_version']}');
        print('   - Total Records: ${metadata['total_records']}');
        print('   - Device Count: ${metadata['device_count']}');
        print(
          '   - Genetic Insights Count: ${metadata['genetic_insights_count']}',
        );
      }
    }

    // Save export to file for inspection
    final exportFile = File('test_export_output.json');
    exportFile.writeAsStringSync(json.encode(exportData));
    if (kDebugMode) {
      print('💾 Export saved to: test_export_output.json');
      print('✅ Export test completed successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error during export test: $e');
    }
  }
}
