class Symptom {
  final String symptom;
  final int severity;

  Symptom({required this.symptom, required this.severity});

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      symptom: json['symptom'],
      severity: json['severity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symptom': symptom,
      'severity': severity,
    };
  }
}

class HealthEntry {
  final String id;
  final String userId;
  final int mood;
  final int energyLevel;
  final List<Symptom> symptoms;
  final String notes;
  final List<String> tags;
  final DateTime timestamp;
  final DateTime createdAt;
  
  // Additional health data fields
  final int? steps;
  final double? activeEnergy;
  final double? heartRate;
  final int? sleepMinutes;
  final Map<String, dynamic>? additionalHealthData;

  HealthEntry({
    required this.id,
    required this.userId,
    required this.mood,
    required this.energyLevel,
    required this.symptoms,
    required this.notes,
    required this.tags,
    required this.timestamp,
    required this.createdAt,
    this.steps,
    this.activeEnergy,
    this.heartRate,
    this.sleepMinutes,
    this.additionalHealthData,
  });

  // Create from JSON
  factory HealthEntry.fromJson(Map<String, dynamic> json) {
    List<Symptom> symptomsList = [];
    if (json['symptoms'] != null) {
      if (json['symptoms'] is List) {
        symptomsList = (json['symptoms'] as List)
            .map((symptomJson) => Symptom.fromJson(symptomJson))
            .toList();
      }
    }

    List<String> tagsList = [];
    if (json['tags'] != null) {
      if (json['tags'] is List) {
        tagsList = List<String>.from(json['tags']);
      } else if (json['tags'] is String) {
        // Handle comma-separated string
        tagsList = (json['tags'] as String)
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();
      }
    }

    return HealthEntry(
      id: json['_id'] ?? json['id'],
      userId: json['userId'],
      mood: json['mood'],
      energyLevel: json['energyLevel'],
      symptoms: symptomsList,
      notes: json['notes'] ?? '',
      tags: tagsList,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      steps: json['steps'],
      activeEnergy: json['activeEnergy'],
      heartRate: json['heartRate'],
      sleepMinutes: json['sleepMinutes'],
      additionalHealthData: json['additionalHealthData'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'mood': mood,
      'energyLevel': energyLevel,
      'symptoms': symptoms.map((symptom) => symptom.toJson()).toList(),
      'notes': notes,
      'tags': tags,
      'timestamp': timestamp.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'steps': steps,
      'activeEnergy': activeEnergy,
      'heartRate': heartRate,
      'sleepMinutes': sleepMinutes,
      'additionalHealthData': additionalHealthData,
    };
  }
}
