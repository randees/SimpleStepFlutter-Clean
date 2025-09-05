import 'package:flutter/material.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import '../conversation_history_service.dart';

/// Model for chat messages
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

/// Service for managing conversation history
class ConversationService {
  final List<ChatMessage> _messages = [];
  final ScrollController scrollController = ScrollController();
  ConversationHistoryService? _historyService;
  final Uuid _uuid = Uuid();

  // Current session ID for grouping messages
  String? _currentSessionId;
  String? _currentUserId;

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  int get messageCount => _messages.length;

  bool get isEmpty => _messages.isEmpty;

  /// Get the history service (lazy-loaded)
  ConversationHistoryService get _getHistoryService {
    _historyService ??= ConversationHistoryService();
    return _historyService!;
  }

  /// Initialize the service with user context
  void initialize(String userId) {
    print('🚀 [CONVERSATION SERVICE] Initializing with user: $userId');
    _currentUserId = userId;
    _currentSessionId = _generateSessionId();
    print('🚀 [CONVERSATION SERVICE] Generated session ID: $_currentSessionId');
    print('✅ [CONVERSATION SERVICE] Initialization complete');
  }

  /// Load conversation history from database
  Future<void> loadConversationHistory({int limit = 20}) async {
    print('📚 [LOAD HISTORY] Starting conversation history load...');
    print('📚 [LOAD HISTORY] Requested limit: $limit');

    if (_currentUserId == null) {
      print('⚠️ [LOAD HISTORY] No user ID available, cannot load history');
      return;
    }

    print('📚 [LOAD HISTORY] Loading history for user: $_currentUserId');

    try {
      final historyMessages = await _getHistoryService
          .getUserConversationHistory(_currentUserId!, limit: limit)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏰ [LOAD HISTORY] Timeout loading conversation history');
              return [];
            },
          );

      print(
        '📚 [LOAD HISTORY] Retrieved ${historyMessages.length} messages from database',
      );

      _messages.clear();
      for (final message in historyMessages) {
        _messages.add(
          ChatMessage(
            message: message.messageContent,
            isUser: message.messageType == 'user',
            timestamp: message.createdAt,
          ),
        );
      }

      _scrollToBottom();

      print('✅ [LOAD HISTORY] Conversation history loaded successfully');
      print('✅ [LOAD HISTORY] Total messages in memory: ${_messages.length}');
    } catch (e) {
      // Handle error gracefully - continue with in-memory messages
      print('❌ [LOAD HISTORY] Error loading conversation history: $e');
      print('❌ [LOAD HISTORY] Continuing with empty conversation');
    }
  }

  void addMessage(
    String message,
    bool isUser, {
    Map<String, dynamic>? metadata,
  }) {
    print('📝 [ADD MESSAGE] Adding new message to conversation');
    print('📝 [ADD MESSAGE] Message type: ${isUser ? 'USER' : 'ASSISTANT'}');
    print('📝 [ADD MESSAGE] Message length: ${message.length} chars');
    print('📝 [ADD MESSAGE] Current message count: ${_messages.length}');

    final chatMessage = ChatMessage(
      message: message,
      isUser: isUser,
      timestamp: DateTime.now(),
    );

    _messages.add(chatMessage);
    _scrollToBottom();

    print('📝 [ADD MESSAGE] Message added to local conversation');
    print('📝 [ADD MESSAGE] New message count: ${_messages.length}');

    // Persist to database asynchronously
    if (_currentUserId != null && _currentSessionId != null) {
      print(
        '📝 [ADD MESSAGE] User and session IDs available, attempting persistence...',
      );
      _persistMessage(chatMessage, metadata: metadata);
    } else {
      print(
        '⚠️ [ADD MESSAGE] User ID or Session ID missing, skipping persistence',
      );
      print('⚠️ [ADD MESSAGE] Current userId: $_currentUserId');
      print('⚠️ [ADD MESSAGE] Current sessionId: $_currentSessionId');
    }
  }

  /// Persist message to database
  Future<void> _persistMessage(
    ChatMessage message, {
    Map<String, dynamic>? metadata,
  }) async {
    print('💾 [PERSIST MESSAGE] Starting message persistence...');
    print(
      '💾 [PERSIST MESSAGE] Message type: ${message.isUser ? 'USER' : 'ASSISTANT'}',
    );
    print(
      '💾 [PERSIST MESSAGE] Message length: ${message.message.length} chars',
    );
    print(
      '💾 [PERSIST MESSAGE] Timestamp: ${message.timestamp.toIso8601String()}',
    );

    try {
      // Check if we have the required IDs
      if (_currentUserId == null || _currentSessionId == null) {
        print('⚠️ [PERSIST MESSAGE] MISSING REQUIRED DATA');
        print('⚠️ [PERSIST MESSAGE] Current userId: $_currentUserId');
        print('⚠️ [PERSIST MESSAGE] Current sessionId: $_currentSessionId');
        print(
          '⚠️ [PERSIST MESSAGE] Cannot persist message: userId or sessionId is null',
        );
        return;
      }

      print('💾 [PERSIST MESSAGE] User ID available: $_currentUserId');
      print('💾 [PERSIST MESSAGE] Session ID available: $_currentSessionId');

      // Merge default metadata with provided metadata
      final defaultMetadata = {
        'timestamp': message.timestamp.toIso8601String(),
        'session_context': 'ai_assistant_conversation',
      };

      final mergedMetadata = {...defaultMetadata, ...?metadata};

      print('💾 [PERSIST MESSAGE] Calling history service saveMessage...');

      await _getHistoryService.saveMessage(
        userId: _currentUserId!,
        sessionId: _currentSessionId!,
        messageContent: message.message,
        messageType: message.isUser ? 'user' : 'assistant',
        messageRole: message.isUser ? 'user' : 'assistant',
        modelUsed: 'gpt-3.5-turbo', // Could be made configurable
        metadata: mergedMetadata,
      );

      print('✅ [PERSIST MESSAGE] Message persisted successfully');
    } catch (e) {
      // Log error but don't interrupt user experience
      // Always log errors (not just in debug mode) for production debugging
      print('❌ [PERSIST MESSAGE] Error persisting message: $e');
      print('❌ [PERSIST MESSAGE] Stack trace: ${StackTrace.current}');
      print('❌ [PERSIST MESSAGE] Error type: ${e.runtimeType}');
    }
  }

  void clearHistory() {
    _messages.clear();
    // Start a new session
    _currentSessionId = _generateSessionId();
  }

  /// Generate a simple session ID
  String _generateSessionId() {
    return _uuid.v4();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  /// Get conversation context for AI (last N messages)
  List<ChatMessage> getConversationContext({int maxMessages = 10}) {
    if (_messages.isEmpty) return [];

    // If last message is from user, exclude it (will be added separately)
    final messagesToInclude = _messages.last.isUser && _messages.length > 1
        ? _messages.sublist(0, _messages.length - 1)
        : _messages;

    // Limit to maxMessages
    return messagesToInclude.length > maxMessages
        ? messagesToInclude.sublist(messagesToInclude.length - maxMessages)
        : messagesToInclude;
  }

  void dispose() {
    scrollController.dispose();
  }
}
