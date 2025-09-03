/// Model for custom AI prompts
class CustomAiPrompt {
  final String id;
  final String promptTypeId;
  final String promptName;
  final String promptText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PromptType? promptType;

  const CustomAiPrompt({
    required this.id,
    required this.promptTypeId,
    required this.promptName,
    required this.promptText,
    required this.createdAt,
    required this.updatedAt,
    this.promptType,
  });

  factory CustomAiPrompt.fromMap(Map<String, dynamic> map) {
    return CustomAiPrompt(
      id: map['id'] as String,
      promptTypeId: map['prompt_type_id'] as String,
      promptName: map['prompt_name'] as String,
      promptText: map['prompt_text'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      promptType: map['prompt_type'] != null
          ? PromptType.fromMap(map['prompt_type'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prompt_type_id': promptTypeId,
      'prompt_name': promptName,
      'prompt_text': promptText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CustomAiPrompt copyWith({
    String? id,
    String? promptTypeId,
    String? promptName,
    String? promptText,
    DateTime? createdAt,
    DateTime? updatedAt,
    PromptType? promptType,
  }) {
    return CustomAiPrompt(
      id: id ?? this.id,
      promptTypeId: promptTypeId ?? this.promptTypeId,
      promptName: promptName ?? this.promptName,
      promptText: promptText ?? this.promptText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      promptType: promptType ?? this.promptType,
    );
  }

  @override
  String toString() {
    return 'CustomAiPrompt(id: $id, promptTypeId: $promptTypeId, promptName: $promptName, promptText: ${promptText.substring(0, 50)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomAiPrompt &&
        other.id == id &&
        other.promptTypeId == promptTypeId &&
        other.promptName == promptName &&
        other.promptText == promptText;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        promptTypeId.hashCode ^
        promptName.hashCode ^
        promptText.hashCode;
  }
}

/// Model for prompt types
class PromptType {
  final String id;
  final String keyName;

  const PromptType({required this.id, required this.keyName});

  factory PromptType.fromMap(Map<String, dynamic> map) {
    return PromptType(
      id: map['id'] as String,
      keyName: map['key_name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'key_name': keyName};
  }

  @override
  String toString() {
    return 'PromptType(id: $id, keyName: $keyName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PromptType && other.id == id && other.keyName == keyName;
  }

  @override
  int get hashCode {
    return id.hashCode ^ keyName.hashCode;
  }
}
