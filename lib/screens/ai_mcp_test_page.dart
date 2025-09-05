import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/ai_services/service_locator.dart';
import '../services/ai_services/conversation_service.dart';
import '../services/ai_services/openai_service.dart';
import '../services/ai_services/prompt_service.dart';
import '../services/ai_services/user_service.dart';
import '../services/mcp_client_service.dart';
import '../services/custom_prompts_service.dart';
import '../models/user_model.dart';
import '../models/custom_ai_prompt.dart';
import '../widgets/ai_components/user_selection_widget.dart';
import '../widgets/ai_components/question_input_widget.dart';
import '../widgets/ai_components/conversation_history_widget.dart';
import '../widgets/ai_components/custom_prompt_widget.dart';

/// Comprehensive Health Data AI Assistant - AI-powered health analysis with OpenAI integration
class AIMCPTestPage extends StatefulWidget {
  const AIMCPTestPage({super.key});

  @override
  State<AIMCPTestPage> createState() => _AIMCPTestPageState();
}

class _AIMCPTestPageState extends State<AIMCPTestPage> {
  // Service dependencies (Dependency Injection)
  late final ConversationService _conversationService;
  late final OpenAIService _openAIService;
  late final PromptService _promptService;
  late final UserService _userService;

  // UI State (separated from business logic)
  UserModel? _selectedUser;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _customPromptController = TextEditingController();
  final TextEditingController _promptNameController = TextEditingController();
  final ScrollController _conversationScrollController = ScrollController();
  bool _isHistoryExpanded = false;

  // Business State
  bool _isAiProcessing = false;
  List<CustomAiPrompt> _savedPrompts = [];
  CustomAiPrompt? _selectedPrompt;
  bool _isLoadingPrompts = false;
  String _promptStatus = 'Ready';

  // MCP service for health data access
  MCPClientService? _mcpService;

  // Service initialization state
  bool _servicesInitialized = false;

  // Debug logging throttle
  int? _lastDebugTime;

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
9. get_genetic_insights: Get genetic insights and personalized health recommendations based on genetic data analysis

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
    _initializeServices();
    _customPromptController.text = _defaultSystemPrompt;
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

