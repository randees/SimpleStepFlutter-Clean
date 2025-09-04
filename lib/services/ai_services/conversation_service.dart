import 'package:flutter/material.dart';

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

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  int get messageCount => _messages.length;

  bool get isEmpty => _messages.isEmpty;

  void addMessage(String message, bool isUser) {
    _messages.add(
      ChatMessage(message: message, isUser: isUser, timestamp: DateTime.now()),
    );
    _scrollToBottom();
  }

  void clearHistory() {
    _messages.clear();
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
