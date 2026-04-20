class SleepQualityAlgorithm {
  const SleepQualityAlgorithm._();

  static double calculate({
    required int fallAsleepMinutes,
    required int fatigueLevel,
    required int age,
  }) {
    final normalizedSleepLatency = (100 - fallAsleepMinutes).clamp(0, 100);
    final normalizedFatigue = (100 - (fatigueLevel * 10)).clamp(0, 100);
    final normalizedAge = _ageScore(age);

    final score =
        (normalizedSleepLatency * 0.45) +
        (normalizedFatigue * 0.35) +
        (normalizedAge * 0.20);

    return double.parse(score.toStringAsFixed(1));
  }

  static int _ageScore(int age) {
    if (age <= 25) return 92;
    if (age <= 35) return 88;
    if (age <= 45) return 82;
    if (age <= 60) return 76;
    return 70;
  }
}
