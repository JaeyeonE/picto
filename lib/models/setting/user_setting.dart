class UserSettings {
  final bool lightMode;
  final bool autoRotation;
  final bool aroundAlert;
  final bool popularAlert;

  UserSettings({
    required this.lightMode,
    required this.autoRotation,
    required this.aroundAlert,
    required this.popularAlert,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      lightMode: json['lightMode'],
      autoRotation: json['autoRotation'],
      aroundAlert: json['aroundAlert'],
      popularAlert: json['popularAlert'],
    );
  }

  Map<String, dynamic> toJson() => {
    'lightMode': lightMode,
    'autoRotation': autoRotation,
    'aroundAlert': aroundAlert,
    'popularAlert': popularAlert,
  };
}