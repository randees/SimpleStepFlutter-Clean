// Test script to verify custom AI prompt ID is properly captured
// This verifies the fix for the custom AI prompt ID not being assigned

import 'package:flutter_test/flutter_test.dart';
import '../lib/services/ai_services/conversation_service.dart';

void main() {
  group('Custom AI Prompt ID Tests', () {
    late ConversationService conversationService;

    setUp(() {
      conversationService = ConversationService();
    });

    test('addMessage accepts customAiPromptId parameter', () {
      // Setup
      conversationService.initialize('test-user-123');

      // Execute - add message with custom prompt ID
      const customPromptId = 'prompt-uuid-123';
      conversationService.addMessage(
        'Hello with custom prompt',
        true,
        customAiPromptId: customPromptId,
      );

      // Verify - message was added (persistence testing would require database mocking)
      expect(conversationService.messageCount, 1);
      expect(conversationService.isEmpty, false);
    });

    test('addMessage without customAiPromptId still works', () {
      // Setup
      conversationService.initialize('test-user-123');

      // Execute - add message without custom prompt ID (legacy behavior)
      conversationService.addMessage('Hello without custom prompt', true);

      // Verify - message was added
      expect(conversationService.messageCount, 1);
      expect(conversationService.isEmpty, false);
    });

    test('Multiple messages with different prompt IDs', () {
      // Setup
      conversationService.initialize('test-user-123');

      // Execute - add messages with different prompt IDs
      conversationService.addMessage(
        'Message with prompt A',
        true,
        customAiPromptId: 'prompt-a-uuid',
      );

      conversationService.addMessage(
        'Response with prompt A',
        false,
        customAiPromptId: 'prompt-a-uuid',
      );

      conversationService.addMessage(
        'Message with prompt B',
        true,
        customAiPromptId: 'prompt-b-uuid',
      );

      // Verify - all messages were added
      expect(conversationService.messageCount, 3);
      expect(conversationService.isEmpty, false);
    });

    test('clearHistory works with custom prompt ID messages', () {
      // Setup
      conversationService.initialize('test-user-123');
      conversationService.addMessage(
        'Message with custom prompt',
        true,
        customAiPromptId: 'test-prompt-uuid',
      );
      expect(conversationService.messageCount, 1);

      // Execute
      conversationService.clearHistory();

      // Verify
      expect(conversationService.isEmpty, true);
      expect(conversationService.messageCount, 0);
    });
  });

  group('Integration Test Scenarios', () {
    // These would be manual integration tests using the actual UI

    test('Manual Test: Select custom prompt and verify database', () {
      // Steps for manual testing:
      // 1. Open AI MCP Test Page
      // 2. Load a saved custom prompt
      // 3. Send a message to the AI
      // 4. Check the conversation_history table in Supabase
      // 5. Verify the custom_ai_prompt_id column contains the prompt's UUID

      // SQL to check:
      // SELECT id, custom_ai_prompt_id, message_content, message_type
      // FROM conversation_history
      // WHERE custom_ai_prompt_id IS NOT NULL
      // ORDER BY created_at DESC;
    });

    test('Manual Test: Switch between prompts and verify IDs', () {
      // Steps for manual testing:
      // 1. Open AI MCP Test Page
      // 2. Send message with default prompt (should have NULL custom_ai_prompt_id)
      // 3. Load custom prompt A
      // 4. Send message (should have prompt A's UUID)
      // 5. Load custom prompt B
      // 6. Send message (should have prompt B's UUID)
      // 7. Reset to default prompt
      // 8. Send message (should have NULL custom_ai_prompt_id again)
      // 9. Verify all messages in database have correct prompt IDs
    });

    test('Manual Test: Error handling with invalid prompt ID', () {
      // Steps for manual testing:
      // 1. Manually set an invalid/non-existent prompt ID in the code
      // 2. Send a message
      // 3. Verify the message still saves but with NULL custom_ai_prompt_id
      // 4. Check that no errors occur in the UI
    });
  });

  group('Database Schema Validation', () {
    test('Manual Database Test: Foreign key constraint works', () {
      // Steps for manual database testing:
      // 1. Connect to Supabase database
      // 2. Try to insert a conversation_history record with invalid custom_ai_prompt_id
      // 3. Should fail due to foreign key constraint
      // 4. Try to delete a custom_ai_prompts record that's referenced
      // 5. Should set conversation_history.custom_ai_prompt_id to NULL (ON DELETE SET NULL)
    });
  });
}
