class FolderModel {
  final int folderId;
  final int? generatorId;
  final String? name;
  final String? link;
  final String? content;
  final int? createdDateTime;

  FolderModel({
    required this.folderId,
    required this.generatorId,
    this.name,
    this.link,
    this.content,
    this.createdDateTime,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      folderId: json['folderId'],
      generatorId: json['generatorId'],
      name: json['folderName'] ?? '',
      link: json['link'] ?? '',
      content: json['content'],
      createdDateTime: json['createdDateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folderId': folderId,
      'generatorId': generatorId,
      'folderName': name,
      'link': link,
      'content': content,
      'createdDateTime': createdDateTime,
    };
  }
}