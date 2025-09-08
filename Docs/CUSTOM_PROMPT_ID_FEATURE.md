# Custom AI Prompt ID in Conversation History

## Overview
A new column `custom_ai_prompt_id` has been added to the `conversation_history` table to track which custom AI prompt was used for each conversation message.

## Database Changes

### Migration: 014_add_custom_prompt_id_to_conversation_history.sql

#### Changes Made:
1. **Added Column**: `custom_ai_prompt_id UUID` to `conversation_history` table
2. **Foreign Key**: References `custom_ai_prompts(id)` with `ON DELETE SET NULL`
3. **Index**: Added `idx_conversation_history_custom_prompt_id` for query performance
4. **Documentation**: Added column comment for clarity

#### Column Details:
- **Type**: `UUID` 
- **Nullable**: `YES` (allows NULL values)
- **Foreign Key**: References `custom_ai_prompts.id`
- **On Delete**: `SET NULL` (preserves conversation history if prompt is deleted)

## Code Changes

### 1. ConversationMessage Model (`lib/models/conversation_message.dart`)
- Added `customAiPromptId` field
- Updated `fromJson()`, `toJson()`, and `copyWith()` methods
- Maintains backward compatibility with existing data

### 2. ConversationHistoryService (`lib/services/conversation_history_service.dart`)
- Added `customAiPromptId` parameter to `saveMessage()` method
- Updated database insert to include the new column
- Maintains backward compatibility (parameter is optional)

### 3. ConversationService (`lib/services/ai_services/conversation_service.dart`)
- Updated `saveMessage()` call to pass `customAiPromptId: null`
- Added TODO comment for future implementation

## Usage

### Saving a Message with Custom Prompt ID
```dart
await conversationHistoryService.saveMessage(
  userId: userId,
  sessionId: sessionId,
  messageContent: 'User message...',
  messageType: 'user',
  messageRole: 'user',
  customAiPromptId: 'prompt-uuid-here', // NEW: Track which prompt was used
);
```

### Querying Messages with Prompt Information
```sql
SELECT 
    ch.message_content,
    ch.message_type,
    cap.prompt_name,
    pt.key_name as prompt_type
FROM conversation_history ch
LEFT JOIN custom_ai_prompts cap ON ch.custom_ai_prompt_id = cap.id
LEFT JOIN prompt_type pt ON cap.prompt_type_id = pt.id
WHERE ch.user_id = 'user-uuid-here';
```

## Benefits

1. **Prompt Analytics**: Track which custom prompts are being used most
2. **Conversation Context**: Understand which prompt generated specific responses
3. **Audit Trail**: Maintain history of prompt usage
4. **Future Features**: Enable prompt-specific conversation filtering/analysis

## Migration Status

✅ **Applied Successfully** - The migration has been applied to the remote database.

## Testing

A test script has been provided at `supabase/test_custom_prompt_column.sql` that:
1. Verifies the column structure
2. Checks foreign key constraints
3. Validates index creation
4. Tests data insertion and querying

## Next Steps

1. **Update AI Integration**: Modify AI services to pass actual custom prompt IDs
2. **Analytics Dashboard**: Create views to analyze prompt usage patterns
3. **Conversation Filtering**: Add UI to filter conversations by prompt type
4. **Prompt Performance**: Track which prompts generate better user engagement

## Backward Compatibility

- ✅ Existing code continues to work (optional parameter)
- ✅ Existing data remains intact (NULL values allowed)
- ✅ No breaking changes to APIs
