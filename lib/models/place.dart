class Place {
  final String id;
  final String userId; // Identifiant du propriétaire du lieu
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  final String description;
  final List<String>? imageUrls; // Liste d'URLs d'images
  final List<String> tags;
  final String vibe;
  final DateTime? startDate;
  final DateTime? endDate;

  Place({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.description,
    this.imageUrls,
    required this.tags,
    required this.vibe,
    this.startDate,
    this.endDate,
  });

  // Convertir un document Firestore en objet Place
  factory Place.fromFirestore(Map<String, dynamic> data, String id) {
    return Place(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      address: data['address'] ?? '',
      description: data['description'] ?? '',
      imageUrls: data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : null,
      tags: List<String>.from(data['tags'] ?? []),
      vibe: data['vibe'] ?? '',
      startDate: data['startDate'] != null ? DateTime.parse(data['startDate']) : null,
      endDate: data['endDate'] != null ? DateTime.parse(data['endDate']) : null,
    );
  }

  // Convertir un objet Place en Map pour Firestore (inclut l'id)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId, // Obligatoire pour les règles !
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'description': description,
      'imageUrls': imageUrls,
      'tags': tags,
      'vibe': vibe,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  // Convertir un objet Place en Map pour Firestore (sans l'id)
  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'description': description,
      'imageUrls': imageUrls,
      'tags': tags,
      'vibe': vibe,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  // Méthode pour créer une copie avec des propriétés mises à jour
  Place copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    double? latitude,
    double? longitude,
    String? address,
    String? description,
    List<String>? imageUrls,
    List<String>? tags,
    String? vibe,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Place(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      vibe: vibe ?? this.vibe,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
