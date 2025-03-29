class JournalEntry {
  final String? id;
  final String userId;
  final DateTime date;
  final int mood;
  final int energy;
  final List<Symptom> symptoms;
  final String notes;
  final List<String> tags;
  final Location? location;
  final DateTime createdAt;

  JournalEntry({
    this.id,
    required this.userId,
    required this.date,
    required this.mood,
    required this.energy,
    required this.symptoms,
    required this.notes,
    required this.tags,
    this.location,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['_id'],
      userId: json['user'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      mood: json['mood'] ?? 3,
      energy: json['energy'] ?? 3,
      symptoms: json['symptoms'] != null
          ? List<Symptom>.from(
              json['symptoms'].map((x) => Symptom.fromJson(x)))
          : [],
      notes: json['notes'] ?? '',
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : [],
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'user': userId,
      'date': date.toIso8601String(),
      'mood': mood,
      'energy': energy,
      'symptoms': symptoms.map((x) => x.toJson()).toList(),
      'notes': notes,
      'tags': tags,
      if (location != null) 'location': location!.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  JournalEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? mood,
    int? energy,
    List<Symptom>? symptoms,
    String? notes,
    List<String>? tags,
    Location? location,
    DateTime? createdAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Symptom {
  final String name;
  final int severity;

  Symptom({
    required this.name,
    required this.severity,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      name: json['name'] ?? '',
      severity: json['severity'] ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'severity': severity,
    };
  }
}

class Location {
  final String type;
  final List<double> coordinates;
  final String? description;

  Location({
    required this.type,
    required this.coordinates,
    this.description,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? 'Point',
      coordinates: json['coordinates'] != null
          ? List<double>.from(json['coordinates'])
          : [0, 0],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
      if (description != null) 'description': description,
    };
  }
}
