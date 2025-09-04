import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/services/supabase_service.dart';

void main() async {
  print('🧪 Testing Export Function with Genetic Insights');

  // Initialize Supabase (you'll need to set these environment variables)
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  try {
    // First, let's check if we have any users in the database
    print('🔍 Checking for existing users...');
    final usersResponse = await Supabase.instance.client
        .from('users')
        .select('id, email')
        .limit(5);

    if (usersResponse.isEmpty) {
      print('⚠️ No users found in database. Let\'s import test data first...');

      // Read the test data file
      final testDataFile = File('test_data/user_data_Sarah Martinez_1756999481008.json');
      if (!testDataFile.existsSync()) {
        print('❌ Test data file not found!');
        return;
      }

      final testDataContent = testDataFile.readAsStringSync();
      final testData = json.decode(testDataContent) as Map<String, dynamic>;

      print('📥 Importing test data...');
      final importResult = await SupabaseService.importUserData(testData);

      if (!importResult) {
        print('❌ Failed to import test data');
        return;
      }
      print('✅ Test data imported successfully');

      // Get the newly imported user ID
      final newUsers = await Supabase.instance.client
          .from('users')
          .select('id, email')
          .eq('email', 'sarah.college.athlete@university.edu')
          .maybeSingle();

      if (newUsers == null) {
        print('❌ Could not find imported user');
        return;
      }

      final userId = newUsers['id'] as String;
      print('🔍 Found imported user: $userId');

      // Now test the export
      await testExport(userId);
    } else {
      print('✅ Found existing users:');
      for (final user in usersResponse) {
        print('   - ${user['id']}: ${user['email']}');
      }

      // Use the first user for testing
      final userId = usersResponse[0]['id'] as String;
      await testExport(userId);
    }

  } catch (e) {
    print('❌ Error during testing: $e');
  }
}

Future<void> testExport(String userId) async {
  print('📤 Testing export for user: $userId');

  try {
    final exportData = await SupabaseService.exportUserData(userId);

    print('✅ Export completed successfully');

    // Check the genetic_insights structure
    if (exportData.containsKey('genetic_insights')) {
      final geneticInsights = exportData['genetic_insights'] as List<dynamic>;

      print('🔍 Genetic Insights Analysis:');
      print('   - Type: ${geneticInsights.runtimeType}');
      print('   - Length: ${geneticInsights.length}');

      if (geneticInsights.isNotEmpty) {
        final firstInsight = geneticInsights[0] as Map<String, dynamic>;
        print('   - First insight keys: ${firstInsight.keys.toList()}');

        if (firstInsight.containsKey('data')) {
          print('   ✅ Contains "data" field');
        } else {
          print('   ❌ Missing "data" field');
        }

        if (firstInsight.containsKey('meta_data')) {
          print('   ✅ Contains "meta_data" field');
        } else {
          print('   ❌ Missing "meta_data" field');
        }

        // Check if it has the database fields that should be removed
        if (firstInsight.containsKey('id')) {
          print('   ❌ Still contains "id" field (should be removed)');
        } else {
          print('   ✅ "id" field properly removed');
        }

        if (firstInsight.containsKey('user_id')) {
          print('   ❌ Still contains "user_id" field (should be removed)');
        } else {
          print('   ✅ "user_id" field properly removed');
        }
      }
    } else {
      print('❌ Export data missing genetic_insights key');
    }

    // Check export metadata
    if (exportData.containsKey('export_metadata')) {
      final metadata = exportData['export_metadata'] as Map<String, dynamic>;
      print('📋 Export Metadata:');
      print('   - Format Version: ${metadata['export_format_version']}');
      print('   - Total Records: ${metadata['total_records']}');
      print('   - Device Count: ${metadata['device_count']}');
      print('   - Genetic Insights Count: ${metadata['genetic_insights_count']}');
    }

    // Save export to file for inspection
    final exportFile = File('test_export_output.json');
    exportFile.writeAsStringSync(json.encode(exportData));
    print('💾 Export saved to: test_export_output.json');

    print('✅ Export test completed successfully');

  } catch (e) {
    print('❌ Error during export test: $e');
  }
}
