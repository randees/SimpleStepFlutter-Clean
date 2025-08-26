import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';

class MCPTestWidget extends StatefulWidget {
  const MCPTestWidget({super.key});

  @override
  State<MCPTestWidget> createState() => _MCPTestWidgetState();
}

class _MCPTestWidgetState extends State<MCPTestWidget> {
  bool _isLoading = false;
  String _debugOutput = 'Ready to test database connection...';
  int _userCount = 0;
  List<UserModel> _users = [];
  String? _lastError;

  @override
  void initState() {
    super.initState();
    // Automatically run initial check when widget loads
    _testDatabaseConnection();
  }

  /// Test basic database connection
  Future<void> _testDatabaseConnection() async {
    setState(() {
      _isLoading = true;
      _debugOutput = 'Testing database connection...';
      _lastError = null;
    });

    try {
      print('🔄 MCPTest: Starting database connection test...');

      // Test 1: Check if Supabase is initialized
      await SupabaseService.initialize();
      _appendDebug('✅ Supabase service initialized');

      // Test 2: Test connection
      final connectionOk = await SupabaseService.testConnection();
      _appendDebug('✅ Database connection test: $connectionOk');

      // Test 3: Fetch users
      final users = await SupabaseService.fetchUsers();
      _appendDebug('✅ Fetched users from database: ${users.length} users');

      setState(() {
        _users = users;
        _userCount = users.length;
      });

      // Test 4: Show user details if any exist
      if (users.isNotEmpty) {
        _appendDebug('\n📋 User Details:');
        for (int i = 0; i < users.length; i++) {
          final user = users[i];
          _appendDebug('  ${i + 1}. ${user.friendlyName} (ID: ${user.id})');
          _appendDebug('     Email: ${user.email}');
        }
      } else {
        _appendDebug('\n⚠️ No users found in database');
        _appendDebug('   This could mean:');
        _appendDebug('   - The users table is empty');
        _appendDebug('   - Row Level Security is blocking access');
        _appendDebug('   - The table does not exist');
      }
    } catch (e, stackTrace) {
      print('❌ MCPTest: Database error: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        _lastError = e.toString();
      });

      _appendDebug('\n❌ Database Error: $e');

      // Provide specific guidance based on error type
      if (e.toString().contains('Failed host lookup')) {
        _appendDebug('\n🔍 Network Issue Detected:');
        _appendDebug('   - Check internet connection');
        _appendDebug('   - Verify Supabase URL is correct');
        _appendDebug('   - Try again when network is stable');
      } else if (e.toString().contains('permission denied')) {
        _appendDebug('\n🔍 Permission Issue Detected:');
        _appendDebug('   - Row Level Security may be blocking access');
        _appendDebug('   - Anonymous key may lack permissions');
        _appendDebug('   - Check Supabase policies');
      } else {
        _appendDebug('\n🔍 Unknown Error:');
        _appendDebug('   - Check Supabase configuration');
        _appendDebug('   - Verify database schema');
        _appendDebug('   - Check server logs');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Helper to append debug messages
  void _appendDebug(String message) {
    setState(() {
      _debugOutput += '\n$message';
    });
  }

  /// Manual retry button
  void _retryTest() {
    setState(() {
      _debugOutput = 'Retrying database connection test...';
      _userCount = 0;
      _users.clear();
      _lastError = null;
    });
    _testDatabaseConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug Tool'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: _lastError != null
                  ? Colors.red.shade50
                  : _userCount > 0
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _lastError != null
                              ? Icons.error
                              : _userCount > 0
                              ? Icons.check_circle
                              : Icons.warning,
                          color: _lastError != null
                              ? Colors.red
                              : _userCount > 0
                              ? Colors.green
                              : Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Database Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _lastError != null
                                ? Colors.red.shade700
                                : _userCount > 0
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'User Count: $_userCount',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_lastError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Last Error: $_lastError',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _retryTest,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(_isLoading ? 'Testing...' : 'Test Database'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _debugOutput = 'Debug output cleared...';
                        _lastError = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Log'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Debug Output
            const Text(
              'Debug Output:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugOutput,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
