class BowlingType {
  final String id;
  final String shortName;
  final String fullName;

  BowlingType({
    required this.id,
    required this.shortName,
    required this.fullName,
  });

  factory BowlingType.fromJson(Map<String, dynamic> json) {
    return BowlingType(
      id: json['id'] as String,
      shortName: json['shortName'] as String,
      fullName: json['fullName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shortName': shortName,
      'fullName': fullName,
    };
  }
}