  /// Initialize all services using ServiceLocator (Dependency Injection)
  Future<void> _initializeServices() async {
    try {
      await ServiceLocator().initialize();

      _conversationService = ServiceLocator().conversationService;
      _openAIService = ServiceLocator().openAIService;
      _promptService = ServiceLocator().promptService;
      _userService = ServiceLocator().userService;

      setState(() {
        _servicesInitialized = true;
      });

      if (kDebugMode) {
        print('✅ All services initialized successfully');
      }

      // Load initial user data
      await _loadInitialUser();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize services: $e');
      }
    }
  }

  /// Load initial user data
  Future<void> _loadInitialUser() async {
    try {
      final users = await _userService.getAllUsers();
      if (users.isNotEmpty) {
        setState(() {
          _selectedUser = users.first;
        });
        _initializeMCPService(_selectedUser!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading initial user: $e');
      }
    }
  }

  /// Initialize MCP service for a user
  void _initializeMCPService(UserModel user) {
    _mcpService = MCPClientService(userId: user.id);
    _mcpService!.initialize().then((success) {
      if (success) {
        if (kDebugMode) {
          print('✅ MCP service initialized for user: ${user.friendlyName}');
        }
      } else {
        if (kDebugMode) {
          print(
            '❌ Failed to initialize MCP service for user: ${user.friendlyName}',
          );
        }
      }
    });
  }

  /// Handle user selection change
  void _onUserChanged(UserModel? user) {
    setState(() {
      _selectedUser = user;
      // Clear conversation history when switching users
      _conversationService.clearHistory();
    });

    if (user != null) {
      _initializeMCPService(user);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to user: ${user.friendlyName}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      _mcpService = null;
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
        case 'get_genetic_insights':
          // Call MCP directly for OpenAI function calls
          return await _mcpService!.callMCPFunctionForOpenAI(
            functionName,
            args,
          );
        default:
          return 'Unknown function: $functionName';
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error executing MCP function $functionName: $e');
      }
      return 'Error executing $functionName: $e';
    }
  }

  /// Handle question submission
  Future<void> _onQuestionSubmit() async {
    final question = _questionController.text.trim();
    if (question.isEmpty || _selectedUser == null) return;

    setState(() {
      _isAiProcessing = true;
    });

    try {
      // Add user question to conversation
      _conversationService.addMessage(question, true);

      // Get system prompt
      final systemPrompt = _promptService.getSystemPrompt(
        customPrompt: _customPromptController.text.trim(),
        selectedUser: _selectedUser,
      );

      // Call OpenAI service
      final response = await _openAIService.callOpenAI(
        userMessage: question,
        systemPrompt: systemPrompt,
        conversationContext: _conversationService.getConversationContext(),
        executeMCPFunction: _executeMCPFunction,
      );

      // Add AI response to conversation
      _conversationService.addMessage(response, false);

      _questionController.clear();

      if (kDebugMode) {
        print('✅ AI response received successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error with AI request: $e');
      }
      _conversationService.addMessage(
        'Sorry, there was an error processing your request: $e',
        false,
      );
    } finally {
      setState(() {
        _isAiProcessing = false;
      });
    }
  }

  /// Handle cancel AI request
  void _onCancelAiRequest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Request cancellation requested - please wait for current request to complete',
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
    if (kDebugMode) {
      print('🔄 AI request cancellation requested by user');
    }
  }

  /// Load saved prompts
  Future<void> _loadSavedPrompts() async {
    setState(() {
      _isLoadingPrompts = true;
      _promptStatus = 'Loading saved prompts...';
    });

    try {
      final prompts = await CustomPromptsService.getCustomPrompts(
        'goal_setting',
      );
      setState(() {
        _savedPrompts = prompts;
        _promptStatus = 'Loaded ${prompts.length} saved prompts';
      });
      if (kDebugMode) {
        print('✅ Loaded ${prompts.length} saved prompts');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading saved prompts: $e');
      }
      setState(() {
        _promptStatus = 'Error loading prompts: $e';
      });
    } finally {
      setState(() {
        _isLoadingPrompts = false;
      });
    }
  }

  /// Save current prompt
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
        await _loadSavedPrompts();
        _promptNameController.clear();
        setState(() {
          _promptStatus = 'Prompt saved successfully!';
        });
        if (kDebugMode) {
          print('✅ Saved custom prompt: ${savedPrompt.promptName}');
        }
      } else {
        setState(() {
          _promptStatus = 'Failed to save prompt';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving prompt: $e');
      }
      setState(() {
        _promptStatus = 'Error saving prompt: $e';
      });
    } finally {
      setState(() {
        _isLoadingPrompts = false;
      });
    }
  }

  /// Load selected prompt
  void _loadSelectedPrompt(CustomAiPrompt? prompt) {
    setState(() {
      _selectedPrompt = prompt;
      if (prompt != null) {
        _customPromptController.text = prompt.promptText;
        _promptStatus = 'Loaded prompt: ${prompt.promptName}';
      }
    });
    if (kDebugMode && prompt != null) {
      print('✅ Loaded prompt: ${prompt.promptName}');
    }
  }

  /// Delete saved prompt
  Future<void> _deleteSavedPrompt(CustomAiPrompt prompt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prompt'),
        content: Text(
          'Are you sure you want to delete "${prompt.promptName}"?',
        ),
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
        await _loadSavedPrompts();
        if (_selectedPrompt?.id == prompt.id) {
          setState(() {
            _selectedPrompt = null;
          });
        }
        setState(() {
          _promptStatus = 'Prompt deleted successfully';
        });
        if (kDebugMode) {
          print('✅ Deleted prompt: ${prompt.promptName}');
        }
      } else {
        setState(() {
          _promptStatus = 'Failed to delete prompt';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting prompt: $e');
      }
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
    if (kDebugMode) {
      print('🔄 Reset custom prompt to default');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isWideScreen = screenWidth > 800;

        // Debug logging for web deployment (throttled to reduce spam)
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        if (_lastDebugTime == null || currentTime - _lastDebugTime! > 1000) {
          if (kDebugMode) {
            print(
              '📱 LayoutBuilder dimensions: ${screenWidth.toInt()}x${constraints.maxHeight.toInt()}, isWideScreen: $isWideScreen',
            );
          }
          _lastDebugTime = currentTime;
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: isWideScreen
              ? Container(
                  key: const ValueKey('wide'),
                  child: _buildWideLayout(constraints),
                )
              : Container(
                  key: const ValueKey('narrow'),
                  child: _buildNarrowLayout(constraints),
                ),
        );
      },
    );
  }

  Widget _buildWideLayout(BoxConstraints constraints) {
    // Check if services are initialized
    if (!_servicesInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final availableHeight = constraints.maxHeight - kToolbarHeight - 32;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: availableHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Custom prompt
            Expanded(
              flex: 1,
              child: CustomPromptWidget(
                promptController: _customPromptController,
                promptNameController: _promptNameController,
                promptStatus: _promptStatus,
                onResetPrompt: _resetCustomPrompt,
                onSavePrompt: _saveCurrentPrompt,
                onLoadPrompts: _loadSavedPrompts,
                isLoadingPrompts: _isLoadingPrompts,
                savedPrompts: _savedPrompts,
                selectedPrompt: _selectedPrompt,
                onPromptSelected: _loadSelectedPrompt,
                onDeletePrompt: _deleteSavedPrompt,
              ),
            ),
            const SizedBox(width: 24),
            // Right column - User selection, conversation history and question input
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  UserSelectionWidget(
                    selectedUser: _selectedUser,
                    onUserChanged: _onUserChanged,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ConversationHistoryWidget(
                      messages: _conversationService.messages,
                      scrollController: _conversationScrollController,
                      onClearHistory: () =>
                          setState(() => _conversationService.clearHistory()),
                      isExpanded: _isHistoryExpanded,
                      onExpandedChanged: (expanded) =>
                          setState(() => _isHistoryExpanded = expanded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  QuestionInputWidget(
                    controller: _questionController,
                    selectedUser: _selectedUser,
                    isProcessing: _isAiProcessing,
                    onSubmit: _onQuestionSubmit,
                    onCancel: _onCancelAiRequest,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BoxConstraints constraints) {
    // Check if services are initialized
    if (!_servicesInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final availableHeight = constraints.maxHeight - kToolbarHeight - 32;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: availableHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserSelectionWidget(
              selectedUser: _selectedUser,
              onUserChanged: _onUserChanged,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, // Fixed height for question input
              child: QuestionInputWidget(
                controller: _questionController,
                selectedUser: _selectedUser,
                isProcessing: _isAiProcessing,
                onSubmit: _onQuestionSubmit,
                onCancel: _onCancelAiRequest,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300, // Fixed height for conversation history
              child: ConversationHistoryWidget(
                messages: _conversationService.messages,
                scrollController: _conversationScrollController,
                onClearHistory: () =>
                    setState(() => _conversationService.clearHistory()),
                isExpanded: _isHistoryExpanded,
                onExpandedChanged: (expanded) =>
                    setState(() => _isHistoryExpanded = expanded),
                useConstrainedLayout: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400, // Fixed height for custom prompt
              child: CustomPromptWidget(
                promptController: _customPromptController,
                promptNameController: _promptNameController,
                promptStatus: _promptStatus,
                onResetPrompt: _resetCustomPrompt,
                onSavePrompt: _saveCurrentPrompt,
                onLoadPrompts: _loadSavedPrompts,
                isLoadingPrompts: _isLoadingPrompts,
                savedPrompts: _savedPrompts,
                selectedPrompt: _selectedPrompt,
                onPromptSelected: _loadSelectedPrompt,
                onDeletePrompt: _deleteSavedPrompt,
                useConstrainedLayout: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
