class UserUpdateRequest {
  final int userId;
  final String? email;
  final String? password;
  final String? accountName;
  final String? name;
  final String? intro;
  final String? profilePhotoPath;
  final bool? profileActive;
  final String? type;

  UserUpdateRequest({
    required this.userId,
    this.email,
    this.password,
    this.accountName,
    this.name,
    this.intro,
    this.profilePhotoPath,
    this.profileActive,
    this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (accountName != null) 'accountName': accountName,
      if (name != null) 'name': name,
      if (intro != null) 'intro': intro,
      if (profilePhotoPath != null) 'profilePhotoPath': profilePhotoPath,
      if (profileActive != null) 'profileActive': profileActive,
      if (type != null) 'type': type,
    };
  }
}