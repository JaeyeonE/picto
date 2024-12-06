class Status{
  final bool isSuccess;
  final int code;
  final String message;

  Status({
    required this.isSuccess,
    required this.code,
    required this.message,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      isSuccess: json['isSuccess'],
      code: json['code'],
      message: json['message']
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSucess': isSuccess,
      'code': code,
      'message': message,
    };
  }
}