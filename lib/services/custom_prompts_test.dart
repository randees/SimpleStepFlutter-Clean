// Simple test to verify custom prompts functionality
// This can be run manually to test the feature

import '../services/custom_prompts_service.dart';

class CustomPromptsTest {
  static Future<void> runBasicTest() async {
    print('🧪 Starting Custom Prompts Basic Test...');

    // Test 1: Get hardcoded default prompt (should always work)
    print('\n📝 Test 1: Get hardcoded default prompt');
    final hardcodedPrompt = CustomPromptsService.getHardcodedDefaultPrompt();
    print('✅ Hardcoded prompt length: ${hardcodedPrompt.length} characters');
    print('📄 Preview: ${hardcodedPrompt.substring(0, 100)}...');

    // Test 2: User context substitution
    print('\n🔄 Test 2: User context substitution');
    const testUserId = 'test-user-123';
    const testUserEmail = 'test@example.com';
    final substitutedPrompt = CustomPromptsService.substituteUserContext(
      'Hello {user_id}, your email is {user_email}',
      testUserId,
      testUserEmail,
    );
    print('✅ Substitution result: $substitutedPrompt');

    // Test 3: Try database operations (these may fail if migration not applied)
    print(
      '\n🗄️  Test 3: Database operations (may fail if migration not applied)',
    );

    try {
      print('   📊 Fetching prompt types...');
      final promptTypes = await CustomPromptsService.getPromptTypes();
      print('   ✅ Found ${promptTypes.length} prompt types');
      for (final type in promptTypes) {
        print('      - ${type.id}: ${type.keyName}');
      }

      if (promptTypes.isNotEmpty) {
        final firstTypeId = promptTypes.first.id;
        print('   📋 Fetching prompts for type: $firstTypeId');
        final prompts = await CustomPromptsService.getCustomPrompts(
          firstTypeId,
        );
        print('   ✅ Found ${prompts.length} custom prompts for $firstTypeId');
      }
    } catch (e) {
      print('   ❌ Database operations failed: $e');
      print('   💡 This is expected if the migration hasn\'t been applied yet');
    }

    print('\n✅ Custom Prompts Basic Test completed!');
  }

  static Future<void> runFullTest() async {
    print('🧪 Starting Custom Prompts Full Test...');

    await runBasicTest();

    // Test 4: CRUD operations (only if database is available)
    print('\n🔧 Test 4: CRUD operations');

    try {
      // Create a test prompt
      print('   📝 Creating test prompt...');
      final createdPrompt = await CustomPromptsService.createCustomPrompt(
        promptTypeId: 'goal_setting',
        promptText: 'Test prompt created at ${DateTime.now()}',
        promptName: 'Test Prompt ${DateTime.now().millisecondsSinceEpoch}',
      );

      if (createdPrompt != null) {
        print('   ✅ Created prompt with ID: ${createdPrompt.id}');
        print('   📝 Prompt name: "${createdPrompt.promptName}"');
        print(
          '   📄 Prompt preview: ${createdPrompt.promptText.substring(0, 50)}...',
        );

        // Update the prompt
        print('   ✏️  Updating test prompt...');
        final updatedPrompt = await CustomPromptsService.updateCustomPrompt(
          promptId: createdPrompt.id,
          promptText: 'Updated test prompt at ${DateTime.now()}',
          promptName: 'Updated ${createdPrompt.promptName}',
        );

        if (updatedPrompt != null) {
          print('   ✅ Updated prompt successfully');
          print('   📝 Updated name: "${updatedPrompt.promptName}"');

          // Delete the prompt
          print('   🗑️  Deleting test prompt...');
          final deleted = await CustomPromptsService.deleteCustomPrompt(
            createdPrompt.id,
          );

          if (deleted) {
            print('   ✅ Deleted prompt successfully');
          } else {
            print('   ❌ Failed to delete prompt');
          }
        } else {
          print('   ❌ Failed to update prompt');
        }
      } else {
        print('   ❌ Failed to create prompt');
      }
    } catch (e) {
      print('   ❌ CRUD operations failed: $e');
      print('   💡 This is expected if the migration hasn\'t been applied yet');
    }

    print('\n✅ Custom Prompts Full Test completed!');
  }
}
