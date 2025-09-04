# Custom AI Prompts Feature

## Overview
This feature adds database-backed custom AI prompts management to the SimpleStep Flutter app.

## Database Schema

### Tables Created

#### 1. `prompt_type`
- **Purpose**: Defines the types of prompts available
- **Columns**:
  - `id` (VARCHAR(20), PRIMARY KEY): Unique identifier
  - `key_name` (VARCHAR(50)): Human-readable name

**Default Data**:
- `goal_setting` → "Goal Setting"
- `planning` → "Planning"

#### 2. `custom_ai_prompts`
- **Purpose**: Stores custom AI prompts with their types
- **Columns**:
  - `id` (UUID, PRIMARY KEY): Unique identifier
  - `prompt_type_id` (VARCHAR(20), FOREIGN KEY): References prompt_type.id
  - `prompt_text` (TEXT): The actual prompt content
  - `created_at` (TIMESTAMP): Creation timestamp
  - `updated_at` (TIMESTAMP): Last update timestamp (auto-updated via trigger)

## Features

### Database Features
- ✅ **Row Level Security (RLS)**: Enabled on both tables
- ✅ **Foreign Key Constraints**: Ensures data integrity
- ✅ **Auto-timestamps**: `updated_at` automatically updated via trigger
- ✅ **Default Prompt**: Includes the current default goal setting prompt

### Service Features (`CustomPromptsService`)
- ✅ **Get Prompt Types**: Fetch all available prompt types
- ✅ **Get Custom Prompts**: Fetch prompts by type or all prompts
- ✅ **Get Default Prompt**: Get the first/default prompt for a type
- ✅ **Create Prompt**: Add new custom prompts
- ✅ **Update Prompt**: Modify existing prompts
- ✅ **Delete Prompt**: Remove prompts
- ✅ **User Context Substitution**: Replace {user_id} and {user_email} placeholders
- ✅ **Hardcoded Fallback**: Provides fallback prompt if database fails

### UI Features (`CustomPromptsDemo`)
- ✅ **Interactive Demo**: Test all CRUD operations
- ✅ **Prompt Type Selection**: Choose between Goal Setting and Planning
- ✅ **Live Status Updates**: Real-time feedback on operations
- ✅ **Error Handling**: Graceful error display
- ✅ **Confirmation Dialogs**: Prevent accidental deletions

## Files Created/Modified

### Migration
- `supabase/migrations/009_create_custom_prompts_tables.sql`

### Services
- `lib/services/custom_prompts_service.dart`

### Widgets
- `lib/widgets/custom_prompts_demo.dart`

### Documentation
- `docs/custom_prompts_feature_summary.md` (this file)

## How to Use

### 1. Apply Migration
```bash
# If using local Supabase (requires Docker)
supabase db reset

# Or apply to remote database
supabase db push
```

### 2. Test the Feature
Add the demo widget to any screen:
```dart
import '../widgets/custom_prompts_demo.dart';

// In your widget build method:
CustomPromptsDemo()
```

### 3. Integrate with AI System
```dart
// Get default prompt for goal setting
final defaultPrompt = await CustomPromptsService.getDefaultPrompt('goal_setting');

// Substitute user context
final finalPrompt = CustomPromptsService.substituteUserContext(
  defaultPrompt?['prompt_text'] ?? CustomPromptsService.getHardcodedDefaultPrompt(),
  userId,
  userEmail,
);

// Use finalPrompt with your AI system
```

## Testing Without Migration

The service includes a `getHardcodedDefaultPrompt()` method that provides the same default prompt as a fallback, so the system works even if the migration hasn't been applied yet.

## Next Steps

1. **Apply Migration**: Run the migration against your Supabase database
2. **Test Demo**: Add `CustomPromptsDemo` to a screen and test CRUD operations
3. **Integrate**: Replace hardcoded prompts in your AI system with database-backed prompts
4. **Extend**: Add more prompt types as needed (fitness, nutrition, mental_health, etc.)

## Security

- **RLS Enabled**: Only authenticated users can access prompts
- **Input Validation**: Service methods include error handling
- **Foreign Key Constraints**: Prevents invalid prompt_type_id references
