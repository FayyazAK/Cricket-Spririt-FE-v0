import 'player_model.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Player? player;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isEmailVerified,
    required this.createdAt,
    this.updatedAt,
    this.player,
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
    };
  }

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
