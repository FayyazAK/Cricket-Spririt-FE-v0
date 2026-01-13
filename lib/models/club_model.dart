import 'player_model.dart';

class Club {
  final String id;
  final String name;
  final String? profilePicture;
  final String? bio;
  final DateTime? establishedDate;
  final PlayerAddress address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Club({
    required this.id,
    required this.name,
    this.profilePicture,
    this.bio,
    this.establishedDate,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as String,
      name: json['name'] as String,
      profilePicture: json['profilePicture'] as String?,
      bio: json['bio'] as String?,
      establishedDate: json['establishedDate'] != null
          ? DateTime.tryParse(json['establishedDate'] as String)
          : null,
      address: PlayerAddress.fromJson(json['address'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (profilePicture != null) 'profilePicture': profilePicture,
      if (bio != null) 'bio': bio,
      if (establishedDate != null)
        'establishedDate': establishedDate!.toIso8601String().split('T')[0],
      'address': address.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
