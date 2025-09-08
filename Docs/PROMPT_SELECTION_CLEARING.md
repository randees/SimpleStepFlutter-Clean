# Prompt Selection Conversation Clearing

## Overview
Extended the conversation clearing functionality to also reset conversation history when custom AI prompts are selected, deselected, or reset. This ensures users always start with fresh conversations when changing prompt context.

## New Clearing Triggers

### 1. Custom Prompt Selection
**When**: User selects a saved custom prompt from the dropdown
**Action**: Conversation history is cleared and new session started
**Feedback**: "Loaded prompt: [Name] - Fresh conversation started" (purple snackbar)

### 2. Prompt Reset to Default  
**When**: User clicks the "Reset" button to return to default system prompt
**Action**: Conversation history is cleared and new session started
**Feedback**: "Reset to default prompt - Fresh conversation started" (blue snackbar)

### 3. Prompt Deselection
**When**: User clears/deselects the current custom prompt (sets to null)
**Action**: Conversation history is cleared and new session started  
**Feedback**: "Prompt cleared - Fresh conversation started" (orange snackbar)

## Implementation Details

### Modified Methods

#### `_loadSelectedPrompt(CustomAiPrompt? prompt)`
**Before**: Only loaded prompt text into controller
**After**: 
- Loads prompt text
- Clears conversation history 
- Shows appropriate user feedback
- Handles both selection and deselection cases

#### `_resetCustomPrompt()`
**Before**: Only reset prompt controller to default text
**After**:
- Resets prompt controller
- Clears conversation history
- Shows user feedback about fresh conversation

### User Experience Flow

1. **User has active conversation** with existing context
2. **User selects different prompt** from saved prompts dropdown  
3. **History is immediately cleared** (invisible to user)
4. **User sees confirmation** via snackbar message
5. **Next AI interaction** starts fresh with new prompt context
6. **No confusion** about mixed prompt contexts in conversation

## Benefits

- **Context Clarity**: No mixing of different prompt contexts in same conversation
- **Predictable Behavior**: Users know when they're starting fresh
- **Better Testing**: Each prompt gets clean testing environment
- **Consistent UX**: Same clearing behavior as user/model selection

## Testing

### Manual Test Scenarios
1. Have conversation → Select custom prompt → Verify history cleared
2. Have conversation → Reset to default → Verify history cleared  
3. Have conversation → Deselect prompt → Verify history cleared
4. Switch between multiple prompts → Verify each starts fresh

### Edge Cases Handled
- Selecting same prompt again (still clears - consistent behavior)
- Rapid prompt switching (each change clears properly)
- Deselecting when no prompt selected (safe operation)

## Code Changes

### Files Modified
- `lib/screens/ai_mcp_test_page.dart` - Enhanced prompt selection methods
- `test/conversation_clearing_test.dart` - Added prompt selection test cases
- `docs/CONVERSATION_CLEARING_FIX.md` - Updated documentation

### Key Changes
- Added `_conversationService.clearHistory()` calls to prompt methods
- Added user feedback snackbars with appropriate colors
- Enhanced logging for debugging prompt-related clearing
- Added test cases for prompt selection scenarios

## User Feedback Colors
- **Purple**: Custom prompt loaded
- **Blue**: Reset to default prompt  
- **Orange**: Prompt cleared/deselected
- **Green**: User selection (existing)
- **Orange**: Clear button (existing)

This maintains consistent color coding while distinguishing different types of clearing actions.
