import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'dart:async';
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
  final ConversationHistoryService _historyService = ConversationHistoryService();
  final Random _random = Random();

  // Current session ID for grouping messages
  String? _currentSessionId;
  String? _currentUserId;

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  int get messageCount => _messages.length;

  bool get isEmpty => _messages.isEmpty;

  /// Initialize the service with user context
  void initialize(String userId) {
    _currentUserId = userId;
    _currentSessionId = _generateSessionId();
  }

  /// Load conversation history from database
  Future<void> loadConversationHistory({int limit = 20}) async {
    if (_currentUserId == null) return;

    try {
      if (kDebugMode) {
        print('📚 Loading conversation history for user: $_currentUserId');
      }

      final historyMessages = await _historyService.getUserConversationHistory(
        _currentUserId!,
        limit: limit,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (kDebugMode) {
            print('⏰ Timeout loading conversation history');
          }
          return [];
        },
      );

      if (kDebugMode) {
        print('📚 Retrieved ${historyMessages.length} messages from database');
      }

      _messages.clear();
      for (final message in historyMessages) {
        _messages.add(ChatMessage(
          message: message.messageContent,
          isUser: message.messageType == 'user',
          timestamp: message.createdAt,
        ));
      }

      _scrollToBottom();

      if (kDebugMode) {
        print('✅ Conversation history loaded successfully');
      }
    } catch (e) {
      // Handle error gracefully - continue with in-memory messages
      if (kDebugMode) {
        print('❌ Error loading conversation history: $e');
      }
    }
  }

  void addMessage(String message, bool isUser, {Map<String, dynamic>? metadata}) {
    final chatMessage = ChatMessage(
      message: message,
      isUser: isUser,
      timestamp: DateTime.now(),
    );

    _messages.add(chatMessage);
    _scrollToBottom();

    // Persist to database asynchronously
    if (_currentUserId != null && _currentSessionId != null) {
      _persistMessage(chatMessage, metadata: metadata);
    }
  }

  /// Persist message to database
  Future<void> _persistMessage(ChatMessage message, {Map<String, dynamic>? metadata}) async {
    try {
      // Merge default metadata with provided metadata
      final defaultMetadata = {
        'timestamp': message.timestamp.toIso8601String(),
        'session_context': 'ai_assistant_conversation',
      };

      final mergedMetadata = {...defaultMetadata, ...?metadata};

      await _historyService.saveMessage(
        userId: _currentUserId!,
        sessionId: _currentSessionId!,
        messageContent: message.message,
        messageType: message.isUser ? 'user' : 'assistant',
        messageRole: message.isUser ? 'user' : 'assistant',
        modelUsed: 'gpt-3.5-turbo', // Could be made configurable
        metadata: mergedMetadata,
      );
    } catch (e) {
      // Log error but don't interrupt user experience
      print('Error persisting message: $e');
    }
  }

  void clearHistory() {
    _messages.clear();
    // Start a new session
    _currentSessionId = _generateSessionId();
  }

  /// Generate a simple session ID
  String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
           _random.nextInt(999999).toString().padLeft(6, '0');
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
