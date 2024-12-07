class UserFilter {
  final String sort;          // "조회수순", "좋아요순" 등
  final String period;        // "일주일", "한달" 등
  final int startDatetime;    // 시작 시간 timestamp
  final int endDatetime;      // 종료 시간 timestamp

  UserFilter({
    required this.sort,
    required this.period,
    required this.startDatetime,
    required this.endDatetime,
  });

  factory UserFilter.fromJson(Map<String, dynamic> json) => UserFilter(
    sort: json['sort'],
    period: json['period'],
    startDatetime: json['startDatetime'],
    endDatetime: json['endDatetime'],
  );

  Map<String, dynamic> toJson() => {
    'sort': sort,
    'period': period,
    'startDatetime': startDatetime,
    'endDatetime': endDatetime,
  };

  // 기본값을 가진 빈 필터 생성
  factory UserFilter.empty() => UserFilter(
    sort: '좋아요순',
    period: '한달',
    startDatetime: DateTime.now().millisecondsSinceEpoch,
    endDatetime: DateTime.now().millisecondsSinceEpoch,
  );
}