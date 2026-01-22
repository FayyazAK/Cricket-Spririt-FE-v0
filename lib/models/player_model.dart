import 'bowling_type_model.dart';

class PlayerAddress {
  final String? id;
  final String? street;
  final String? townSuburb;
  final String city;
  final String state;
  final String country;
  final String? postalCode;

  PlayerAddress({
    this.id,
    this.street,
    this.townSuburb,
    required this.city,
    required this.state,
    required this.country,
    this.postalCode,
  });

  factory PlayerAddress.fromJson(Map<String, dynamic> json) {
    return PlayerAddress(
      id: json['id'] as String?,
      street: json['street'] as String?,
      townSuburb: json['townSuburb'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      postalCode: json['postalCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'city': city,
      'state': state,
      'country': country,
    };
    if (id != null) map['id'] = id;
    if (street != null) map['street'] = street;
    if (townSuburb != null) map['townSuburb'] = townSuburb;
    if (postalCode != null) map['postalCode'] = postalCode;
    return map;
  }
}

class Player {
  final String? id;
  final String firstName;
  final String lastName;
  final String gender;
  final DateTime dateOfBirth;
  final String? profilePicture;
  final String playerType;
  final bool isWicketKeeper;
  final String batHand;
  final String? bowlHand;
  final bool isActive;
  final PlayerAddress address;
  final List<BowlingType> bowlingTypes;
  final List<JoinedClub> joinedClubs;
  final List<JoinedTeam> joinedTeams;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Player({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    this.profilePicture,
    required this.playerType,
    required this.isWicketKeeper,
    required this.batHand,
    this.bowlHand,
    this.isActive = true,
    required this.address,
    required this.bowlingTypes,
    this.joinedClubs = const [],
    this.joinedTeams = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      gender: json['gender'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      profilePicture: json['profilePicture'] as String?,
      playerType: json['playerType'] as String,
      isWicketKeeper: json['isWicketKeeper'] as bool,
      batHand: json['batHand'] as String,
      bowlHand: json['bowlHand'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      address: PlayerAddress.fromJson(json['address'] as Map<String, dynamic>),
      bowlingTypes: (json['bowlingTypes'] as List?)
              ?.map((e) => BowlingType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      joinedClubs: (json['joinedClubs'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => JoinedClub.fromJson(e))
              .toList() ??
          const [],
      joinedTeams: (json['joinedTeams'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => JoinedTeam.fromJson(e))
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String().split('T')[0],
      'profilePicture': profilePicture,
      'playerType': playerType,
      'isWicketKeeper': isWicketKeeper,
      'batHand': batHand,
      'bowlHand': bowlHand,
      'isActive': isActive,
      'address': address.toJson(),
      // Keep both shapes:
      // - `bowlingTypes` for local persistence / re-parsing
      // - `bowlingTypeIds` for API update/register payloads (when needed elsewhere)
      'bowlingTypes': bowlingTypes.map((e) => e.toJson()).toList(),
      'bowlingTypeIds': bowlingTypes.map((e) => e.id).toList(),
      'joinedClubs': joinedClubs.map((e) => e.toJson()).toList(),
      'joinedTeams': joinedTeams.map((e) => e.toJson()).toList(),
    };
    
    if (id != null) map['id'] = id;
    if (createdAt != null) map['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) map['updatedAt'] = updatedAt!.toIso8601String();
    
    return map;
  }
}

/// Minimal joined club representation for `/auth/me`
class JoinedClub {
  final String id;
  final String name;
  final String? profilePicture;

  JoinedClub({
    required this.id,
    required this.name,
    this.profilePicture,
  });

  factory JoinedClub.fromJson(Map<String, dynamic> json) {
    return JoinedClub(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      profilePicture: json['profilePicture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (profilePicture != null) 'profilePicture': profilePicture,
    };
  }
}

/// Minimal joined team representation for `/auth/me`
class JoinedTeam {
  final String id;
  final String name;
  final String? logo;
  final String clubId;

  JoinedTeam({
    required this.id,
    required this.name,
    this.logo,
    required this.clubId,
  });

  factory JoinedTeam.fromJson(Map<String, dynamic> json) {
    return JoinedTeam(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logo: json['logo'] as String?,
      clubId: json['clubId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (logo != null) 'logo': logo,
      'clubId': clubId,
    };
  }
}
