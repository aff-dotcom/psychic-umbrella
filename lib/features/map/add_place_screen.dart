import 'package:flutter/material.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _type;
  late double _latitude;
  late double _longitude;
  late String _address;
  late String _description;
  late List<String> _tags;
  late String _vibe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un lieu'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nom du lieu'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Type de lieu'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un type';
                }
                return null;
              },
              onSaved: (value) => _type = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une latitude';
                }
                if (double.tryParse(value) == null) {
                  return 'Veuillez entrer un nombre valide';
                }
                return null;
              },
              onSaved: (value) => _latitude = double.parse(value!),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une longitude';
                }
                if (double.tryParse(value) == null) {
                  return 'Veuillez entrer un nombre valide';
                }
                return null;
              },
              onSaved: (value) => _longitude = double.parse(value!),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Adresse'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une adresse';
                }
                return null;
              },
              onSaved: (value) => _address = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une description';
                }
                return null;
              },
              onSaved: (value) => _description = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Tags (séparés par des virgules)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer au moins un tag';
                }
                return null;
              },
              onSaved: (value) => _tags = value!.split(',').map((tag) => tag.trim()).toList(),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Ambiance'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une ambiance';
                }
                return null;
              },
              onSaved: (value) => _vibe = value!,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newPlace = Place(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: "UID_DE_L_UTILISATEUR", // À remplacer par l'UID réel de l'utilisateur connecté
                    name: _name,
                    type: _type,
                    latitude: _latitude,
                    longitude: _longitude,
                    address: _address,
                    description: _description,
                    tags: _tags,
                    vibe: _vibe,
                  );
                  // Ici, vous pouvez ajouter newPlace à votre base de données ou service
                  Navigator.of(context).pop(newPlace); // Retour à l'écran précédent avec le nouveau lieu
                }
              },
              child: const Text('Ajouter le lieu'),
            ),
          ],
        ),
      ),
    );
  }
}

class Place {
  final String id;
  final String userId;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  final String description;
  final List<String>? imageUrls;
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
