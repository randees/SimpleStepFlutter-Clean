import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/supabase_service.dart';
import '../models/user_model.dart';
import '../config/openai_config.dart';

enum TestMode { database, aiMcp }

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}

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

  // New state for switching between test modes
  TestMode _currentMode = TestMode.database;

  // AI Chat state variables
  UserModel? _selectedUser;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _customPromptController = TextEditingController();
  List<ChatMessage> _conversationHistory = [];
  bool _isAiProcessing = false;
  bool _isHistoryExpanded = false;

  // Default system prompt
  static const String _defaultSystemPrompt =
      '''You are a certified health provider and fitness trainer who cares deeply about helping people improve their health and wellness. You have access to detailed health data through MCP (Model Context Protocol) tools.

Your personality and approach:
- Speak in a warm, encouraging, and professional tone
- Use motivational language that inspires positive action
- Provide specific, actionable health and fitness advice
- Celebrate progress and achievements, no matter how small
- Offer gentle guidance when improvements are needed
- Use "you" and "your" to make responses personal and engaging
- Include practical tips and suggestions for better health outcomes

Current client context:
- Name: {user_name}
- Email: {user_email}
- Age: {user_age}
- Activity Level: {user_activity_level}
- Health Goals: {user_health_goals}

You can access their health data using our Supabase Edge Functions at:
- Base URL: https://YOUR-PROJECT-ID.supabase.co/functions/v1/mcp-server

Use a ReAct (Reasoning and Acting) approach:
1. Think about what health data you need to provide the best guidance
2. Act by calling the appropriate endpoint to retrieve their data
3. Observe the results and analyze patterns
4. Provide encouraging, actionable health advice as their personal trainer/health provider

Always respond as if you're speaking directly to your client in a supportive consultation. Keep responses under 1000 characters. Maximum 5 attempts to formulate a response.''';

  @override
  void initState() {
    super.initState();
    // Initialize custom prompt with default
    _customPromptController.text = _defaultSystemPrompt;
    // Automatically run initial check when widget loads
    _testDatabaseConnection();
    // Load users for AI testing
    _loadUsersForAi();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }

  /// Switch between test modes
  void _switchTestMode() {
    setState(() {
      if (_currentMode == TestMode.database) {
        _currentMode = TestMode.aiMcp;
        _debugOutput =
            'AI/MCP Testing Mode\n\nReAct interface for health data analysis.';
        _lastError = null;
        _userCount = 0;
        _isLoading = false;
        // Don't clear users when switching to AI mode - we need them for the dropdown
        // Load users if not already loaded and not currently loading
        if (_users.isEmpty && !_isLoading) {
          _loadUsersForAi();
        } else if (_users.isNotEmpty) {
          // Ensure we have a valid selected user if users are available
          if (_selectedUser == null || !_users.contains(_selectedUser)) {
            _selectedUser = _users.first;
          }
        }
      } else {
        _currentMode = TestMode.database;
        _debugOutput = 'Switched to Database Testing Mode...';
        _lastError = null;
        _userCount = 0;
        _users.clear();
        _testDatabaseConnection();
      }
    });
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
          if (user.displayName != null) {
            _appendDebug('     Display Name: ${user.displayName}');
          }
          if (user.gender != null) {
            _appendDebug('     Gender: ${user.gender}');
          }
          if (user.heightCm != null && user.weightKg != null) {
            _appendDebug(
              '     Height: ${user.heightCm}cm, Weight: ${user.weightKg}kg',
            );
          }
          if (user.activityLevel != null) {
            _appendDebug('     Activity Level: ${user.activityLevel}');
          }
          if (user.healthGoals != null && user.healthGoals!.isNotEmpty) {
            _appendDebug('     Health Goals: ${user.healthGoals!.join(", ")}');
          }
          _appendDebug(''); // Empty line between users
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

  /// Load users for AI testing with network fallback
  Future<void> _loadUsersForAi() async {
    // Prevent loading if already loading or users already exist
    if (_isLoading || _users.isNotEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final users = await SupabaseService.fetchUsers();
      setState(() {
        _users = users;
        // Reset selected user to the first user from the new list
        _selectedUser = users.isNotEmpty ? users.first : null;
        _isLoading = false;
      });
      print('✅ Loaded ${users.length} users for AI testing');
    } catch (e) {
      print('❌ Network error loading users: $e');

      // Fallback: Create mock users for testing when network is unavailable
      final mockUsers = [
        UserModel(
          id: 'mock-alex',
          email: 'alex.johnson@example.com',
          displayName: 'Alex Johnson',
          activityLevel: 'Moderately Active',
          healthGoals: ['Lose Weight', 'Build Muscle'],
          dateOfBirth: DateTime(1990, 5, 15),
          gender: 'Male',
          heightCm: 180,
          weightKg: 75,
        ),
        UserModel(
          id: 'mock-maria',
          email: 'maria.garcia@example.com',
          displayName: 'Maria Garcia',
          activityLevel: 'Very Active',
          healthGoals: ['Maintain Fitness', 'Run Marathon'],
          dateOfBirth: DateTime(1985, 8, 22),
          gender: 'Female',
          heightCm: 165,
          weightKg: 60,
        ),
        UserModel(
          id: 'mock-john',
          email: 'john.smith@example.com',
          displayName: 'John Smith',
          activityLevel: 'Lightly Active',
          healthGoals: ['Increase Steps', 'Better Sleep'],
          dateOfBirth: DateTime(1992, 12, 3),
          gender: 'Male',
          heightCm: 175,
          weightKg: 80,
        ),
      ];

      setState(() {
        _users = mockUsers;
        // Reset selected user to the first user from the mock list
        _selectedUser = mockUsers.isNotEmpty ? mockUsers.first : null;
        _isLoading = false;
      });
      print(
        '✅ Using ${mockUsers.length} mock users for testing (network unavailable)',
      );
    }
  }

  /// Submit question to AI with proper error handling (uses default prompt)
  Future<void> _submitQuestion() async {
    print('🔘 _submitQuestion called (DEFAULT)');
    await _submitQuestionWithPrompt(false);
  }

  /// Submit question to AI with custom prompt
  Future<void> _submitQuestionCustom() async {
    print('🟣 _submitQuestionCustom called (CUSTOM)');
    await _submitQuestionWithPrompt(true);
  }

  /// Submit question to AI with proper error handling
  Future<void> _submitQuestionWithPrompt(bool useCustomPrompt) async {
    print(
      '🚀 _submitQuestionWithPrompt called with useCustomPrompt: $useCustomPrompt',
    );

    final question = _questionController.text.trim();
    print('📝 Question: "$question"');
    print('👤 Selected user: ${_selectedUser?.friendlyName ?? "null"}');
    print('🔄 Is AI processing: $_isAiProcessing');

    if (question.isEmpty || _selectedUser == null) {
      print(
        '❌ Returning early: question empty (${question.isEmpty}) or user null (${_selectedUser == null})',
      );
      return;
    }

    setState(() {
      _isAiProcessing = true;
      _conversationHistory.add(
        ChatMessage(
          message: useCustomPrompt
              ? "[CUSTOM PROMPT] $question"
              : "[DEFAULT PROMPT] $question",
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    // Don't clear the question automatically - user can use the clear button if desired
    // _questionController.clear(); // Removed automatic clearing

    try {
      final response = await _callOpenAI(
        question,
        _selectedUser!,
        useCustomPrompt,
      );
      setState(() {
        _conversationHistory.add(
          ChatMessage(
            message: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });

      // Auto-expand history if it was collapsed
      if (!_isHistoryExpanded) {
        setState(() {
          _isHistoryExpanded = true;
        });
      }
    } catch (e) {
      setState(() {
        _conversationHistory.add(
          ChatMessage(
            message:
                'Sorry, I encountered an error: ${e.toString()}. This might be due to network connectivity or API issues.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } finally {
      setState(() {
        _isAiProcessing = false;
      });
    }
  }

  /// Call OpenAI API with health provider personality
  Future<String> _callOpenAI(
    String question,
    UserModel user,
    bool useCustomPrompt,
  ) async {
    print('🔄 _callOpenAI called with useCustomPrompt: $useCustomPrompt');

    // Use environment variable or config for API key in production
    final apiKey = OpenAIConfig.apiKey;

    String systemPrompt;

    if (useCustomPrompt) {
      print('✅ Using CUSTOM prompt');
      // Use custom prompt with user context replacement
      systemPrompt = _customPromptController.text
          .replaceAll('{user_name}', user.friendlyName)
          .replaceAll('{user_email}', user.email)
          .replaceAll(
            '{user_age}',
            user.dateOfBirth != null
                ? '${DateTime.now().year - user.dateOfBirth!.year}'
                : 'Unknown',
          )
          .replaceAll('{user_activity_level}', user.activityLevel ?? 'Unknown')
          .replaceAll(
            '{user_health_goals}',
            user.healthGoals?.join(', ') ?? 'None specified',
          );
      print(
        '📝 Custom prompt (first 200 chars): ${systemPrompt.substring(0, systemPrompt.length > 200 ? 200 : systemPrompt.length)}...',
      );
    } else {
      print('🔹 Using DEFAULT prompt');
      // Use default prompt
      systemPrompt =
          '''
You are a certified health provider and fitness trainer who cares deeply about helping people improve their health and wellness. You have access to detailed health data through MCP (Model Context Protocol) tools.

Your personality and approach:
- Speak in a warm, encouraging, and professional tone
- Use motivational language that inspires positive action
- Provide specific, actionable health and fitness advice
- Celebrate progress and achievements, no matter how small
- Offer gentle guidance when improvements are needed
- Use "you" and "your" to make responses personal and engaging
- Include practical tips and suggestions for better health outcomes

Current client context:
- Name: ${user.friendlyName}
- Email: ${user.email}
- Age: ${user.dateOfBirth != null ? DateTime.now().year - user.dateOfBirth!.year : 'Unknown'}
- Activity Level: ${user.activityLevel ?? 'Unknown'}
- Health Goals: ${user.healthGoals?.join(', ') ?? 'None specified'}

You can access their health data using our Supabase Edge Functions at:
- Base URL: https://YOUR-PROJECT-ID.supabase.co/functions/v1/mcp-server

Use a ReAct (Reasoning and Acting) approach:
1. Think about what health data you need to provide the best guidance
2. Act by calling the appropriate endpoint to retrieve their data
3. Observe the results and analyze patterns
4. Provide encouraging, actionable health advice as their personal trainer/health provider

Always respond as if you're speaking directly to your client in a supportive consultation. Keep responses under 1000 characters. Maximum 5 attempts to formulate a response.
''';
    }

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...(_conversationHistory.length > 10
              ? _conversationHistory.skip(_conversationHistory.length - 8)
              : _conversationHistory)
          .map(
            (msg) => {
              'role': msg.isUser ? 'user' : 'assistant',
              'content': msg.message,
            },
          ),
      {'role': 'user', 'content': question},
    ];

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': messages,
        'max_tokens': 300,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final content = data['choices'][0]['message']['content'] as String;
      return content.length > 1000
          ? content.substring(0, 997) + '...'
          : content;
    } else {
      throw Exception(
        'OpenAI API error: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Reset conversation history
  void _resetConversation() {
    setState(() {
      _conversationHistory.clear();
      // Don't clear the question text - user can use the clear button if desired
      // _questionController.clear(); // Removed automatic clearing
      _isAiProcessing = false;
    });
  }

  /// Reset custom prompt to default
  void _resetCustomPrompt() {
    setState(() {
      _customPromptController.text = _defaultSystemPrompt;
    });
  }

  /// Toggle conversation history visibility
  void _toggleHistory() {
    setState(() {
      _isHistoryExpanded = !_isHistoryExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // This helps with keyboard handling
      appBar: AppBar(
        title: const Text('Testing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _switchTestMode,
            tooltip: _currentMode == TestMode.database
                ? 'Switch to AI/MCP Testing'
                : 'Switch to Database Testing',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _currentMode == TestMode.database
            ? _buildDatabaseTestView()
            : _buildAiMcpTestView(),
      ),
    );
  }

  /// Build the database testing interface
  Widget _buildDatabaseTestView() {
    return Column(
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
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build the AI/MCP testing interface
  Widget _buildAiMcpTestView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mode indicator card
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
                        Icons.smart_toy,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI & MCP ReAct Interface',
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
                    'Ask questions about user health data using AI with ReAct pattern.',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Custom System Prompt section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Custom System Prompt:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _resetCustomPrompt,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Reset to Default'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Edit the AI system prompt. Use placeholders: {user_name}, {user_email}, {user_age}, {user_activity_level}, {user_health_goals}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _customPromptController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your custom system prompt here...',
                      contentPadding: EdgeInsets.all(12),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // User selection dropdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select User Context:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Debug info for users
                  if (_users.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange.shade200),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Loading users... If this persists, check network connectivity.',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    )
                  else
                    Text(
                      'Found ${_users.length} users available',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                      ),
                    ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<UserModel>(
                    value: _users.contains(_selectedUser)
                        ? _selectedUser
                        : null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    hint: _users.isEmpty
                        ? const Text('Loading users...')
                        : const Text('Choose a user for context'),
                    items: _users.isEmpty
                        ? []
                        : _users.map((user) {
                            return DropdownMenuItem<UserModel>(
                              value: user,
                              child: Text(
                                '${user.friendlyName} (${user.activityLevel ?? 'Unknown'})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                    onChanged: (UserModel? newValue) {
                      setState(() {
                        _selectedUser = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Question input area
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Ask a Question:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _questionController.clear();
                          });
                        },
                        icon: const Icon(Icons.clear, size: 20),
                        tooltip: 'Clear question',
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _questionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText:
                          'Ask about the user\'s health data, activity patterns, goals, etc.',
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      // First row: Ask AI and Ask AI Custom buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isAiProcessing || _selectedUser == null
                                  ? null
                                  : () {
                                      print('🔘 Default button pressed!');
                                      _submitQuestion();
                                    },
                              icon: _isAiProcessing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send),
                              label: Text(
                                _isAiProcessing ? 'Processing...' : 'Ask AI',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isAiProcessing || _selectedUser == null
                                  ? null
                                  : () {
                                      print('🟣 Custom button pressed!');
                                      _submitQuestionCustom();
                                    },
                              icon: _isAiProcessing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.psychology),
                              label: Text(
                                _isAiProcessing
                                    ? 'Processing...'
                                    : 'Ask AI Custom',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Second row: Reset button (centered)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _conversationHistory.isEmpty
                              ? null
                              : _resetConversation,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset Conversation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Conversation history (collapsible)
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    _isHistoryExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue,
                  ),
                  title: Text(
                    'Conversation History (${_conversationHistory.length} messages)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: _toggleHistory,
                ),
                if (_isHistoryExpanded) ...[
                  const Divider(height: 1),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: _conversationHistory.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No conversation yet. Ask a question to get started!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : Scrollbar(
                            child: ListView.builder(
                              shrinkWrap: true,
                              reverse: true, // Start from bottom like a chat
                              itemCount: _conversationHistory.length,
                              itemBuilder: (context, index) {
                                // Reverse the index to show newest at bottom
                                final reversedIndex =
                                    _conversationHistory.length - 1 - index;
                                final message =
                                    _conversationHistory[reversedIndex];
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: message.isUser
                                              ? Colors.blue
                                              : Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Icon(
                                          message.isUser
                                              ? Icons.person
                                              : Icons.smart_toy,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: message.isUser
                                                ? Colors.blue.shade50
                                                : Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: message.isUser
                                                  ? Colors.blue.shade200
                                                  : Colors.green.shade200,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                message.message,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
