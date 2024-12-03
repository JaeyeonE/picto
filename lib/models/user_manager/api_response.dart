class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJson) {
    return ApiResponse(
      success: json['success'] ?? true,
      message: json['message'],
      data: json['data'] != null && fromJson != null ? fromJson(json['data']) : null,
    );
  }
}