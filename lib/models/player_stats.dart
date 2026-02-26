class PlayerStats {
  final int level;
  final String rank;
  final int exp;
  final int strength;
  final int agility;
  final int vitality;
  final int sense;
  final int intelligence;
  final int statPoints;
  final String hunterClass;
  final bool isPlayerAwakened;
  final String preferredWorkoutType; // "HOME", "CALISTHENICS", "GYM", or "NONE"

  PlayerStats({
    required this.level,
    required this.rank,
    required this.exp,
    required this.strength,
    required this.agility,
    required this.vitality,
    required this.sense,
    required this.intelligence,
    required this.statPoints,
    this.hunterClass = "NONE",
    this.isPlayerAwakened = false,
    this.preferredWorkoutType = "NONE",
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      level: json['level'] ?? 1,
      rank: json['rank'] ?? "E",
      exp: json['exp'] ?? 0,
      strength: json['strength'] ?? 5,
      agility: json['agility'] ?? 5,
      vitality: json['vitality'] ?? 5,
      sense: json['sense'] ?? 5,
      intelligence: json['intelligence'] ?? 5,
      statPoints: json['statPoints'] ?? 0,
      hunterClass: json['hunterClass'] ?? "NONE",
      isPlayerAwakened: json['isPlayerAwakened'] ?? false,
      preferredWorkoutType: json['preferredWorkoutType'] ?? "NONE",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'rank': rank,
      'exp': exp,
      'strength': strength,
      'agility': agility,
      'vitality': vitality,
      'sense': sense,
      'intelligence': intelligence,
      'statPoints': statPoints,
      'hunterClass': hunterClass,
      'isPlayerAwakened': isPlayerAwakened,
      'preferredWorkoutType': preferredWorkoutType,
    };
  }

  PlayerStats copyWith({
    int? level,
    String? rank,
    int? exp,
    int? strength,
    int? agility,
    int? vitality,
    int? sense,
    int? intelligence,
    int? statPoints,
    String? hunterClass,
    bool? isPlayerAwakened,
    String? preferredWorkoutType,
  }) {
    return PlayerStats(
      level: level ?? this.level,
      rank: rank ?? this.rank,
      exp: exp ?? this.exp,
      strength: strength ?? this.strength,
      agility: agility ?? this.agility,
      vitality: vitality ?? this.vitality,
      sense: sense ?? this.sense,
      intelligence: intelligence ?? this.intelligence,
      statPoints: statPoints ?? this.statPoints,
      hunterClass: hunterClass ?? this.hunterClass,
      isPlayerAwakened: isPlayerAwakened ?? this.isPlayerAwakened,
      preferredWorkoutType: preferredWorkoutType ?? this.preferredWorkoutType,
    );
  }
}
