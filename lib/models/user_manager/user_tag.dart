class UserTag {
  final String tagName;

  UserTag({
    required this.tagName,
  });

  factory UserTag.fromJson(Map<String, dynamic> json) => UserTag(
    tagName: json['tagName'],
  );

  Map<String, dynamic> toJson() => {
    'tagName': tagName,
  };

  // 빈 태그 생성
  factory UserTag.empty() => UserTag(
    tagName: '',
  );

  // equals 메서드 추가 (태그 비교 시 유용)
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is UserTag &&
    runtimeType == other.runtimeType &&
    tagName == other.tagName;

  @override
  int get hashCode => tagName.hashCode;
}