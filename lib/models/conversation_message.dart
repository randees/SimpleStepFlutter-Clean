/// Model for conversation messages stored in the database
class ConversationMessage {
  final String id;
  final String? userId;
  final String sessionId;
  final String messageContent;
  final String messageType; // 'user', 'assistant', 'system'
  final String messageRole; // 'user', 'assistant', 'system'
  final String? modelUsed;
  final int? tokensUsed;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConversationMessage({
    required this.id,
    this.userId,
    required this.sessionId,
    required this.messageContent,
    required this.messageType,
    required this.messageRole,
    this.modelUsed,
    this.tokensUsed,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON (database response)
  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      sessionId: json['session_id'] as String,
      messageContent: json['message_content'] as String,
      messageType: json['message_type'] as String,
      messageRole: json['message_role'] as String,
      modelUsed: json['model_used'] as String?,
      tokensUsed: json['tokens_used'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON (for database insertion)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'session_id': sessionId,
      'message_content': messageContent,
      'message_type': messageType,
      'message_role': messageRole,
      'model_used': modelUsed,
      'tokens_used': tokensUsed,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  ConversationMessage copyWith({
    String? id,
    String? userId,
    String? sessionId,
    String? messageContent,
    String? messageType,
    String? messageRole,
    String? modelUsed,
    int? tokensUsed,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      messageContent: messageContent ?? this.messageContent,
      messageType: messageType ?? this.messageType,
      messageRole: messageRole ?? this.messageRole,
      modelUsed: modelUsed ?? this.modelUsed,
      tokensUsed: tokensUsed ?? this.tokensUsed,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ConversationMessage(id: $id, type: $messageType, role: $messageRole, content: ${messageContent.substring(0, min(50, messageContent.length))}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Helper function for min
int min(int a, int b) => a < b ? a : b;
