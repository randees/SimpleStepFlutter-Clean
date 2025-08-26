class MCPMessage {
  final String method;
  final Map<String, dynamic>? params;
  final String? id;

  MCPMessage({required this.method, this.params, this.id});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'method': method};

    if (params != null) {
      json['params'] = params;
    }

    if (id != null) {
      json['id'] = id;
    }

    return json;
  }

  factory MCPMessage.fromJson(Map<String, dynamic> json) {
    return MCPMessage(
      method: json['method'] as String,
      params: json['params'] as Map<String, dynamic>?,
      id: json['id'] as String?,
    );
  }
}

class MCPResponse {
  final Map<String, dynamic>? result;
  final MCPError? error;
  final String? id;

  MCPResponse({this.result, this.error, this.id});

  bool get isSuccess => error == null;

  factory MCPResponse.fromJson(Map<String, dynamic> json) {
    return MCPResponse(
      result: json['result'] as Map<String, dynamic>?,
      error: json['error'] != null
          ? MCPError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (result != null) {
      json['result'] = result;
    }

    if (error != null) {
      json['error'] = error!.toJson();
    }

    if (id != null) {
      json['id'] = id;
    }

    return json;
  }
}

class MCPError {
  final int code;
  final String message;
  final dynamic data;

  MCPError({required this.code, required this.message, this.data});

  factory MCPError.fromJson(Map<String, dynamic> json) {
    return MCPError(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'code': code, 'message': message};

    if (data != null) {
      json['data'] = data;
    }

    return json;
  }
}
