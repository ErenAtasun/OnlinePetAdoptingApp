enum AdoptionRequestStatus {
  pending,
  approved,
  rejected,
}

class AdoptionRequest {
  final String id;
  final String petId;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final AdoptionRequestStatus status;
  final String? message;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AdoptionRequest({
    required this.id,
    required this.petId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.status,
    this.message,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'status': status.name,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AdoptionRequest.fromJson(Map<String, dynamic> json) {
    return AdoptionRequest(
      id: json['id'] as String,
      petId: json['petId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      userPhone: json['userPhone'] as String?,
      status: AdoptionRequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AdoptionRequestStatus.pending,
      ),
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  AdoptionRequest copyWith({
    String? id,
    String? petId,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    AdoptionRequestStatus? status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdoptionRequest(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

