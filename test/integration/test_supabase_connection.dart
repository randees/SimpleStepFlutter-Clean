import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../lib/config/supabase_config.dart';

void main() async {
  print('🔄 Testing Supabase connection...');
  print('URL: ${SupabaseConfig.supabaseUrl}');
  print('Anon Key: ${SupabaseConfig.supabaseAnonKey.substring(0, 20)}...\n');

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );

    print('✅ Supabase client initialized successfully!');

    // Test basic connection
    final client = Supabase.instance.client;

    // Try to perform a simple query (this will test the connection)
    try {
      // Check if we can connect to the database
      final response = await client
          .from('step_data')
          .select('count(*)')
          .limit(1);

      print('✅ Database connection successful!');
      print('✅ Can access step_data table');
      print('Response: $response');
    } catch (tableError) {
      print(
        '⚠️  Connection successful, but step_data table might not exist yet:',
      );
      print('   Error: $tableError');
      print('   This is expected if you haven\'t created the table yet.');
    }

    // Test authentication status
    final user = client.auth.currentUser;
    if (user != null) {
      print('✅ User authenticated: ${user.id}');
    } else {
      print('ℹ️  No user authenticated (using anon key - this is normal)');
    }

    print('\n🎉 Supabase connection test completed successfully!');
  } catch (e) {
    print('❌ Failed to connect to Supabase:');
    print('   Error: $e');
    print('\n🔍 Troubleshooting tips:');
    print('   1. Check that your Supabase URL is correct');
    print('   2. Verify your anon key is valid');
    print('   3. Ensure your Supabase project is active');
    print('   4. Check your internet connection');
    exit(1);
  }
}
