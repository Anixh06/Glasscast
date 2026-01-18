import 'package:uuid/uuid.dart';

class City {
  final String id;
  final String name;
  final String country;
  final double? latitude;
  final double? longitude;
  final DateTime addedAt;

  City({
    String? id,
    required this.name,
    this.country = '',
    this.latitude,
    this.longitude,
    DateTime? addedAt,
  })  : id = id ?? const Uuid().v4(),
        addedAt = addedAt ?? DateTime.now();

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? const Uuid().v4(),
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      addedAt: json['added_at'] != null 
          ? DateTime.parse(json['added_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson({required String userId}) {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'added_at': addedAt.toIso8601String(),
    };
  }

  City copyWith({
    String? id,
    String? name,
    String? country,
    double? latitude,
    double? longitude,
    DateTime? addedAt,
  }) {
    return City(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

