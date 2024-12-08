// invite_model.dart

class Invite {
  final int id;
  final String type;
  final int senderId;
  final int receiverId;
  final int folderId;
  final String folderName;
  final int createdDatetime;

  Invite({
    required this.id,
    required this.type,
    required this.senderId,
    required this.receiverId,
    required this.folderId,
    required this.folderName,
    required this.createdDatetime,
  });

  // JSON에서 Invite 객체로 변환
  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      id: json['id'] as int,
      type: json['type'] as String,
      senderId: json['senderId'] as int,
      receiverId: json['receiverId'] as int,
      folderId: json['folderId'] as int,
      folderName: json['folderName'] as String,
      createdDatetime: json['createdDatetime'] as int,
    );
  }

  // Invite 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'senderId': senderId,
      'receiverId': receiverId,
      'folderId': folderId,
      'folderName': folderName,
      'createdDatetime': createdDatetime,
    };
  }

  // 객체 복사본 생성 with 메서드
  Invite copyWith({
    int? id,
    String? type,
    int? senderId,
    int? receiverId,
    int? folderId,
    String? folderName,
    int? createdDatetime,
  }) {
    return Invite(
      id: id ?? this.id,
      type: type ?? this.type,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      folderId: folderId ?? this.folderId,
      folderName: folderName ?? this.folderName,
      createdDatetime: createdDatetime ?? this.createdDatetime,
    );
  }
}