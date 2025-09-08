# Custom AI Prompt ID Fix Implementation

## Issue Description
The custom AI prompt ID was not being assigned when conversations were being recorded to the database. Although the database schema had the `custom_ai_prompt_id` column and the infrastructure was in place, the actual prompt ID was never passed from the UI to the persistence layer.

## Root Cause Analysis
1. **ConversationService.addMessage()** method did not accept a `customAiPromptId` parameter
2. **ConversationService._persistMessage()** was hardcoded to pass `null` for `customAiPromptId`
3. **AIMCPTestPage** tracked the selected prompt in `_selectedPrompt` state but never passed this information to the conversation service
4. No connection between the UI prompt selection and database persistence

## Solution Implementation

### 1. Enhanced ConversationService.addMessage()
**File**: `lib/services/ai_services/conversation_service.dart`

Added `customAiPromptId` parameter to the `addMessage()` method:
```dart
void addMessage(
  String message,
  bool isUser, {
  Map<String, dynamic>? metadata,
  String? customAiPromptId,  // NEW PARAMETER
}) {
  // ... existing code ...
  _persistMessage(chatMessage, metadata: metadata, customAiPromptId: customAiPromptId);
}
```

### 2. Enhanced ConversationService._persistMessage()
**File**: `lib/services/ai_services/conversation_service.dart`

Updated the `_persistMessage()` method to accept and forward the custom prompt ID:
```dart
Future<void> _persistMessage(
  ChatMessage message, {
  Map<String, dynamic>? metadata,
  String? customAiPromptId,  // NEW PARAMETER
}) async {
  // ... existing code ...
  await _getHistoryService.saveMessage(
    // ... other parameters ...
    customAiPromptId: customAiPromptId,  // FORWARDED TO DATABASE
  );
}
```

### 3. Enhanced AIMCPTestPage._onQuestionSubmit()
**File**: `lib/screens/ai_mcp_test_page.dart`

Updated the question submission logic to pass the selected prompt ID:
```dart
Future<void> _onQuestionSubmit() async {
  // ... existing code ...
  
  // Get the custom prompt ID if a prompt is selected
  final customPromptId = _selectedPrompt?.id;

  // Add user question with custom prompt ID
  _conversationService.addMessage(
    question, 
    true,
    customAiPromptId: customPromptId,
  );

  // ... AI processing ...

  // Add AI response with custom prompt ID  
  _conversationService.addMessage(
    response.content, 
    false,
    customAiPromptId: customPromptId,
  );
}
```

## Implementation Details

### Data Flow
1. **UI Layer**: User selects a custom prompt → stored in `_selectedPrompt` state
2. **UI Layer**: User submits question → `_selectedPrompt?.id` extracted
3. **Service Layer**: `ConversationService.addMessage()` receives `customAiPromptId`
4. **Service Layer**: `_persistMessage()` forwards ID to `ConversationHistoryService`
5. **Database Layer**: `saveMessage()` inserts record with `custom_ai_prompt_id`

### Prompt ID Scenarios
- **No prompt selected**: `customAiPromptId` = `null` → database stores `NULL`
- **Custom prompt selected**: `customAiPromptId` = UUID → database stores the UUID
- **Prompt changed**: New conversation messages use the new prompt's ID
- **Error messages**: Use the same prompt ID as the context they're responding to

### Database Schema
The `conversation_history` table has:
```sql
custom_ai_prompt_id UUID REFERENCES custom_ai_prompts(id) ON DELETE SET NULL
```

This ensures:
- Valid prompt IDs are stored when available
- NULL is stored when no prompt is selected
- If a prompt is deleted, existing conversation records are preserved with NULL

## Testing Strategy

### Unit Tests
Created `test/custom_prompt_id_test.dart` with tests for:
- `addMessage()` with `customAiPromptId` parameter
- Backward compatibility (messages without prompt ID)
- Multiple messages with different prompt IDs
- Clearing history with prompt ID messages

### Integration Tests
Manual testing scenarios:
1. **Prompt Selection**: Load prompt → send message → verify database has correct UUID
2. **Prompt Switching**: Change prompts → verify new messages use new prompt ID
3. **Default Prompt**: Reset to default → verify messages have NULL prompt ID
4. **Error Handling**: Invalid prompt ID → graceful handling

### Database Verification
Query to verify the fix:
```sql
SELECT 
  id, 
  custom_ai_prompt_id, 
  message_content, 
  message_type,
  created_at
FROM conversation_history 
WHERE custom_ai_prompt_id IS NOT NULL 
ORDER BY created_at DESC;
```

## Backward Compatibility
- Existing code calling `addMessage()` without `customAiPromptId` continues to work
- Existing database records with NULL `custom_ai_prompt_id` are unaffected
- No breaking changes to the API

## Benefits
1. **Full Traceability**: Can track which prompt was used for each conversation
2. **Analytics**: Can analyze prompt effectiveness and usage patterns
3. **Context Preservation**: Conversation history maintains prompt context
4. **User Experience**: Users can see which prompts were used in past conversations
5. **Debugging**: Easier to troubleshoot issues related to specific prompts

## Future Enhancements
1. **UI Display**: Show prompt name/icon in conversation history
2. **Filtering**: Filter conversation history by prompt type
3. **Analytics Dashboard**: Usage statistics by prompt
4. **Prompt Versioning**: Track prompt changes over time
5. **Export**: Include prompt information in conversation exports

## Validation
After implementing this fix:
- [x] Custom prompt IDs are correctly captured in database
- [x] Null values are stored when no prompt is selected  
- [x] Prompt switching properly updates subsequent messages
- [x] Error messages inherit the correct prompt context
- [x] Backward compatibility is maintained
- [x] No performance impact on message persistence
