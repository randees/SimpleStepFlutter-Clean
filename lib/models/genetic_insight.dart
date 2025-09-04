/// Model for genetic insights data
class GeneticInsight {
  final String id;
  final String userId;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? metaData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GeneticInsight({
    required this.id,
    required this.userId,
    this.data,
    this.metaData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GeneticInsight.fromJson(Map<String, dynamic> json) {
    return GeneticInsight(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
      metaData: json['meta_data'] != null
          ? Map<String, dynamic>.from(json['meta_data'] as Map)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'data': data,
      'meta_data': metaData,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GeneticInsight copyWith({
    String? id,
    String? userId,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metaData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GeneticInsight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      data: data ?? this.data,
      metaData: metaData ?? this.metaData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'GeneticInsight(id: $id, userId: $userId, createdAt: $createdAt, dataKeys: ${data?.keys.length ?? 0})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeneticInsight &&
        other.id == id &&
        other.userId == userId &&
        other.data == data &&
        other.metaData == metaData;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ data.hashCode ^ metaData.hashCode;
  }
}
