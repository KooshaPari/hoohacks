class HealthData {
  final String? id;
  final String userId;
  final DateTime date;
  final String dataType;
  final HealthValues values;
  final String source;
  final DateTime createdAt;

  HealthData({
    this.id,
    required this.userId,
    required this.date,
    required this.dataType,
    required this.values,
    required this.source,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      id: json['_id'],
      userId: json['user'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      dataType: json['dataType'] ?? '',
      values: HealthValues.fromJson(json['values'] ?? {}),
      source: json['source'] ?? 'manual_entry',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'user': userId,
      'date': date.toIso8601String(),
      'dataType': dataType,
      'values': values.toJson(),
      'source': source,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class HealthValues {
  // Sleep data
  final double? duration;
  final String? quality;
  final int? deepSleepMinutes;
  final int? remSleepMinutes;
  
  // Activity data
  final int? steps;
  final int? activeCalories;
  final int? exerciseMinutes;
  final int? standHours;
  
  // Heart rate data
  final int? restingHeartRate;
  final int? averageHeartRate;
  final double? heartRateVariability;
  
  // Nutrition data
  final int? calories;
  final double? protein;
  final double? carbohydrates;
  final double? fat;
  final double? water;

  HealthValues({
    this.duration,
    this.quality,
    this.deepSleepMinutes,
    this.remSleepMinutes,
    this.steps,
    this.activeCalories,
    this.exerciseMinutes,
    this.standHours,
    this.restingHeartRate,
    this.averageHeartRate,
    this.heartRateVariability,
    this.calories,
    this.protein,
    this.carbohydrates,
    this.fat,
    this.water,
  });

  factory HealthValues.fromJson(Map<String, dynamic> json) {
    return HealthValues(
      duration: json['duration']?.toDouble(),
      quality: json['quality'],
      deepSleepMinutes: json['deepSleepMinutes'],
      remSleepMinutes: json['remSleepMinutes'],
      steps: json['steps'],
      activeCalories: json['activeCalories'],
      exerciseMinutes: json['exerciseMinutes'],
      standHours: json['standHours'],
      restingHeartRate: json['restingHeartRate'],
      averageHeartRate: json['averageHeartRate'],
      heartRateVariability: json['heartRateVariability']?.toDouble(),
      calories: json['calories'],
      protein: json['protein']?.toDouble(),
      carbohydrates: json['carbohydrates']?.toDouble(),
      fat: json['fat']?.toDouble(),
      water: json['water']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    
    if (duration != null) map['duration'] = duration;
    if (quality != null) map['quality'] = quality;
    if (deepSleepMinutes != null) map['deepSleepMinutes'] = deepSleepMinutes;
    if (remSleepMinutes != null) map['remSleepMinutes'] = remSleepMinutes;
    
    if (steps != null) map['steps'] = steps;
    if (activeCalories != null) map['activeCalories'] = activeCalories;
    if (exerciseMinutes != null) map['exerciseMinutes'] = exerciseMinutes;
    if (standHours != null) map['standHours'] = standHours;
    
    if (restingHeartRate != null) map['restingHeartRate'] = restingHeartRate;
    if (averageHeartRate != null) map['averageHeartRate'] = averageHeartRate;
    if (heartRateVariability != null) map['heartRateVariability'] = heartRateVariability;
    
    if (calories != null) map['calories'] = calories;
    if (protein != null) map['protein'] = protein;
    if (carbohydrates != null) map['carbohydrates'] = carbohydrates;
    if (fat != null) map['fat'] = fat;
    if (water != null) map['water'] = water;
    
    return map;
  }
}

class SleepData extends HealthData {
  SleepData({
    String? id,
    required String userId,
    required DateTime date,
    required double duration,
    String? quality,
    int? deepSleepMinutes,
    int? remSleepMinutes,
    String source = 'manual_entry',
    DateTime? createdAt,
  }) : super(
          id: id,
          userId: userId,
          date: date,
          dataType: 'sleep',
          values: HealthValues(
            duration: duration,
            quality: quality,
            deepSleepMinutes: deepSleepMinutes,
            remSleepMinutes: remSleepMinutes,
          ),
          source: source,
          createdAt: createdAt,
        );
}

class ActivityData extends HealthData {
  ActivityData({
    String? id,
    required String userId,
    required DateTime date,
    required int steps,
    int? activeCalories,
    int? exerciseMinutes,
    int? standHours,
    String source = 'manual_entry',
    DateTime? createdAt,
  }) : super(
          id: id,
          userId: userId,
          date: date,
          dataType: 'activity',
          values: HealthValues(
            steps: steps,
            activeCalories: activeCalories,
            exerciseMinutes: exerciseMinutes,
            standHours: standHours,
          ),
          source: source,
          createdAt: createdAt,
        );
}

class HeartRateData extends HealthData {
  HeartRateData({
    String? id,
    required String userId,
    required DateTime date,
    int? restingHeartRate,
    int? averageHeartRate,
    double? heartRateVariability,
    String source = 'manual_entry',
    DateTime? createdAt,
  }) : super(
          id: id,
          userId: userId,
          date: date,
          dataType: 'heartRate',
          values: HealthValues(
            restingHeartRate: restingHeartRate,
            averageHeartRate: averageHeartRate,
            heartRateVariability: heartRateVariability,
          ),
          source: source,
          createdAt: createdAt,
        );
}

class NutritionData extends HealthData {
  NutritionData({
    String? id,
    required String userId,
    required DateTime date,
    int? calories,
    double? protein,
    double? carbohydrates,
    double? fat,
    double? water,
    String source = 'manual_entry',
    DateTime? createdAt,
  }) : super(
          id: id,
          userId: userId,
          date: date,
          dataType: 'nutrition',
          values: HealthValues(
            calories: calories,
            protein: protein,
            carbohydrates: carbohydrates,
            fat: fat,
            water: water,
          ),
          source: source,
          createdAt: createdAt,
        );
}
