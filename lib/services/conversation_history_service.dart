import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/conversation_message.dart';
import 'supabase_service.dart';

/// Service for managing persistent conversation history in the database
class ConversationHistoryService {
  SupabaseClient get _supabase {
    try {
      return SupabaseService.adminClient;
    } catch (e) {
      // Always log fallback (not just in debug mode) for production debugging
      print(
        '⚠️ Admin client not available, falling back to regular client: $e',
      );
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
    final startTime = DateTime.now();
    print('🔄 [CONVERSATION SAVE] Starting save attempt...');
    print('🔄 [CONVERSATION SAVE] User ID: $userId');
    print('🔄 [CONVERSATION SAVE] Session ID: $sessionId');
    print('🔄 [CONVERSATION SAVE] Message Type: $messageType');
    print('🔄 [CONVERSATION SAVE] Message Role: $messageRole');
    print(
      '🔄 [CONVERSATION SAVE] Message Length: ${messageContent.length} chars',
    );

    try {
      // Log which client we're using
      final isUsingAdminClient = _supabase == SupabaseService.adminClient;
      print(
        '🔄 [CONVERSATION SAVE] Using ${isUsingAdminClient ? 'ADMIN' : 'REGULAR'} client',
      );

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

      final duration = DateTime.now().difference(startTime);
      print(
        '✅ [CONVERSATION SAVE] SUCCESS - Saved in ${duration.inMilliseconds}ms',
      );
      print('✅ [CONVERSATION SAVE] Message saved to conversation history');
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      print(
        '❌ [CONVERSATION SAVE] FAILED - Attempt took ${duration.inMilliseconds}ms',
      );
      print('❌ [CONVERSATION SAVE] Error: $e');
      print('❌ [CONVERSATION SAVE] Error type: ${e.runtimeType}');
      if (e is Exception) {
        print('❌ [CONVERSATION SAVE] Exception details: ${e.toString()}');
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
    print('📚 [GET HISTORY] Starting conversation history retrieval...');
    print('📚 [GET HISTORY] User ID: $userId');
    print('📚 [GET HISTORY] Limit: $limit');
    print('📚 [GET HISTORY] Since: $since');

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

      print('📚 [GET HISTORY] Executing database query...');
      final response = await query;
      print('📚 [GET HISTORY] Database query completed');

      final messages = (response as List<dynamic>)
          .map(
            (json) =>
                ConversationMessage.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      print(
        '📚 [GET HISTORY] Retrieved ${messages.length} messages from database',
      );
      print('📚 [GET HISTORY] Returning messages in chronological order');

      return messages.reversed.toList(); // Return in chronological order
    } catch (e) {
      print('❌ [GET HISTORY] Error retrieving conversation history: $e');
      print('❌ [GET HISTORY] Returning empty list');
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
      print('❌ [GET SESSIONS] Error retrieving conversation sessions: $e');
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
      print('❌ [GET SESSION MESSAGES] Error retrieving session messages: $e');
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

      print(
        '🗑️ [DELETE HISTORY] Deleted conversation history for user: $userId',
      );
    } catch (e) {
      print('❌ [DELETE HISTORY] Error deleting conversation history: $e');
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
      print('📦 [ARCHIVE] Would archive conversations older than: $cutoffDate');
    } catch (e) {
      print('❌ [ARCHIVE] Error archiving conversations: $e');
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
      print('❌ [GET STATS] Error retrieving conversation stats: $e');
      return {};
    }
  }
}
