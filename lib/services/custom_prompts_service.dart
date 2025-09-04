import 'supabase_service.dart';
import '../models/custom_ai_prompt.dart';
import 'package:flutter/foundation.dart';

/// Service for managing custom AI prompts
class CustomPromptsService {
  /// Get all prompt types
  static Future<List<PromptType>> getPromptTypes() async {
    try {
      final response = await SupabaseService.client
          .from('prompt_type')
          .select('*')
          .order('key_name');

      return List<PromptType>.from(
        response.map((item) => PromptType.fromMap(item)),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching prompt types: $e');
      }
      return [];
    }
  }

  /// Get all custom prompts for a specific type
  static Future<List<CustomAiPrompt>> getCustomPrompts(
    String promptTypeId,
  ) async {
    try {
      if (kDebugMode) {
        print(
          '🔄 CustomPromptsService: Fetching prompts for type: $promptTypeId',
        );
      }

      // Use admin client to bypass RLS for custom prompts (they're system-level)
      final response = await SupabaseService.adminClient
          .from('custom_ai_prompts')
          .select('*, prompt_type!inner(*)')
          .eq('prompt_type_id', promptTypeId)
          .order('created_at', ascending: false);

      final prompts = List<CustomAiPrompt>.from(
        response.map((item) => CustomAiPrompt.fromMap(item)),
      );

      if (kDebugMode) {
        print('✅ CustomPromptsService: Retrieved ${prompts.length} prompts');
      }
      return prompts;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CustomPromptsService: Error fetching prompts: $e');
      }
      return [];
    }
  }

  /// Get all custom prompts with their types
  static Future<List<CustomAiPrompt>> getAllCustomPrompts() async {
    try {
      final response = await SupabaseService.client
          .from('custom_ai_prompts')
          .select('*, prompt_type!inner(*)')
          .order('prompt_type_id')
          .order('created_at', ascending: false);

      return List<CustomAiPrompt>.from(
        response.map((item) => CustomAiPrompt.fromMap(item)),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all custom prompts: $e');
      }
      return [];
    }
  }

  /// Get the default prompt for a specific type
  static Future<CustomAiPrompt?> getDefaultPrompt(String promptTypeId) async {
    try {
      final response = await SupabaseService.client
          .from('custom_ai_prompts')
          .select('*, prompt_type!inner(*)')
          .eq('prompt_type_id', promptTypeId)
          .order('created_at')
          .limit(1)
          .maybeSingle();

      return response != null ? CustomAiPrompt.fromMap(response) : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching default prompt: $e');
      }
      return null;
    }
  }

  /// Create a new custom prompt
  static Future<CustomAiPrompt?> createCustomPrompt({
    required String promptTypeId,
    required String promptText,
    required String promptName,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '🔄 CustomPromptsService: Creating prompt "$promptName" for type: $promptTypeId',
        );
      }

      // Use admin client to bypass RLS for custom prompts (they're system-level)
      final response = await SupabaseService.adminClient
          .from('custom_ai_prompts')
          .insert({
            'prompt_type_id': promptTypeId,
            'prompt_text': promptText,
            'prompt_name': promptName,
          })
          .select('*, prompt_type!inner(*)')
          .single();

      if (kDebugMode) {
        print('✅ Created custom prompt "$promptName" for type: $promptTypeId');
      }
      return CustomAiPrompt.fromMap(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating custom prompt: $e');
        print('❌ Error type: ${e.runtimeType}');
        if (e is Exception) {
          print('❌ Error message: ${e.toString()}');
        }
      }
      return null;
    }
  }

  /// Update an existing custom prompt
  static Future<CustomAiPrompt?> updateCustomPrompt({
    required String promptId,
    required String promptText,
    String? promptName,
  }) async {
    try {
      if (kDebugMode) {
        print('🔄 CustomPromptsService: Updating prompt $promptId');
      }

      // Use admin client to bypass RLS for custom prompts (they're system-level)
      final updateData = {'prompt_text': promptText};
      if (promptName != null) {
        updateData['prompt_name'] = promptName;
      }

      final response = await SupabaseService.adminClient
          .from('custom_ai_prompts')
          .update(updateData)
          .eq('id', promptId)
          .select('*, prompt_type!inner(*)')
          .single();

      if (kDebugMode) {
        print('✅ Updated custom prompt: $promptId');
      }
      return CustomAiPrompt.fromMap(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating custom prompt: $e');
      }
      return null;
    }
  }

  /// Delete a custom prompt
  static Future<bool> deleteCustomPrompt(String promptId) async {
    try {
      if (kDebugMode) {
        print('🔄 CustomPromptsService: Deleting prompt $promptId');
      }

      // Use admin client to bypass RLS for custom prompts (they're system-level)
      await SupabaseService.adminClient
          .from('custom_ai_prompts')
          .delete()
          .eq('id', promptId);

      if (kDebugMode) {
        print('✅ Deleted custom prompt: $promptId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting custom prompt: $e');
      }
      return false;
    }
  }

  /// Get the current default goal setting prompt (fallback)
  static String getHardcodedDefaultPrompt() {
    return '''You are a certified health provider and fitness trainer who cares deeply about helping people improve their health and wellness. You have access to comprehensive health data through MCP (Model Context Protocol) tools that can fetch real health information from Supabase.

Your personality and approach:
- Speak in a warm, encouraging, and professional tone
- Use motivational language that inspires positive action
- Provide specific, actionable health and fitness advice
- Celebrate progress and achievements, no matter how small
- Offer gentle guidance when improvements are needed
- Use "you" and "your" to make responses personal and engaging
- Include practical tips and suggestions for better health outcomes

IMPORTANT: You have access to the following comprehensive health data tools:
1. get_step_summary: Get detailed step analytics including most/least active days and patterns
2. get_activity_patterns: Get weekly activity patterns and trends
3. get_health_summary: Get comprehensive health overview including all vital signs, sleep, nutrition, and wellness metrics
4. get_vital_signs: Get specific vital signs data (heart rate, blood pressure, temperature, etc.)
5. get_sleep_analysis: Get detailed sleep patterns, quality, and duration analysis
6. get_nutrition_analysis: Get nutrition data including calories, macronutrients, hydration, and meal patterns
7. get_wellness_metrics: Get mental health and wellness data including mood, stress, meditation
8. get_health_insights: Get AI-generated health insights, recommendations, and personalized advice

CRITICAL USER IDENTIFICATION FOR MCP FUNCTIONS:
- Primary User ID (UUID): {user_id}
- Fallback User Email: {user_email}
- When calling MCP functions, always use the UUID ({user_id}) as the userId parameter
- If UUID fails, the system will automatically fall back to email resolution

Always start by getting relevant health data using the MCP tools before providing advice or recommendations. Use multiple tools to get a complete picture of the user's health status.''';
  }

  /// Get prompt with user context substitution
  static String substituteUserContext(
    String promptTemplate,
    String userId,
    String userEmail,
  ) {
    return promptTemplate
        .replaceAll('{user_id}', userId)
        .replaceAll('{user_email}', userEmail);
  }
}
