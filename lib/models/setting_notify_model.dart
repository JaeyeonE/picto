class SettingNotifyModel {
  final bool photoNearby;
  final bool photoPopular;
  final bool newContest;
  final bool favoriteTags;
  final DateTime? sleepModeStart;
  final DateTime? sleepModeEnd;

  SettingNotifyModel({
    required this.photoNearby,
    required this.photoPopular,
    required this.newContest,
    required this.favoriteTags,
    this.sleepModeStart,
    this.sleepModeEnd,
  });
}