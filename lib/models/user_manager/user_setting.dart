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

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    lightMode: json['lightMode'] as bool,
    autoRotation: json['autoRotation'] as bool,
    aroundAlert: json['aroundAlert'] as bool,
    popularAlert: json['popularAlert'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'lightMode': lightMode,
    'autoRotation': autoRotation,
    'aroundAlert': aroundAlert,
    'popularAlert': popularAlert,
  };

  factory UserSettings.empty() => UserSettings(
    lightMode: false,
    autoRotation: false,
    aroundAlert: true,
    popularAlert: true,
  );
}