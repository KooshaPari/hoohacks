class WeeklySummary {
  final SummaryPeriod period;
  final int entries;
  final MoodSummary mood;
  final EnergySummary energy;
  final Map<String, SymptomSummary> symptoms;
  final SleepSummary sleep;
  final ActivitySummary activity;
  final HeartRateSummary heartRate;
  final String narrative;

  WeeklySummary({
    required this.period,
    required this.entries,
    required this.mood,
    required this.energy,
    required this.symptoms,
    required this.sleep,
    required this.activity,
    required this.heartRate,
    required this.narrative,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? {};
    final Map<String, SymptomSummary> symptomsMap = {};
    
    if (summary['symptoms'] != null) {
      summary['symptoms'].forEach((key, value) {
        symptomsMap[key] = SymptomSummary.fromJson(value);
      });
    }
    
    return WeeklySummary(
      period: SummaryPeriod.fromJson(summary['period'] ?? {}),
      entries: summary['entries'] ?? 0,
      mood: MoodSummary.fromJson(summary['mood'] ?? {}),
      energy: EnergySummary.fromJson(summary['energy'] ?? {}),
      symptoms: symptomsMap,
      sleep: SleepSummary.fromJson(summary['sleep'] ?? {}),
      activity: ActivitySummary.fromJson(summary['activity'] ?? {}),
      heartRate: HeartRateSummary.fromJson(summary['heartRate'] ?? {}),
      narrative: json['narrative'] ?? '',
    );
  }
}

class SummaryPeriod {
  final DateTime start;
  final DateTime end;

  SummaryPeriod({
    required this.start,
    required this.end,
  });

  factory SummaryPeriod.fromJson(Map<String, dynamic> json) {
    return SummaryPeriod(
      start: json['start'] != null ? DateTime.parse(json['start']) : DateTime.now().subtract(const Duration(days: 7)),
      end: json['end'] != null ? DateTime.parse(json['end']) : DateTime.now(),
    );
  }
}

class MoodSummary {
  final double average;

  MoodSummary({
    required this.average,
  });

  factory MoodSummary.fromJson(Map<String, dynamic> json) {
    return MoodSummary(
      average: (json['average'] ?? 0).toDouble(),
    );
  }
}

class EnergySummary {
  final double average;

  EnergySummary({
    required this.average,
  });

  factory EnergySummary.fromJson(Map<String, dynamic> json) {
    return EnergySummary(
      average: (json['average'] ?? 0).toDouble(),
    );
  }
}

class SymptomSummary {
  final int count;
  final double avgSeverity;

  SymptomSummary({
    required this.count,
    required this.avgSeverity,
  });

  factory SymptomSummary.fromJson(Map<String, dynamic> json) {
    return SymptomSummary(
      count: json['count'] ?? 0,
      avgSeverity: (json['avgSeverity'] ?? 0).toDouble(),
    );
  }
}

class SleepSummary {
  final double average;

  SleepSummary({
    required this.average,
  });

  factory SleepSummary.fromJson(Map<String, dynamic> json) {
    return SleepSummary(
      average: (json['average'] ?? 0).toDouble(),
    );
  }
}

class ActivitySummary {
  final double averageSteps;

  ActivitySummary({
    required this.averageSteps,
  });

  factory ActivitySummary.fromJson(Map<String, dynamic> json) {
    return ActivitySummary(
      averageSteps: (json['averageSteps'] ?? 0).toDouble(),
    );
  }
}

class HeartRateSummary {
  final double averageResting;

  HeartRateSummary({
    required this.averageResting,
  });

  factory HeartRateSummary.fromJson(Map<String, dynamic> json) {
    return HeartRateSummary(
      averageResting: (json['averageResting'] ?? 0).toDouble(),
    );
  }
}

class PatternAnalysis {
  final String symptom;
  final SummaryPeriod period;
  final int symptomDaysCount;
  final int nonSymptomDaysCount;
  final Comparisons comparisons;
  final TagsComparison tags;
  final List<Insight> insights;

  PatternAnalysis({
    required this.symptom,
    required this.period,
    required this.symptomDaysCount,
    required this.nonSymptomDaysCount,
    required this.comparisons,
    required this.tags,
    required this.insights,
  });

  factory PatternAnalysis.fromJson(Map<String, dynamic> json) {
    final analysis = json['analysis'] ?? {};
    
    return PatternAnalysis(
      symptom: analysis['symptom'] ?? '',
      period: SummaryPeriod.fromJson(analysis['period'] ?? {}),
      symptomDaysCount: analysis['symptomDaysCount'] ?? 0,
      nonSymptomDaysCount: analysis['nonSymptomDaysCount'] ?? 0,
      comparisons: Comparisons.fromJson(analysis['comparisons'] ?? {}),
      tags: TagsComparison.fromJson(analysis['tags'] ?? {}),
      insights: json['insights'] != null
          ? List<Insight>.from(json['insights'].map((x) => Insight.fromJson(x)))
          : [],
    );
  }
}

class Comparisons {
  final ComparisonItem sleep;
  final ComparisonItem activity;

  Comparisons({
    required this.sleep,
    required this.activity,
  });

  factory Comparisons.fromJson(Map<String, dynamic> json) {
    return Comparisons(
      sleep: ComparisonItem.fromJson(json['sleep'] ?? {}),
      activity: ComparisonItem.fromJson(json['activity'] ?? {}),
    );
  }
}

class ComparisonItem {
  final double symptomDaysAvg;
  final double nonSymptomDaysAvg;
  final double difference;

  ComparisonItem({
    required this.symptomDaysAvg,
    required this.nonSymptomDaysAvg,
    required this.difference,
  });

  factory ComparisonItem.fromJson(Map<String, dynamic> json) {
    return ComparisonItem(
      symptomDaysAvg: (json['symptomDaysAvg'] ?? 0).toDouble(),
      nonSymptomDaysAvg: (json['nonSymptomDaysAvg'] ?? 0).toDouble(),
      difference: (json['difference'] ?? 0).toDouble(),
    );
  }
}

class TagsComparison {
  final Map<String, int> symptomDays;
  final Map<String, int> nonSymptomDays;

  TagsComparison({
    required this.symptomDays,
    required this.nonSymptomDays,
  });

  factory TagsComparison.fromJson(Map<String, dynamic> json) {
    final symptomDaysMap = <String, int>{};
    final nonSymptomDaysMap = <String, int>{};
    
    if (json['symptomDays'] != null) {
      json['symptomDays'].forEach((key, value) {
        symptomDaysMap[key] = value;
      });
    }
    
    if (json['nonSymptomDays'] != null) {
      json['nonSymptomDays'].forEach((key, value) {
        nonSymptomDaysMap[key] = value;
      });
    }
    
    return TagsComparison(
      symptomDays: symptomDaysMap,
      nonSymptomDays: nonSymptomDaysMap,
    );
  }
}

class Insight {
  final String factor;
  final String insight;

  Insight({
    required this.factor,
    required this.insight,
  });

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      factor: json['factor'] ?? '',
      insight: json['insight'] ?? '',
    );
  }
}

