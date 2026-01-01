class AppNotification {
  final String id;
  final String userId;
  final String message;
  final DateTime date;
  final bool isRead;
  final String? type; // e.g., 'adoption_status', 'application_review', etc.

  AppNotification({
    required this.id,
    required this.userId,
    required this.message,
    required this.date,
    this.isRead = false,
    this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'message': message,
      'date': date.toIso8601String(),
      'isRead': isRead,
      'type': type,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      message: json['message'] as String,
      date: DateTime.parse(json['date'] as String),
      isRead: json['isRead'] as bool? ?? false,
      type: json['type'] as String?,
    );
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? message,
    DateTime? date,
    bool? isRead,
    String? type,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

