class AppSettings{
  final bool lightMode;
  final bool autoRotation;
  // 알림 설정
  final bool photoNearby;
  final bool photoPopular;
  final bool newContest;
  final bool favoriteTags;
  final List<String>? selectedTags; // 선택된 태그들
  final DateTime? sleepModeStart;
  final DateTime? sleepModeEnd;

  AppSettings({
    this.lightMode = true,
    this.autoRotation = false, // true: 가로사진 세로로 돌림, false: 가로사진 그대로 보여줌
    this.photoNearby = false,
    this.photoPopular = false,
    this.newContest = false,
    this.favoriteTags = false,
    this.selectedTags,
    this.sleepModeStart,
    this.sleepModeEnd,
  });
}