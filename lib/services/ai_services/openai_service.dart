import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'conversation_service.dart';
import '../../models/openai_function.dart';
import '../../config/openai_config.dart';

/// Enhanced response model for OpenAI API calls
class OpenAIResponse {
  final String content;
  final String model;
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;
  final List<Map<String, dynamic>>? toolCalls;

  OpenAIResponse({
    required this.content,
    required this.model,
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
    this.toolCalls,
  });
}

/// Service for handling OpenAI API interactions
class OpenAIService {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  /// Call OpenAI API with conversation context and MCP function calling
  Future<OpenAIResponse> callOpenAI({
    required String userMessage,
    required String systemPrompt,
    required List<ChatMessage> conversationContext,
    required Future<String> Function(String, Map<String, dynamic>)
    executeMCPFunction,
  }) async {
    final apiKey = OpenAIConfig.apiKey;

    // Validate API key
    if (apiKey.isEmpty || apiKey == 'REPLACE_WITH_YOUR_OPENAI_API_KEY') {
      return OpenAIResponse(
        content: 'Error: OpenAI API key not configured. Please set OPENAI_API_KEY in your .env file.',
        model: 'gpt-3.5-turbo',
      );
    }

    if (!OpenAIConfig.hasValidApiKeyFormat) {
      return OpenAIResponse(
        content: 'Error: Invalid OpenAI API key format. Please check your OPENAI_API_KEY in the .env file.',
        model: 'gpt-3.5-turbo',
      );
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    // Define available tools for OpenAI
    final tools = HealthDataFunctions.getAllFunctions()
        .map((f) => {'type': 'function', 'function': f.toJson()})
        .toList();

    // Build messages array
    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    // Add conversation history
    for (final chatMessage in conversationContext) {
      messages.add({
        'role': chatMessage.isUser ? 'user' : 'assistant',
        'content': chatMessage.message,
      });
    }

    // Add current user message
    messages.add({'role': 'user', 'content': userMessage});

    if (kDebugMode) {
      print('📤 Sending ${messages.length} messages to OpenAI');
    }

    try {
      final body = json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': messages,
        'tools': tools,
        'tool_choice': 'auto',
        'max_tokens': 500,
        'temperature': 0.7,
      });

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('OpenAI API Error: ${response.statusCode} - ${response.body}');
        }
        return OpenAIResponse(
          content: 'Error: Unable to get AI response. Status: ${response.statusCode}',
          model: 'gpt-3.5-turbo',
        );
      }

      final data = json.decode(response.body);
      final choice = data['choices'][0];
      final message = choice['message'];

      // Check if AI wants to call a tool
      if (message['tool_calls'] != null && message['tool_calls'].isNotEmpty) {
        final toolCalls = message['tool_calls'] as List;

        // Process each tool call
        for (final toolCall in toolCalls) {
          final toolCallId = toolCall['id'];
          final function = toolCall['function'];
          final functionName = function['name'];
          final functionArgs = json.decode(function['arguments']);

          if (kDebugMode) {
            print('🔧 AI calling function: $functionName');
          }

          // Execute MCP function
          final functionResult = await executeMCPFunction(
            functionName,
            functionArgs,
          );

          // Add tool call and result to messages for follow-up
          messages.add(message);
          messages.add({
            'role': 'tool',
            'tool_call_id': toolCallId,
            'content': functionResult,
          });

          // Make follow-up call
          final followUpBody = json.encode({
            'model': 'gpt-3.5-turbo',
            'messages': messages,
            'max_tokens': 500,
            'temperature': 0.7,
          });

          final followUpResponse = await http.post(
            Uri.parse(_apiUrl),
            headers: headers,
            body: followUpBody,
          );

          if (followUpResponse.statusCode == 200) {
            final followUpData = json.decode(followUpResponse.body);
            final followUpChoice = followUpData['choices'][0];
            final usage = followUpData['usage'];

            return OpenAIResponse(
              content: followUpChoice['message']['content'] ?? 'No response',
              model: 'gpt-3.5-turbo',
              promptTokens: usage?['prompt_tokens'],
              completionTokens: usage?['completion_tokens'],
              totalTokens: usage?['total_tokens'],
            );
          }
        }
      } else {
        // Direct response without tool calls
        final usage = data['usage'];
        return OpenAIResponse(
          content: message['content'] ?? 'No response',
          model: 'gpt-3.5-turbo',
          promptTokens: usage?['prompt_tokens'],
          completionTokens: usage?['completion_tokens'],
          totalTokens: usage?['total_tokens'],
        );
      }

      return OpenAIResponse(
        content: 'I gathered some health data but ran into processing limits. Please try asking a more specific question.',
        model: 'gpt-3.5-turbo',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Network Error: $e');
      }
      return OpenAIResponse(
        content: 'Error: Network issue connecting to AI service.',
        model: 'gpt-3.5-turbo',
      );
    }
  }
}
