import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/supabase_service.dart';
import '../models/user_model.dart';
import '../utils/app_icons.dart';
import '../config/openai_config.dart';

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

/// AI/MCP Testing page - Test OpenAI integration with custom prompts and user context
class AIMCPTestPage extends StatefulWidget {
  const AIMCPTestPage({super.key});

  @override
  State<AIMCPTestPage> createState() => _AIMCPTestPageState();
}

class _AIMCPTestPageState extends State<AIMCPTestPage> {
  // AI Chat state variables
  UserModel? _selectedUser;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _customPromptController = TextEditingController();
  List<ChatMessage> _conversationHistory = [];
  bool _isAiProcessing = false;
  bool _isHistoryExpanded = false;
  List<UserModel> _users = [];
  bool _isLoading = false;

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
    // Load users for AI testing
    _loadUsersForAi();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }

  /// Load users from database for AI testing context
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
          weightKg: 82.5,
        ),
        UserModel(
          id: 'mock-sarah',
          email: 'sarah.davis@example.com',
          displayName: 'Sarah Davis',
          activityLevel: 'Very Active',
          healthGoals: ['Build Endurance', 'Maintain Weight'],
          dateOfBirth: DateTime(1995, 8, 22),
          gender: 'Female',
          heightCm: 165,
          weightKg: 58.0,
        ),
        UserModel(
          id: 'mock-mike',
          email: 'mike.chen@example.com',
          displayName: 'Mike Chen',
          activityLevel: 'Lightly Active',
          healthGoals: ['Improve Health', 'Lose Weight'],
          dateOfBirth: DateTime(1985, 3, 10),
          gender: 'Male',
          heightCm: 175,
          weightKg: 88.2,
        ),
      ];

      setState(() {
        _users = mockUsers;
        _selectedUser = mockUsers.first;
        _isLoading = false;
      });
      print('⚠️ Using mock users for AI testing (network unavailable)');
    }
  }

  /// Reset custom prompt to default
  void _resetCustomPrompt() {
    setState(() {
      _customPromptController.text = _defaultSystemPrompt;
    });
    print('🔄 Reset custom prompt to default');
  }

  /// Submit question with custom system prompt
  Future<void> _submitQuestionCustom() async {
    final question = _questionController.text.trim();
    final customPrompt = _customPromptController.text.trim();

    if (question.isEmpty) {
      print('❌ Custom question is empty');
      return;
    }

    if (_selectedUser == null) {
      print('❌ No user selected for context');
      return;
    }

    setState(() {
      _isAiProcessing = true;
    });

    try {
      print('🔄 Submitting custom question: "$question"');
      print('🔄 Using custom prompt: ${customPrompt.substring(0, 100)}...');
      print('🔄 For user: ${_selectedUser!.friendlyName}');

      // Add user question to history
      _conversationHistory.add(
        ChatMessage(message: question, isUser: true, timestamp: DateTime.now()),
      );

      final systemPrompt = _buildSystemPromptWithUserContext(
        _selectedUser!,
        customPrompt,
      );

      final response = await _callOpenAI(question, systemPrompt);

      // Add AI response to history
      _conversationHistory.add(
        ChatMessage(
          message: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );

      print('✅ Custom AI response received successfully');
    } catch (e) {
      print('❌ Error with custom AI request: $e');
      // Add error to conversation history
      _conversationHistory.add(
        ChatMessage(
          message: 'Sorry, there was an error processing your request: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      setState(() {
        _isAiProcessing = false;
      });
    }
  }

  /// Submit question using default system prompt
  Future<void> _submitQuestion() async {
    final question = _questionController.text.trim();

    if (question.isEmpty) {
      print('❌ Question is empty');
      return;
    }

    if (_selectedUser == null) {
      print('❌ No user selected for context');
      return;
    }

    setState(() {
      _isAiProcessing = true;
    });

    try {
      print('🔄 Submitting question: "$question"');
      print('🔄 For user: ${_selectedUser!.friendlyName}');

      // Add user question to history
      _conversationHistory.add(
        ChatMessage(message: question, isUser: true, timestamp: DateTime.now()),
      );

      final systemPrompt = _buildSystemPromptWithUserContext(
        _selectedUser!,
        _defaultSystemPrompt,
      );

      final response = await _callOpenAI(question, systemPrompt);

      // Add AI response to history
      _conversationHistory.add(
        ChatMessage(
          message: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );

      print('✅ AI response received successfully');
    } catch (e) {
      print('❌ Error with AI request: $e');
      // Add error to conversation history
      _conversationHistory.add(
        ChatMessage(
          message: 'Sorry, there was an error processing your request: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      setState(() {
        _isAiProcessing = false;
      });
    }
  }

  /// Build system prompt with user context
  String _buildSystemPromptWithUserContext(UserModel user, String basePrompt) {
    return basePrompt
        .replaceAll('{user_name}', user.friendlyName)
        .replaceAll('{user_email}', user.email)
        .replaceAll(
          '{user_age}',
          user.dateOfBirth != null
              ? (DateTime.now().year - user.dateOfBirth!.year).toString()
              : 'Unknown',
        )
        .replaceAll('{user_activity_level}', user.activityLevel ?? 'Unknown')
        .replaceAll(
          '{user_health_goals}',
          user.healthGoals?.join(', ') ?? 'None specified',
        );
  }

  /// Call OpenAI API with system prompt and user question
  Future<String> _callOpenAI(String userMessage, String systemPrompt) async {
    final apiKey = OpenAIConfig.apiKey;
    const apiUrl = 'https://api.openai.com/v1/chat/completions';

    // Validate API key
    if (apiKey.isEmpty || apiKey == 'REPLACE_WITH_YOUR_OPENAI_API_KEY') {
      return 'Error: OpenAI API key not configured. Please set OPENAI_API_KEY in your .env file.';
    }

    if (!OpenAIConfig.hasValidApiKeyFormat) {
      return 'Error: Invalid OpenAI API key format. Please check your OPENAI_API_KEY in the .env file.';
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = json.encode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userMessage},
      ],
      'max_tokens': 500,
      'temperature': 0.7,
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'] ?? 'No response';
      } else {
        print('OpenAI API Error: ${response.statusCode} - ${response.body}');
        return 'Error: Unable to get AI response. Status: ${response.statusCode}';
      }
    } catch (e) {
      print('Network Error: $e');
      return 'Error: Network issue connecting to AI service.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI/MCP Testing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.brain(),
                          color: Colors.purple.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI/MCP Testing',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Test OpenAI integration with custom prompts and user context. Uses ReAct (Reasoning and Acting) approach for health data analysis.',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // User Selection
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            'e.g., "How is my step count progress this week?"',
                        contentPadding: EdgeInsets.all(12),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isAiProcessing || _selectedUser == null
                                ? null
                                : _submitQuestion,
                            child: _isAiProcessing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Ask AI'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isAiProcessing || _selectedUser == null
                                ? null
                                : _submitQuestionCustom,
                            icon: const Icon(Icons.psychology, size: 16),
                            label: const Text('Ask AI Custom'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade100,
                              foregroundColor: Colors.purple.shade700,
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

            // Custom Prompt Section
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
                        TextButton.icon(
                          onPressed: _resetCustomPrompt,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reset'),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customPromptController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your custom system prompt...',
                        contentPadding: EdgeInsets.all(12),
                      ),
                      maxLines: 8,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Conversation History
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Conversation History:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (_conversationHistory.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _conversationHistory.clear();
                              });
                            },
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text('Clear'),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red.shade100,
                              foregroundColor: Colors.red.shade700,
                            ),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isHistoryExpanded = !_isHistoryExpanded;
                            });
                          },
                          icon: Icon(
                            _isHistoryExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                          ),
                          tooltip: _isHistoryExpanded
                              ? 'Collapse history'
                              : 'Expand history',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_conversationHistory.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'No conversation yet. Ask a question to get started!',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: _isHistoryExpanded ? 400 : 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: _conversationHistory.length,
                          itemBuilder: (context, index) {
                            final message = _conversationHistory[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: message.isUser
                                    ? Colors.blue.shade50
                                    : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: message.isUser
                                      ? Colors.blue.shade200
                                      : Colors.green.shade200,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        message.isUser
                                            ? Icons.person
                                            : Icons.psychology,
                                        size: 16,
                                        color: message.isUser
                                            ? Colors.blue.shade600
                                            : Colors.green.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        message.isUser ? 'You' : 'AI Assistant',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: message.isUser
                                              ? Colors.blue.shade600
                                              : Colors.green.shade600,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(message.message),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
