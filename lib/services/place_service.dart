import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fripesfinderv2/models/place.dart';
import 'package:logger/logger.dart';

class PlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  /// Récupère tous les lieux en temps réel via un Stream.
  Stream<List<Place>> getPlacesStream() {
    return _firestore
        .collection('places')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Place.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Récupère tous les lieux en une seule requête (Future).
  Future<List<Place>> getPlaces() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('places').get();
      return snapshot.docs
          .map((doc) => Place.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      _logger.e("Erreur lors de la récupération des lieux : $e");
      return [];
    }
  }

  /// Récupère un lieu par son ID.
  Future<Place?> getPlaceById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('places').doc(id).get();
      if (doc.exists) {
        return Place.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      _logger.e("Erreur lors de la récupération du lieu : $e");
      return null;
    }
  }

  /// Ajoute un nouveau lieu dans Firestore et met à jour les points de l'utilisateur.
  Future<void> addPlace({required Place place, required String userId}) async {
    try {
      // Ajoute le lieu dans Firestore
      await _firestore.collection('places').doc(place.id).set(place.toMap());

      // Met à jour les points de l'utilisateur dans la collection 'profiles'
      await _firestore.collection('profiles').doc(userId).set({
        'statusPoints': FieldValue.increment(5),
        'lastActionTimestamp': FieldValue.serverTimestamp(), // Optionnel : pour tracker la dernière action
      }, SetOptions(merge: true));

      _logger.i("Lieu ajouté avec succès (ID: ${place.id})");
    } catch (e) {
      _logger.e("Erreur lors de l'ajout du lieu : $e");
      rethrow;
    }
  }

  /// Met à jour un lieu existant dans Firestore.
  Future<void> updatePlace(Place place) async {
    try {
      await _firestore.collection('places').doc(place.id).update(place.toMap());
      _logger.i("Lieu mis à jour avec succès (ID: ${place.id})");
    } catch (e) {
      _logger.e("Erreur lors de la mise à jour du lieu : $e");
      rethrow;
    }
  }

  /// Supprime un lieu de Firestore.
  Future<void> deletePlace(String id) async {
    try {
      await _firestore.collection('places').doc(id).delete();
      _logger.i("Lieu supprimé avec succès (ID: $id)");
    } catch (e) {
      _logger.e("Erreur lors de la suppression du lieu : $e");
      rethrow;
    }
  }

  /// Récupère la position géographique actuelle de l'utilisateur.
  Future<Position> getCurrentPosition() async {
    // Vérifie si les services de localisation sont activés
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Les services de localisation sont désactivés.');
    }

    // Vérifie et demande la permission de localisation si nécessaire
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission de localisation refusée.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permission de localisation définitivement refusée.');
    }

    // Récupère la position actuelle avec une haute précision
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
