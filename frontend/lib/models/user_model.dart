class UserModel {
  final String id;
  final String name; // nickname -> name으로 변경

  UserModel({
    required this.id,
    required this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// 방 멤버 프로필 정보를 위한 새로운 모델
class UserProfileModel {
  final String userId;
  final String nickname;
  final String profileImageUrl;

  UserProfileModel({
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'] ?? json['_id'] ?? '',
      nickname: json['nickname'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '/images/profile1.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
    };
  }
}