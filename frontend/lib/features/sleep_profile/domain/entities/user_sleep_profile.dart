class UserSleepProfile {
  const UserSleepProfile({
    this.id,
    required this.userId,
    required this.goal,
    required this.healthState,
    required this.reasons,
    required this.age,
    required this.targetHour,
    required this.targetMinute,
    required this.fallAsleepMinutes,
    required this.fatigueLevel,
    required this.sleepQualityIndex,
    required this.updatedAt,
  });

  final int? id;
  final String userId;
  final String goal;
  final String healthState;
  final List<String> reasons;
  final int age;
  final int targetHour;
  final int targetMinute;
  final int fallAsleepMinutes;
  final int fatigueLevel;
  final double sleepQualityIndex;
  final DateTime updatedAt;

  UserSleepProfile copyWith({
    int? id,
    String? userId,
    String? goal,
    String? healthState,
    List<String>? reasons,
    int? age,
    int? targetHour,
    int? targetMinute,
    int? fallAsleepMinutes,
    int? fatigueLevel,
    double? sleepQualityIndex,
    DateTime? updatedAt,
  }) {
    return UserSleepProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goal: goal ?? this.goal,
      healthState: healthState ?? this.healthState,
      reasons: reasons ?? this.reasons,
      age: age ?? this.age,
      targetHour: targetHour ?? this.targetHour,
      targetMinute: targetMinute ?? this.targetMinute,
      fallAsleepMinutes: fallAsleepMinutes ?? this.fallAsleepMinutes,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      sleepQualityIndex: sleepQualityIndex ?? this.sleepQualityIndex,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
