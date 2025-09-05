import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../models/conversation_message.dart';
import 'supabase_service.dart';

/// Service for managing persistent conversation history in the database
class ConversationHistoryService {
  SupabaseClient get _supabase {
    try {
      return SupabaseService.adminClient;
    } catch (e) {
      if (kDebugMode) {
        print(
          '⚠️ Admin client not available, falling back to regular client: $e',
        );
      }
      return SupabaseService.client;
    }
  }

  /// Save a message to the conversation history
  Future<void> saveMessage({
    required String userId,
    required String sessionId,
    required String messageContent,
    required String messageType,
    required String messageRole,
    String? modelUsed,
    int? tokensUsed,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _supabase.from('conversation_history').insert({
        'user_id': userId,
        'session_id': sessionId,
        'message_content': messageContent,
        'message_type': messageType,
        'message_role': messageRole,
        'model_used': modelUsed,
        'tokens_used': tokensUsed,
        'metadata': metadata,
      });

      if (kDebugMode) {
        print('✅ Message saved to conversation history');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving message to conversation history: $e');
      }
      rethrow;
    }
  }

  /// Get conversation history for a user
  Future<List<ConversationMessage>> getUserConversationHistory(
    String userId, {
    int limit = 50,
    DateTime? since,
  }) async {
    try {
      var query = _supabase
          .from('conversation_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      if (since != null) {
        query = (query as dynamic).gte('created_at', since.toIso8601String());
      }

      final response = await query;
      final messages = (response as List<dynamic>)
          .map(
            (json) =>
                ConversationMessage.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      if (kDebugMode) {
        print(
          '📚 Retrieved ${messages.length} messages from conversation history',
        );
      }

      return messages.reversed.toList(); // Return in chronological order
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error retrieving conversation history: $e');
      }
      return [];
    }
  }

  /// Get conversation sessions for a user
  Future<List<Map<String, dynamic>>> getUserConversationSessions(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('conversation_sessions')
          .select()
          .eq('user_id', userId)
          .order('session_start', ascending: false);

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error retrieving conversation sessions: $e');
      }
      return [];
    }
  }

  /// Get messages for a specific conversation session
  Future<List<ConversationMessage>> getSessionMessages(String sessionId) async {
    try {
      final response = await _supabase
          .from('conversation_history')
          .select()
          .eq('session_id', sessionId)
          .order('created_at', ascending: true);

      return (response as List<dynamic>)
          .map(
            (json) =>
                ConversationMessage.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error retrieving session messages: $e');
      }
      return [];
    }
  }

  /// Delete conversation history for a user (GDPR compliance)
  Future<void> deleteUserConversationHistory(String userId) async {
    try {
      await _supabase
          .from('conversation_history')
          .delete()
          .eq('user_id', userId);

      if (kDebugMode) {
        print('🗑️ Deleted conversation history for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting conversation history: $e');
      }
      rethrow;
    }
  }

  /// Archive old conversation history (for data management)
  Future<void> archiveOldConversations({
    required Duration olderThan,
    required String archiveTableName,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(olderThan);

      // Note: This would require additional implementation for actual archiving
      // For now, just log the operation
      if (kDebugMode) {
        print('📦 Would archive conversations older than: $cutoffDate');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error archiving conversations: $e');
      }
      rethrow;
    }
  }

  /// Get conversation statistics for a user
  Future<Map<String, dynamic>> getUserConversationStats(String userId) async {
    try {
      final response = await _supabase
          .from('conversation_history')
          .select('message_type')
          .eq('user_id', userId);

      final stats = <String, dynamic>{};
      final messages = response as List<dynamic>;

      // Count messages by type
      for (final message in messages) {
        final messageType = message['message_type'] as String;
        stats['${messageType}_count'] =
            (stats['${messageType}_count'] ?? 0) + 1;
      }

      // Get session count
      final sessionResponse = await _supabase
          .from('conversation_sessions')
          .select('session_id')
          .eq('user_id', userId);

      stats['session_count'] = (sessionResponse as List<dynamic>).length;
      stats['total_messages'] = messages.length;

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error retrieving conversation stats: $e');
      }
      return {};
    }
  }
}
