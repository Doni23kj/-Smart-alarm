import '../../domain/entities/user_sleep_profile.dart';

class UserSleepProfileModel {
  UserSleepProfileModel({
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

  int? id;
  late String userId;
  late String goal;
  late String healthState;
  late List<String> reasons;
  late int age;
  late int targetHour;
  late int targetMinute;
  late int fallAsleepMinutes;
  late int fatigueLevel;
  late double sleepQualityIndex;
  late DateTime updatedAt;

  UserSleepProfile toEntity() {
    return UserSleepProfile(
      id: id,
      userId: userId,
      goal: goal,
      healthState: healthState,
      reasons: reasons,
      age: age,
      targetHour: targetHour,
      targetMinute: targetMinute,
      fallAsleepMinutes: fallAsleepMinutes,
      fatigueLevel: fatigueLevel,
      sleepQualityIndex: sleepQualityIndex,
      updatedAt: updatedAt,
    );
  }

  static UserSleepProfileModel fromEntity(UserSleepProfile profile) {
    return UserSleepProfileModel(
      id: profile.id,
      userId: profile.userId,
      goal: profile.goal,
      healthState: profile.healthState,
      reasons: profile.reasons,
      age: profile.age,
      targetHour: profile.targetHour,
      targetMinute: profile.targetMinute,
      fallAsleepMinutes: profile.fallAsleepMinutes,
      fatigueLevel: profile.fatigueLevel,
      sleepQualityIndex: profile.sleepQualityIndex,
      updatedAt: profile.updatedAt,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'user_id': userId,
      'goal': goal,
      'health_state': healthState,
      'reasons': reasons,
      'age': age,
      'target_hour': targetHour,
      'target_minute': targetMinute,
      'fall_asleep_minutes': fallAsleepMinutes,
      'fatigue_level': fatigueLevel,
      'sleep_quality_index': sleepQualityIndex,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
