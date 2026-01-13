import 'player_model.dart';

/// Lightweight club model for owned clubs in user profile
class OwnedClub {
  final String id;
  final String name;
  final String? profilePicture;
  final PlayerAddress? address;

  OwnedClub({
    required this.id,
    required this.name,
    this.profilePicture,
    this.address,
  });

  factory OwnedClub.fromJson(Map<String, dynamic> json) {
    return OwnedClub(
      id: json['id'] as String,
      name: json['name'] as String,
      profilePicture: json['profilePicture'] as String?,
      address: json['address'] != null
          ? PlayerAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (profilePicture != null) 'profilePicture': profilePicture,
      if (address != null) 'address': address!.toJson(),
    };
  }
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Player? player;
  final List<OwnedClub> ownedClubs;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isEmailVerified,
    required this.createdAt,
    this.updatedAt,
    this.player,
    this.ownedClubs = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final playerJson = json['player'];
    Player? parsedPlayer;
    if (playerJson is Map<String, dynamic> && playerJson.isNotEmpty) {
      try {
        parsedPlayer = Player.fromJson(playerJson);
      } catch (_) {
        // If backend sends an empty/partial object, don't crash the app.
        parsedPlayer = null;
      }
    }

    // Parse owned clubs
    final ownedClubsJson = json['ownedClubs'];
    List<OwnedClub> parsedClubs = [];
    if (ownedClubsJson is List && ownedClubsJson.isNotEmpty) {
      try {
        parsedClubs = ownedClubsJson
            .whereType<Map<String, dynamic>>()
            .map((e) => OwnedClub.fromJson(e))
            .toList();
      } catch (_) {
        parsedClubs = [];
      }
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? 'User',
      role: json['role']?.toString() ?? 'USER',
      isEmailVerified: json['isEmailVerified'] == true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString()) 
          : null,
      player: parsedPlayer,
      ownedClubs: parsedClubs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'player': player?.toJson(),
      'ownedClubs': ownedClubs.map((c) => c.toJson()).toList(),
    };
  }

  /// Check if user has any owned clubs
  bool get hasOwnedClubs => ownedClubs.isNotEmpty;

  String getMemberSince() {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[createdAt.month - 1]} ${createdAt.year}';
  }

  String getInitials() {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
