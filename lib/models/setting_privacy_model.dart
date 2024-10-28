class SettingPrivacyModel {
  final String name;
  final String id;
  final String email;
  final String? password;
  final String? rePassword;
  final String? verifyNum;
  
  SettingPrivacyModel({
    required this.name,
    required this.id,
    required this.email,
    this.password,
    this.rePassword,
    this.verifyNum,
  });
}