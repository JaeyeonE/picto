class FolderModel {
  final int? folderId;
  final String name;
  final String? link;
  final String content;
  final int? createdDateTime;

  FolderModel({
    this.folderId,
    required this.name,
    this.link,
    required this.content,
    this.createdDateTime,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      folderId: json['generatorId'],
      name: json['name'],
      link: json['link'],
      content: json['content'],
      createdDateTime: json['createdDateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'content': content,
    };
  }
}