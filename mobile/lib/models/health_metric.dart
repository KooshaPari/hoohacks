class HealthMetric {
  final String type; // 'sleep', 'activity', 'heartRate'
  final DateTime timestamp;
  
  // Sleep metrics
  double? duration; // in hours
  String? quality; // 'poor', 'fair', 'good'
  
  // Activity metrics
  int? steps;
  int? activeCalories;
  
  // Heart rate metrics
  int? resting; // resting heart rate
  int? average; // average heart rate

  HealthMetric({
    required this.type,
    required this.timestamp,
    this.duration,
    this.quality,
    this.steps,
    this.activeCalories,
    this.resting,
    this.average,
  });

  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      duration: json['duration']?.toDouble(),
      quality: json['quality'],
      steps: json['steps'],
      activeCalories: json['activeCalories'],
      resting: json['resting'],
      average: json['average'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      if (duration != null) 'duration': duration,
      if (quality != null) 'quality': quality,
      if (steps != null) 'steps': steps,
      if (activeCalories != null) 'activeCalories': activeCalories,
      if (resting != null) 'resting': resting,
      if (average != null) 'average': average,
    };
  }
}
