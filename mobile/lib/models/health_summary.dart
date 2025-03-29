class SymptomSummary {
  final int count;
  final double avgSeverity;

  SymptomSummary({required this.count, required this.avgSeverity});

  factory SymptomSummary.fromJson(Map<String, dynamic> json) {
    return SymptomSummary(
      count: json['count'],
      avgSeverity: json['avgSeverity'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'avgSeverity': avgSeverity,
    };
  }
}

class HealthSummary {
  final DateTime startDate;
  final DateTime endDate;
  final int entryCount;
  final double moodAverage;
  final double energyAverage;
  final Map<String, SymptomSummary> symptoms;
  final double sleepAverage;
  final int stepsAverage;
  final int restingHRAverage;
  final String narrative;

  HealthSummary({
    required this.startDate,
    required this.endDate,
    required this.entryCount,
    required this.moodAverage,
    required this.energyAverage,
    required this.symptoms,
    required this.sleepAverage,
    required this.stepsAverage,
    required this.restingHRAverage,
    required this.narrative,
  });

  factory HealthSummary.fromJson(Map<String, dynamic> json) {
    final symptomsMap = <String, SymptomSummary>{};
    json['symptoms'].forEach((key, value) {
      symptomsMap[key] = SymptomSummary.fromJson(value);
    });

    return HealthSummary(
      startDate: DateTime.parse(json['period']['start']),
      endDate: DateTime.parse(json['period']['end']),
      entryCount: json['entries'],
      moodAverage: json['mood']['average'].toDouble(),
      energyAverage: json['energy']['average'].toDouble(),
      symptoms: symptomsMap,
      sleepAverage: json['sleep']['average'].toDouble(),
      stepsAverage: json['activity']['averageSteps'],
      restingHRAverage: json['heartRate']['averageResting'],
      narrative: json['narrative'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final symptomsMap = <String, dynamic>{};
    symptoms.forEach((key, value) {
      symptomsMap[key] = value.toJson();
    });

    return {
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'entries': entryCount,
      'mood': {
        'average': moodAverage,
      },
      'energy': {
        'average': energyAverage,
      },
      'symptoms': symptomsMap,
      'sleep': {
        'average': sleepAverage,
      },
      'activity': {
        'averageSteps': stepsAverage,
      },
      'heartRate': {
        'averageResting': restingHRAverage,
      },
      'narrative': narrative,
    };
  }
}
