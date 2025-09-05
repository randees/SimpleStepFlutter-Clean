import 'package:flutter/foundation.dart';
import 'conversation_service.dart';
import 'openai_service.dart';
import 'prompt_service.dart';
import 'user_service.dart';

/// Service locator for managing all AI services and dependencies
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  // Service instances
  late final ConversationService _conversationService;
  late final OpenAIService _openAIService;
  late final PromptService _promptService;
  late final UserService _userService;

  // Initialization flag
  bool _isInitialized = false;

  /// Initialize all services
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('🔄 ServiceLocator: Already initialized');
      }
      return;
    }

    if (kDebugMode) {
      print('🚀 ServiceLocator: Initializing services...');
    }

    try {
      // SupabaseService is already initialized in main.dart
      // Just initialize the AI services
      _conversationService = ConversationService();
      _openAIService = OpenAIService();
      _promptService = PromptService();
      _userService = UserService();

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ ServiceLocator: All services initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ServiceLocator: Initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Get conversation service
  ConversationService get conversationService {
    if (kDebugMode) {
      print('🔍 ServiceLocator: Getting conversation service, initialized: $_isInitialized');
    }
    _ensureInitialized();
    if (kDebugMode) {
      print('✅ ServiceLocator: Returning conversation service: $_conversationService');
    }
    return _conversationService;
  }

  /// Get OpenAI service
  OpenAIService get openAIService {
    _ensureInitialized();
    return _openAIService;
  }

  /// Get prompt service
  PromptService get promptService {
    _ensureInitialized();
    return _promptService;
  }

  /// Get user service
  UserService get userService {
    _ensureInitialized();
    return _userService;
  }

  /// Ensure services are initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'ServiceLocator not initialized. Call initialize() first.',
      );
    }
  }

  /// Reset all services (useful for testing)
  void reset() {
    _isInitialized = false;
    if (kDebugMode) {
      print('🔄 ServiceLocator: Reset completed');
    }
  }

  /// Get service status
  Map<String, bool> getServiceStatus() {
    return {
      'initialized': _isInitialized,
      'supabase': _isInitialized,
      'conversation': _isInitialized,
      'openai': _isInitialized,
      'prompt': _isInitialized,
      'user': _isInitialized,
    };
  }
}
