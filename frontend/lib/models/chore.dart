class ChoreCategory {
  final String id;
  final String name;
  final String icon;
  final String type;

  ChoreCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });

  factory ChoreCategory.fromJson(Map<String, dynamic> json) {
    return ChoreCategory(
      id: json['_id'],
      name: json['name'],
      icon: json['icon'],
      type: json['type'],
    );
  }
}

class ChoreSchedule {
  final String id;
  final String roomId;
  final ChoreCategory category;
  final String assignedTo;
  final DateTime date;
  final bool isCompleted;
  final DateTime? completedAt;

  ChoreSchedule({
    required this.id,
    required this.roomId,
    required this.category,
    required this.assignedTo,
    required this.date,
    required this.isCompleted,
    this.completedAt,
  });

  factory ChoreSchedule.fromJson(Map<String, dynamic> json) {
    return ChoreSchedule(
      id: json['_id'],
      roomId: json['room'],
      category: ChoreCategory.fromJson(json['category']),
      assignedTo: json['assignedTo'],
      date: DateTime.parse(json['date']),
      isCompleted: json['isCompleted'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}