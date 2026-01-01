enum AdoptionStatus {
  pending,
  approved,
  rejected,
  cancelled,
}

class AdoptionRequest {
  final String id;
  final String petId;
  final String petName;
  final String? petImageUrl;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhoneNumber;
  final String message;
  final AdoptionStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  AdoptionRequest({
    required this.id,
    required this.petId,
    required this.petName,
    this.petImageUrl,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhoneNumber,
    required this.message,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'petName': petName,
      'petImageUrl': petImageUrl,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhoneNumber': userPhoneNumber,
      'message': message,
      'status': status.name,
      'submittedAt': submittedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  factory AdoptionRequest.fromJson(Map<String, dynamic> json) {
    return AdoptionRequest(
      id: json['id'] as String,
      petId: json['petId'] as String,
      petName: json['petName'] as String,
      petImageUrl: json['petImageUrl'] as String?,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      userPhoneNumber: json['userPhoneNumber'] as String?,
      message: json['message'] as String,
      status: AdoptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AdoptionStatus.pending,
      ),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  AdoptionRequest copyWith({
    String? id,
    String? petId,
    String? petName,
    String? petImageUrl,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhoneNumber,
    String? message,
    AdoptionStatus? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? rejectionReason,
  }) {
    return AdoptionRequest(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      petImageUrl: petImageUrl ?? this.petImageUrl,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhoneNumber: userPhoneNumber ?? this.userPhoneNumber,
      message: message ?? this.message,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

