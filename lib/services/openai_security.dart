import '../models/user_model.dart';

/// Security utilities for OpenAI API interactions
class OpenAISecurity {
  // Dangerous patterns that could be prompt injection attempts
  static final List<RegExp> _dangerousPatterns = [
    RegExp(r'ignore\s+previous\s+instructions', caseSensitive: false),
    RegExp(r'forget\s+everything', caseSensitive: false),
    RegExp(r'system\s*:', caseSensitive: false),
    RegExp(r'assistant\s*:', caseSensitive: false),
    RegExp(r'<\s*script\s*>', caseSensitive: false),
    RegExp(r'javascript\s*:', caseSensitive: false),
    RegExp(r'data\s*:', caseSensitive: false),
    RegExp(r'CREATE\s+TABLE', caseSensitive: false),
    RegExp(r'DROP\s+TABLE', caseSensitive: false),
    RegExp(r'DELETE\s+FROM', caseSensitive: false),
    RegExp(r'UPDATE\s+.*\s+SET', caseSensitive: false),
  ];

  /// Sanitize user input to prevent prompt injection
  static String sanitizeInput(String input) {
    // Remove null bytes and other control characters
    String sanitized = input.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');

    // Limit length to prevent token exhaustion attacks
    if (sanitized.length > 2000) {
      sanitized = sanitized.substring(0, 2000);
    }

    // Remove multiple consecutive newlines
    sanitized = sanitized.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return sanitized.trim();
  }

  /// Check for potential prompt injection attempts
  static bool isPromptInjection(String input) {
    final normalizedInput = input.toLowerCase();

    return _dangerousPatterns.any(
      (pattern) => pattern.hasMatch(normalizedInput),
    );
  }

  /// Validate that input is safe for OpenAI
  static ValidationResult validateInput(String input) {
    if (input.isEmpty) {
      return ValidationResult(false, 'Input cannot be empty');
    }

    if (input.length > 2000) {
      return ValidationResult(false, 'Input too long (max 2000 characters)');
    }

    if (isPromptInjection(input)) {
      return ValidationResult(
        false,
        'Input contains potentially dangerous content',
      );
    }

    return ValidationResult(true, 'Input is valid');
  }

  /// Validate system prompt to ensure it hasn't been tampered with
  static bool validateSystemPrompt(String prompt, String expectedChecksum) {
    // In production, you'd use a proper hash function
    final actualChecksum = prompt.hashCode.toString();
    return actualChecksum == expectedChecksum;
  }

  /// Create a secure context object for OpenAI
  static Map<String, dynamic> createSecureContext(UserModel user) {
    return {
      'user_id': user.id,
      'user_name': sanitizeInput(user.friendlyName),
      'user_email': user.email, // Already validated by auth
      'timestamp': DateTime.now().toIso8601String(),
      // Don't include sensitive data like health conditions directly
    };
  }
}

class ValidationResult {
  final bool isValid;
  final String message;

  ValidationResult(this.isValid, this.message);
}
