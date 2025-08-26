import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔄 Testing Supabase connection via HTTP...');

  final url = 'https://YOUR-PROJECT-ID.supabase.co';
  final anonKey =
      '"YOUR-SUPABASE-ANON-KEY"

  print('URL: $url');
  print('Anon Key: ${anonKey.substring(0, 20)}...\n');

  try {
    // Test basic connection to Supabase
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('$url/rest/v1/'));
    request.headers.set('apikey', anonKey);
    request.headers.set('authorization', 'Bearer $anonKey');

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    print('✅ Connection successful!');
    print('Status Code: ${response.statusCode}');
    print(
      'Response: ${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}...',
    );

    // Test step_data table access
    try {
      final tableRequest = await client.getUrl(
        Uri.parse('$url/rest/v1/step_data?select=count(*)&limit=1'),
      );
      tableRequest.headers.set('apikey', anonKey);
      tableRequest.headers.set('authorization', 'Bearer $anonKey');

      final tableResponse = await tableRequest.close();
      final tableResponseBody = await tableResponse
          .transform(utf8.decoder)
          .join();

      if (tableResponse.statusCode == 200) {
        print('✅ step_data table is accessible!');
        print('Table response: $tableResponseBody');
      } else {
        print('⚠️  step_data table access: Status ${tableResponse.statusCode}');
        print('Response: $tableResponseBody');
      }
    } catch (tableError) {
      print('⚠️  Could not access step_data table: $tableError');
      print('This is expected if the table hasn\'t been created yet.');
    }

    client.close();
    print('\n🎉 Supabase connection test completed!');
  } catch (e) {
    print('❌ Connection failed: $e');
    print('\n🔍 Troubleshooting tips:');
    print('   1. Check that your Supabase URL is correct');
    print('   2. Verify your anon key is valid');
    print('   3. Ensure your Supabase project is active');
    print('   4. Check your internet connection');
  }
}
