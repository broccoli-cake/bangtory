class RoomModel {
  final String roomId;
  final String roomName;
  final String? address;
  final bool isOwner;
  final String? inviteCode;
  final int? expiresIn;

  RoomModel({
    required this.roomId,
    required this.roomName,
    this.address,
    required this.isOwner,
    this.inviteCode,
    this.expiresIn,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomId: json['roomId'],
      roomName: json['roomName'],
      address: json['address'],
      isOwner: json['isOwner'] ?? false,
      inviteCode: json['inviteCode'],
      expiresIn: json['expiresIn'],
    );
  }
}