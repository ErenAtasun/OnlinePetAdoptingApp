enum PetSpecies {
  dog,
  cat,
  bird,
  rabbit,
  other,
}

enum PetSize {
  small,
  medium,
  large,
}

enum PetStatus {
  available,
  pending,
  adopted,
}

class Pet {
  final String id;
  final String name;
  final int age; // in months
  final PetSpecies species;
  final PetSize size;
  final String description;
  final PetStatus status;
  final String city;
  final List<String> imageUrls;
  final String? healthStatus;
  final String? shelterId;
  final String? shelterName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pet({
    required this.id,
    required this.name,
    required this.age,
    required this.species,
    required this.size,
    required this.description,
    required this.status,
    required this.city,
    required this.imageUrls,
    this.healthStatus,
    this.shelterId,
    this.shelterName,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'species': species.name,
      'size': size.name,
      'description': description,
      'status': status.name,
      'city': city,
      'imageUrls': imageUrls,
      'healthStatus': healthStatus,
      'shelterId': shelterId,
      'shelterName': shelterName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      species: PetSpecies.values.firstWhere(
        (e) => e.name == json['species'],
        orElse: () => PetSpecies.other,
      ),
      size: PetSize.values.firstWhere(
        (e) => e.name == json['size'],
        orElse: () => PetSize.medium,
      ),
      description: json['description'] as String,
      status: PetStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PetStatus.available,
      ),
      city: json['city'] as String,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      healthStatus: json['healthStatus'] as String?,
      shelterId: json['shelterId'] as String?,
      shelterName: json['shelterName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Pet copyWith({
    String? id,
    String? name,
    int? age,
    PetSpecies? species,
    PetSize? size,
    String? description,
    PetStatus? status,
    String? city,
    List<String>? imageUrls,
    String? healthStatus,
    String? shelterId,
    String? shelterName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      species: species ?? this.species,
      size: size ?? this.size,
      description: description ?? this.description,
      status: status ?? this.status,
      city: city ?? this.city,
      imageUrls: imageUrls ?? this.imageUrls,
      healthStatus: healthStatus ?? this.healthStatus,
      shelterId: shelterId ?? this.shelterId,
      shelterName: shelterName ?? this.shelterName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

