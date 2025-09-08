# Conversation History Clearing Behavior - Updated

## Summary of Changes

Removed automatic conversation history clearing when prompts or models are changed. The conversation history now only clears in these specific scenarios:

## ✅ Conversation History WILL Clear:

### 1. User Selection Change
- **When**: User selects a different user from the dropdown
- **Method**: `_onUserChanged()`
- **Reason**: Each user should have their own conversation context
- **Feedback**: Green snackbar - "Switched to user: [name] - Fresh conversation started"

### 2. Clear Button Press
- **When**: User explicitly clicks the "Clear History" button
- **Method**: `onClearHistory` callback in `ConversationHistoryWidget`
- **Reason**: User explicitly requested to clear the conversation
- **Feedback**: Standard clear history behavior (no snackbar needed)

## ❌ Conversation History Will NOT Clear:

### 1. Prompt Selection/Change
- **When**: User loads a saved prompt, deselects a prompt, or resets to default
- **Method**: `_loadSelectedPrompt()` and `_resetCustomPrompt()`
- **Behavior**: Prompt changes, conversation history is preserved
- **Feedback**: 
  - Purple snackbar: "Loaded prompt: [name]"
  - Orange snackbar: "Prompt cleared"
  - Blue snackbar: "Reset to default prompt"

### 2. Model Selection/Change (Future Feature)
- **When**: User selects a different AI model
- **Method**: `_onModelChanged()`
- **Behavior**: Model changes, conversation history is preserved
- **Feedback**: Blue snackbar: "AI model changed to: [model]"

## Benefits of This Approach

1. **Conversation Continuity**: Users can switch prompts and continue their conversation without losing context
2. **Experimentation**: Users can try different prompts on the same conversation to see how responses change
3. **User Control**: Only explicit actions (user change, clear button) clear the history
4. **Predictable Behavior**: Clear rules about when conversation is cleared vs preserved

## Technical Implementation

### Removed Code:
```dart
// Removed from _loadSelectedPrompt():
_conversationService.clearHistory();

// Removed from _resetCustomPrompt():
_conversationService.clearHistory();

// Removed from _onModelChanged():
_conversationService.clearHistory();
```

### Preserved Code:
```dart
// Still in _onUserChanged():
_conversationService.clearHistory();

// Still in onClearHistory callback:
setState(() => _conversationService.clearHistory())
```

## User Experience

- **When switching prompts**: Conversation context is maintained, allowing users to see how different prompts affect responses to the same conversation
- **When switching users**: Fresh conversation for proper user isolation
- **When using clear button**: Explicit control over conversation clearing
- **When switching models**: (Future) Model changes without losing conversation context

This provides a more intuitive and flexible user experience where conversation history is preserved unless the user explicitly wants to clear it or is switching to a different user context.
