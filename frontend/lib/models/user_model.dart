class UserModel {
  final String id;
  final String nickname;
  final String profileImageUrl;
  final bool isProfileSet;

  UserModel({
    required this.id,
    required this.nickname,
    required this.profileImageUrl,
    required this.isProfileSet,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      nickname: json['nickname'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '/images/default-profile.png',
      isProfileSet: json['isProfileSet'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
      'isProfileSet': isProfileSet,
    };
  }
}