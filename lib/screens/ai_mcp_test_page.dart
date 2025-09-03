import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../services/mcp_client_service.dart';
import '../services/custom_prompts_service.dart';
import '../models/user_model.dart';
import '../models/openai_function.dart';
import '../models/custom_ai_prompt.dart';
import '../config/openai_config.dart';
import '../widgets/user_management_modal.dart';

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

/// Comprehensive Health Data AI Assistant - AI-powered health analysis with OpenAI integration
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
  final TextEditingController _promptNameController = TextEditingController();
  final ScrollController _conversationScrollController = ScrollController();
  List<ChatMessage> _conversationHistory = [];
  bool _isAiProcessing = false;
  bool _isHistoryExpanded = false;
  List<UserModel> _users = [];
  bool _isLoading = false;

  // Custom prompts state
  List<CustomAiPrompt> _savedPrompts = [];
  CustomAiPrompt? _selectedPrompt;
  bool _isLoadingPrompts = false;
  String _promptStatus = 'Ready';

  // MCP service for health data access
  MCPClientService? _mcpService;

  // Default system prompt
  static const String _defaultSystemPrompt =
      '''You are a certified health provider and fitness trainer who cares deeply about helping people improve their health and wellness. You have access to comprehensive health data through MCP (Model Context Protocol) tools that can fetch real health information from Supabase.

Your personality and approach:
- Speak in a warm, encouraging, and professional tone
- Use motivational language that inspires positive action
- Provide specific, actionable health and fitness advice
- Celebrate progress and achievements, no matter how small
- Offer gentle guidance when improvements are needed
- Use "you" and "your" to make responses personal and engaging
- Include practical tips and suggestions for better health outcomes

IMPORTANT: You have access to the following comprehensive health data tools:
1. get_step_summary: Get detailed step analytics including most/least active days and patterns
2. get_activity_patterns: Get weekly activity patterns and trends
3. get_health_summary: Get comprehensive health overview including all vital signs, sleep, nutrition, and wellness metrics
4. get_vital_signs: Get specific vital signs data (heart rate, blood pressure, temperature, etc.)
5. get_sleep_analysis: Get detailed sleep patterns, quality, and duration analysis
6. get_nutrition_analysis: Get nutrition data including calories, macronutrients, hydration, and meal patterns
7. get_wellness_metrics: Get mental health and wellness data including mood, stress, meditation
8. get_health_insights: Get AI-generated health insights, recommendations, and personalized advice

CRITICAL USER IDENTIFICATION FOR MCP FUNCTIONS:
- Primary User ID (UUID): {user_id}
- Fallback User Email: {user_email}
- When calling MCP functions, always use the UUID ({user_id}) as the userId parameter
- If UUID fails, the system will automatically fall back to email resolution

IMPORTANT DATE CONTEXT:
- Today's date: {current_date}
- When users ask for recent data, use the last 7-30 days from today depending on the data type
- When users ask for broad historical data, use from beginning of time (earliest available data) to today
- Always default to current and recent data unless told otherwise

Current client context:
- Name: {user_name}
- Email: {user_email}
- User ID: {user_id}
- Age: {user_age}
- Activity Level: {user_activity_level}
- Health Goals: {user_health_goals}

When users ask about their health data, step counts, activity patterns, sleep, nutrition, vital signs, wellness, or fitness progress, you MUST call the appropriate function to get their actual data before providing advice. Don't make assumptions - always fetch real data first.

Use a ReAct (Reasoning and Acting) approach:
1. Think about what health data you need to provide the best guidance
2. Act by calling the appropriate function (start with get_health_summary for general questions, then use specific functions for detailed analysis)
3. Observe the results and analyze patterns
4. Provide encouraging, actionable health advice based on their REAL data

Always respond as if you're speaking directly to your client in a supportive consultation. Keep responses under 1000 characters when possible.''';

  @override
  void initState() {
    super.initState();
    // Initialize custom prompt with default
    _customPromptController.text = _defaultSystemPrompt;
    // Load users for AI testing
    _loadUsersForAi();
    // Load saved prompts
    _loadSavedPrompts();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _customPromptController.dispose();
    _promptNameController.dispose();
    _conversationScrollController.dispose();
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

        // Initialize MCP service for the default user
        if (_selectedUser != null) {
          _mcpService = MCPClientService(userId: _selectedUser!.id);
          _mcpService!.initialize().then((success) {
            if (success) {
              print(
                '✅ MCP service initialized for default user: ${_selectedUser!.friendlyName}',
              );
            } else {
              print(
                '❌ Failed to initialize MCP service for default user: ${_selectedUser!.friendlyName}',
              );
            }
          });
        }
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

        // Initialize MCP service for the mock user
        _mcpService = MCPClientService(userId: _selectedUser!.id);
        _mcpService!.initialize().then((success) {
          if (success) {
            print(
              '✅ MCP service initialized for mock user: ${_selectedUser!.friendlyName}',
            );
          } else {
            print(
              '❌ Failed to initialize MCP service for mock user: ${_selectedUser!.friendlyName}',
            );
          }
        });
      });
      print('⚠️ Using mock users for AI testing (network unavailable)');
    }
  }

  /// Scroll to the bottom of conversation history
  void _scrollToBottom() {
    if (_conversationScrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _conversationScrollController.animateTo(
          _conversationScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  /// Load saved custom prompts from database
  Future<void> _loadSavedPrompts() async {
    setState(() {
      _isLoadingPrompts = true;
      _promptStatus = 'Loading saved prompts...';
    });

    try {
      final prompts = await CustomPromptsService.getCustomPrompts('goal_setting');
      setState(() {
        _savedPrompts = prompts;
        _promptStatus = 'Loaded ${prompts.length} saved prompts';
      });
      print('✅ Loaded ${prompts.length} saved prompts');
    } catch (e) {
      print('❌ Error loading saved prompts: $e');
      setState(() {
        _promptStatus = 'Error loading prompts: $e';
      });
    } finally {
      setState(() {
        _isLoadingPrompts = false;
      });
    }
  }

  /// Save current custom prompt to database
  Future<void> _saveCurrentPrompt() async {
    final promptName = _promptNameController.text.trim();
    final promptText = _customPromptController.text.trim();

    if (promptName.isEmpty) {
      setState(() {
        _promptStatus = 'Please enter a prompt name';
      });
      return;
    }

    if (promptText.isEmpty) {
      setState(() {
        _promptStatus = 'Please enter prompt text';
      });
      return;
    }

    setState(() {
      _isLoadingPrompts = true;
      _promptStatus = 'Saving prompt...';
    });

    try {
      final savedPrompt = await CustomPromptsService.createCustomPrompt(
        promptTypeId: 'goal_setting',
        promptText: promptText,
        promptName: promptName,
      );

      if (savedPrompt != null) {
        await _loadSavedPrompts(); // Refresh the list
        _promptNameController.clear();
        setState(() {
          _promptStatus = 'Prompt saved successfully!';
        });
        print('✅ Saved custom prompt: ${savedPrompt.promptName}');
      } else {
        setState(() {
          _promptStatus = 'Failed to save prompt';
        });
      }
    } catch (e) {
      print('❌ Error saving prompt: $e');
      setState(() {
        _promptStatus = 'Error saving prompt: $e';
      });
    } finally {
      setState(() {
        _isLoadingPrompts = false;
      });
    }
  }

  /// Load selected prompt into the editor
  void _loadSelectedPrompt(CustomAiPrompt prompt) {
    setState(() {
      _selectedPrompt = prompt;
      _customPromptController.text = prompt.promptText;
      _promptStatus = 'Loaded prompt: ${prompt.promptName}';
    });
    print('� Loaded prompt: ${prompt.promptName}');
  }

  /// Delete a saved prompt
  Future<void> _deleteSavedPrompt(CustomAiPrompt prompt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prompt'),
        content: Text('Are you sure you want to delete "${prompt.promptName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoadingPrompts = true;
      _promptStatus = 'Deleting prompt...';
    });

    try {
      final success = await CustomPromptsService.deleteCustomPrompt(prompt.id);
      if (success) {
        await _loadSavedPrompts(); // Refresh the list
        if (_selectedPrompt?.id == prompt.id) {
          setState(() {
            _selectedPrompt = null;
          });
        }
        setState(() {
          _promptStatus = 'Prompt deleted successfully';
        });
        print('✅ Deleted prompt: ${prompt.promptName}');
      } else {
        setState(() {
          _promptStatus = 'Failed to delete prompt';
        });
      }
    } catch (e) {
      print('❌ Error deleting prompt: $e');
      setState(() {
        _promptStatus = 'Error deleting prompt: $e';
      });
    } finally {
      setState(() {
        _isLoadingPrompts = false;
      });
    }
  }

  /// Reset custom prompt to default
  void _resetCustomPrompt() {
    setState(() {
      _customPromptController.text = _defaultSystemPrompt;
      _selectedPrompt = null;
      _promptStatus = 'Reset to default prompt';
    });
    print('🔄 Reset custom prompt to default');
  }

  /// Show user management modal
  void _showUserManagementModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserManagementModal(
        onUserSelected: (UserModel user) {
          setState(() {
            _selectedUser = user;
            // Initialize MCP service for the selected user
            _mcpService = MCPClientService(userId: user.id);
            _mcpService!.initialize().then((success) {
              if (success) {
                print(
                  '✅ MCP service initialized for user: ${user.friendlyName}',
                );
              } else {
                print(
                  '❌ Failed to initialize MCP service for user: ${user.friendlyName}',
                );
              }
            });
          });
          // Modal now handles closing itself
        },
      ),
    );
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

      // Clear the question input field
      _questionController.clear();

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

      // Scroll to bottom to show new message
      _scrollToBottom();

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

      // Scroll to bottom to show new message
      _scrollToBottom();
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

      // Clear the question input field
      _questionController.clear();

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

      // Scroll to bottom to show new message
      _scrollToBottom();

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

      // Scroll to bottom to show new message
      _scrollToBottom();
    } finally {
      setState(() {
        _isAiProcessing = false;
      });
    }
  }

  /// Build system prompt with user context
  String _buildSystemPromptWithUserContext(UserModel user, String basePrompt) {
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final finalPrompt = basePrompt
        .replaceAll('{current_date}', currentDate)
        .replaceAll('{user_name}', user.friendlyName)
        .replaceAll('{user_email}', user.email)
        .replaceAll('{user_id}', user.id)
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

    print('🔍 Final System Prompt:');
    print('📝 User UUID: ${user.id}');
    print('📧 User Email: ${user.email}');
    print('👤 User Name: ${user.friendlyName}');
    print('📄 Full System Prompt:\n$finalPrompt');
    return finalPrompt;
  }

  /// Call OpenAI API with ReAct pattern and MCP function calling
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

    if (_mcpService == null) {
      return 'Error: No user selected for health data access. Please select a user first.';
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    // Define available tools for OpenAI (using the new tools format)
    final tools = HealthDataFunctions.getAllFunctions()
        .map((f) => {'type': 'function', 'function': f.toJson()})
        .toList();

    // Initial conversation with system prompt and user message
    List<Map<String, dynamic>> messages = [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userMessage},
    ];

    try {
      // Start ReAct conversation loop (max 5 iterations to prevent infinite loops)
      for (int iteration = 0; iteration < 5; iteration++) {
        print('🔄 ReAct iteration ${iteration + 1}');

        final body = json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'tools': tools,
          'tool_choice': 'auto',
          'max_tokens': 500,
          'temperature': 0.7,
        });

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: body,
        );

        if (response.statusCode != 200) {
          print('OpenAI API Error: ${response.statusCode} - ${response.body}');
          return 'Error: Unable to get AI response. Status: ${response.statusCode}';
        }

        final data = json.decode(response.body);
        final choice = data['choices'][0];
        final message = choice['message'];

        // Add AI response to conversation
        messages.add(message);

        // Check if AI wants to call a tool
        if (message['tool_calls'] != null && message['tool_calls'].isNotEmpty) {
          final toolCalls = message['tool_calls'] as List;

          // Process each tool call
          for (final toolCall in toolCalls) {
            final toolCallId = toolCall['id'];
            final function = toolCall['function'];
            final functionName = function['name'];
            final functionArgs = json.decode(function['arguments']);

            print(
              '🔧 AI is calling function: $functionName with args: $functionArgs',
            );

            // Call the appropriate MCP function
            String functionResult = await _executeMCPFunction(
              functionName,
              functionArgs,
            );

            // Add function result to conversation
            messages.add({
              'role': 'tool',
              'tool_call_id': toolCallId,
              'content': functionResult,
            });

            print(
              '📊 Function result: ${functionResult.length > 100 ? functionResult.substring(0, 100) + "..." : functionResult}',
            );
          }
        } else {
          // AI provided final response without tool call
          final finalResponse = message['content'] ?? 'No response';
          print('✅ AI provided final response');
          return finalResponse;
        }
      }

      return 'I gathered some health data but ran into processing limits. Please try asking a more specific question.';
    } catch (e) {
      print('Network Error: $e');
      return 'Error: Network issue connecting to AI service.';
    }
  }

  /// Execute MCP function based on function name and arguments
  Future<String> _executeMCPFunction(
    String functionName,
    Map<String, dynamic> args,
  ) async {
    if (_mcpService == null) {
      return 'Error: MCP service not initialized';
    }

    try {
      switch (functionName) {
        case 'get_step_summary':
        case 'get_activity_patterns':
        case 'get_health_summary':
        case 'get_vital_signs':
        case 'get_sleep_analysis':
        case 'get_nutrition_analysis':
        case 'get_wellness_metrics':
        case 'get_health_insights':
          // Call MCP directly for OpenAI function calls
          return await _mcpService!.callMCPFunctionForOpenAI(
            functionName,
            args,
          );

        default:
          return 'Unknown function: $functionName';
      }
    } catch (e) {
      print('❌ Error executing MCP function $functionName: $e');
      return 'Error executing $functionName: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 900;

    return isWideScreen
        ? _buildWideLayoutWithHeight(context)
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _buildNarrowLayout(),
          );
  }

  /// Build wide layout with bounded height
  Widget _buildWideLayoutWithHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Calculate available height (screen height minus app bar and padding)
    final availableHeight =
        screenHeight - kToolbarHeight - 32; // 32 for padding

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(height: availableHeight, child: _buildWideLayout()),
    );
  }

  /// Build layout for narrow screens (mobile/tablet)
  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserSelectionCard(),
        const SizedBox(height: 16),
        _buildConversationHistoryCard(),
        const SizedBox(height: 16),
        _buildQuestionInputCard(),
        const SizedBox(height: 16),
        _buildCustomPromptCard(),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Build layout for wide screens (desktop)
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - User selection and custom prompt
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserSelectionCard(),
              const SizedBox(height: 16),
              Expanded(child: _buildCustomPromptCard()),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right column - Conversation history and question input
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(child: _buildConversationHistoryCard()),
              const SizedBox(height: 16),
              _buildQuestionInputCard(),
            ],
          ),
        ),
      ],
    );
  }

  /// Build user selection card
  Widget _buildUserSelectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select User Context:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _showUserManagementModal,
                  icon: const Icon(Icons.people, size: 18),
                  label: const Text('User Management'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                style: TextStyle(fontSize: 12, color: Colors.green.shade600),
              ),
            const SizedBox(height: 8),
            DropdownButtonFormField<UserModel>(
              initialValue: _users.contains(_selectedUser) ? _selectedUser : null,
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
                  // Initialize MCP service for the selected user
                  if (newValue != null) {
                    _mcpService = MCPClientService(userId: newValue.id);
                    _mcpService!.initialize().then((success) {
                      if (success) {
                        print(
                          '✅ MCP service initialized for user: ${newValue.friendlyName}',
                        );
                      } else {
                        print(
                          '❌ Failed to initialize MCP service for user: ${newValue.friendlyName}',
                        );
                      }
                    });
                  } else {
                    _mcpService = null;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build question input card
  Widget _buildQuestionInputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Ask a Health Question:',
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
                    'e.g., "How is my overall health this week?" or "Show me my sleep patterns"',
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
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Ask Health AI'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isAiProcessing || _selectedUser == null
                        ? null
                        : _submitQuestionCustom,
                    icon: const Icon(Icons.psychology, size: 16),
                    label: const Text('Ask Health AI Custom'),
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
    );
  }

  /// Build custom prompt card
  Widget _buildCustomPromptCard() {
    return Card(
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

            // Status message
            if (_promptStatus.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _promptStatus.contains('Error')
                      ? Colors.red.shade50
                      : _promptStatus.contains('success')
                      ? Colors.green.shade50
                      : Colors.blue.shade50,
                  border: Border.all(
                    color: _promptStatus.contains('Error')
                        ? Colors.red.shade200
                        : _promptStatus.contains('success')
                        ? Colors.green.shade200
                        : Colors.blue.shade200,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _promptStatus,
                  style: TextStyle(
                    fontSize: 12,
                    color: _promptStatus.contains('Error')
                        ? Colors.red.shade700
                        : _promptStatus.contains('success')
                        ? Colors.green.shade700
                        : Colors.blue.shade700,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Saved Prompts Section
            Row(
              children: [
                const Text(
                  'Saved Prompts:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _isLoadingPrompts ? null : _loadSavedPrompts,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Saved prompts dropdown
            if (_savedPrompts.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<CustomAiPrompt>(
                  value: _selectedPrompt,
                  hint: const Text('Select a saved prompt'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _savedPrompts.map((prompt) {
                    return DropdownMenuItem<CustomAiPrompt>(
                      value: prompt,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              prompt.promptName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _deleteSavedPrompt(prompt),
                            icon: const Icon(Icons.delete, size: 16),
                            color: Colors.red.shade400,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (CustomAiPrompt? prompt) {
                    if (prompt != null) {
                      _loadSelectedPrompt(prompt);
                    }
                  },
                ),
              )
            else if (_isLoadingPrompts)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No saved prompts yet. Create and save your first custom prompt!',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Save Current Prompt Section
            const Text(
              'Save Current Prompt:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Prompt name input
            TextField(
              controller: _promptNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a name for this prompt...',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 8),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoadingPrompts ? null : _saveCurrentPrompt,
                icon: _isLoadingPrompts
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save, size: 16),
                label: const Text('Save Current Prompt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.green.shade700,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Prompt Editor Section
            const Text(
              'Prompt Editor:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Current prompt info
            if (_selectedPrompt != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Editing: ${_selectedPrompt!.promptName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedPrompt = null;
                        });
                      },
                      icon: const Icon(Icons.clear, size: 16),
                      color: Colors.blue.shade600,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Prompt text editor
            Expanded(
              child: TextField(
                controller: _customPromptController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your custom system prompt...',
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build conversation history card
  Widget _buildConversationHistoryCard() {
    return Card(
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
                    _isHistoryExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  tooltip: _isHistoryExpanded
                      ? 'Collapse history'
                      : 'Expand history',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _conversationHistory.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'No health conversation yet. Ask a question about your health data to get started!',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        controller: _conversationScrollController,
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
            ),
          ],
        ),
      ),
    );
  }
}
