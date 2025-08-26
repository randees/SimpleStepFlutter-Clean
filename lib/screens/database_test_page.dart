import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';
import '../utils/app_icons.dart';

/// Database Connection Tester page - Test Supabase connectivity and database operations
class DatabaseTestPage extends StatefulWidget {
  const DatabaseTestPage({super.key});

  @override
  State<DatabaseTestPage> createState() => _DatabaseTestPageState();
}

class _DatabaseTestPageState extends State<DatabaseTestPage> {
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
      print('🔄 DatabaseTest: Starting database connection test...');

      // Test 1: Check if Supabase is initialized
      _updateOutput('Step 1: Checking Supabase initialization...');
      bool connectionOk = await SupabaseService.testConnection();

      if (!connectionOk) {
        throw Exception('Supabase connection failed');
      }
      _updateOutput('✅ Supabase initialized successfully');

      // Test 2: Try to fetch users
      _updateOutput('Step 2: Fetching users from database...');
      List<UserModel> users = await SupabaseService.fetchUsers();

      setState(() {
        _users = users;
        _userCount = users.length;
        _isLoading = false;
      });

      _updateOutput('✅ Database test completed successfully');
      _updateOutput('Found ${users.length} users in database:');

      for (var user in users) {
        _updateOutput(
          '  - ${user.friendlyName} (${user.activityLevel ?? 'Unknown'})',
        );
      }

      print('✅ Database test completed: ${users.length} users found');
    } catch (e) {
      setState(() {
        _lastError = e.toString();
        _isLoading = false;
        _userCount = 0;
        _users.clear();
      });

      _updateOutput('❌ Database test failed: $e');
      print('❌ Database test failed: $e');
    }
  }

  void _updateOutput(String message) {
    setState(() {
      _debugOutput += '\\n$message';
    });
  }

  /// Retry the database test
  Future<void> _retryTest() async {
    setState(() {
      _debugOutput = 'Retrying database test...';
      _lastError = null;
      _userCount = 0;
      _users.clear();
    });
    await _testDatabaseConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header info
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.database(),
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Database Connection Tester',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Test Supabase database connectivity and user data access.',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

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
                              ? AppIcons.error()
                              : _userCount > 0
                              ? AppIcons.checkCircle()
                              : AppIcons.warning(),
                          color: _lastError != null
                              ? Colors.red.shade700
                              : _userCount > 0
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _lastError != null
                              ? 'Connection Failed'
                              : _userCount > 0
                              ? 'Connected Successfully'
                              : 'Testing Connection...',
                          style: TextStyle(
                            fontSize: 16,
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
                        : Icon(AppIcons.refresh()),
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
                    icon: Icon(AppIcons.clear()),
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
