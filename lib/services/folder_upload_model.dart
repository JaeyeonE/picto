class FolderUploadModel{
  final int? photoId;
  final int? userId;
  final int? folderId;
  final int? dateTime;

  FolderUploadModel({
    this.photoId,
    this.userId,
    this.folderId,
    this.dateTime,
  });

  factory FolderUploadModel.fromJson(Map<String, dynamic> json){
    return FolderUploadModel(
      photoId: json['photoId'] as int ?? 0,
      userId: json['userId'] as int ?? 0,
      folderId: json['folderId'] as int ?? 0,
      dateTime: json['savedDatetime'] as int ?? 0,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'photoId': photoId,
      'userId': userId,
      'folderId': folderId,
      'savedDatetime': dateTime,
    };
  }
}