class DoctorVisitSummary {
  final SummaryPeriod period;
  final List<KeySymptom> keySymptoms;
  final List<String> overallPatterns;
  final List<String> questions;

  DoctorVisitSummary({
    required this.period,
    required this.keySymptoms,
    required this.overallPatterns,
    required this.questions,
  });

  factory DoctorVisitSummary.fromJson(Map<String, dynamic> json) {
    final summaryData = json['summaryData'] ?? {};
    final doctorSummary = json['doctorSummary'] ?? {};
    
    return DoctorVisitSummary(
      period: SummaryPeriod.fromJson(summaryData['period'] ?? {}),
      keySymptoms: doctorSummary['keySymptoms'] != null
          ? List<KeySymptom>.from(
              doctorSummary['keySymptoms'].map((x) => KeySymptom.fromJson(x)))
          : [],
      overallPatterns: doctorSummary['overallPatterns'] != null
          ? List<String>.from(doctorSummary['overallPatterns'])
          : [],
      questions: doctorSummary['questions'] != null
          ? List<String>.from(doctorSummary['questions'])
          : [],
    );
  }
}

class KeySymptom {
  final String name;
  final int occurrences;
  final double avgSeverity;

  KeySymptom({
    required this.name,
    required this.occurrences,
    required this.avgSeverity,
  });

  factory KeySymptom.fromJson(Map<String, dynamic> json) {
    return KeySymptom(
      name: json['name'] ?? '',
      occurrences: json['occurrences'] ?? 0,
      avgSeverity: (json['avgSeverity'] ?? 0).toDouble(),
    );
  }
}
