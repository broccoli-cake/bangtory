import 'package:flutter/material.dart';

class IconUtils {
  // 아이콘 이름을 IconData로 변환하는 매핑
  static const Map<String, IconData> iconMap = {
    // 기본 아이콘
    'category': Icons.category,
    'star': Icons.star,
    'favorite': Icons.favorite,
    'home': Icons.home,
    'work': Icons.work,
    'school': Icons.school,

    // 집안일 관련
    'cleaning_services': Icons.cleaning_services,
    'delete_outline': Icons.delete_outline,
    'local_dining': Icons.local_dining,
    'kitchen': Icons.kitchen,
    'local_laundry_service': Icons.local_laundry_service,
    'iron': Icons.iron,
    'checkroom': Icons.checkroom,

    // 예약 관련
    'bathtub': Icons.bathtub,
    'emoji_people': Icons.emoji_people,
    'meeting_room': Icons.meeting_room,
    'weekend': Icons.weekend,
    'bed': Icons.bed,
    'fitness_center': Icons.fitness_center,
    'restaurant': Icons.restaurant,
    'medical_services': Icons.medical_services,
    'garage': Icons.garage,
    'balcony': Icons.balcony,
    'wc': Icons.wc,
    'grass': Icons.grass,
    'shopping_cart': Icons.shopping_cart,
    'flight': Icons.flight,
  };

  // 아이콘 이름으로부터 IconData 가져오기
  static IconData getIconData(String iconName) {
    return iconMap[iconName] ?? Icons.category;
  }

  // 카테고리 이름으로부터 기본 아이콘 추론
  static IconData getDefaultIconForCategory(String categoryName) {
    final defaultIcons = {
      // 집안일
      '청소': Icons.cleaning_services,
      '분리수거': Icons.delete_outline,
      '설거지': Icons.local_dining,

      // 예약
      '욕실': Icons.bathtub,
      '세탁기': Icons.local_laundry_service,
      '방문객': Icons.emoji_people,
      '주방': Icons.kitchen,
      '거실': Icons.weekend,
      '방': Icons.bed,
      '화장실': Icons.wc,
      '발코니': Icons.balcony,
      '정원': Icons.grass,
      '차고': Icons.garage,
      '운동': Icons.fitness_center,
      '공부': Icons.school,
      '회의': Icons.meeting_room,
      '음식': Icons.restaurant,
      '쇼핑': Icons.shopping_cart,
      '의료': Icons.medical_services,
      '여행': Icons.flight,
      '업무': Icons.work,
    };

    return defaultIcons[categoryName] ?? Icons.category;
  }

  // 집안일용 아이콘 목록
  static Map<String, IconData> getChoreIcons() {
    return {
      'category': Icons.category,
      'star': Icons.star,
      'home': Icons.home,
      'cleaning_services': Icons.cleaning_services,
      'delete_outline': Icons.delete_outline,
      'local_dining': Icons.local_dining,
      'kitchen': Icons.kitchen,
      'local_laundry_service': Icons.local_laundry_service,
      'iron': Icons.iron,
      'checkroom': Icons.checkroom,
      'work': Icons.work,
      'school': Icons.school,
    };
  }

  // 예약용 아이콘 목록
  static Map<String, IconData> getReservationIcons() {
    return {
      'category': Icons.category,
      'star': Icons.star,
      'home': Icons.home,
      'bathtub': Icons.bathtub,
      'local_laundry_service': Icons.local_laundry_service,
      'emoji_people': Icons.emoji_people,
      'meeting_room': Icons.meeting_room,
      'weekend': Icons.weekend,
      'bed': Icons.bed,
      'kitchen': Icons.kitchen,
      'fitness_center': Icons.fitness_center,
      'restaurant': Icons.restaurant,
      'medical_services': Icons.medical_services,
      'garage': Icons.garage,
      'balcony': Icons.balcony,
      'wc': Icons.wc,
      'grass': Icons.grass,
      'shopping_cart': Icons.shopping_cart,
      'flight': Icons.flight,
      'work': Icons.work,
    };
  }
}