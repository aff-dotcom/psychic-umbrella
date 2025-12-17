import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fripesfinderv2/models/outfit.dart';
import 'package:fripesfinderv2/services/status_service.dart';
import 'package:logger/logger.dart';

class OutfitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final StatusService _statusService = StatusService();
  final Logger _logger = Logger();

  /// Ajoute une tenue avec ses images et met à jour les points de l'utilisateur.
  Future<void> addOutfit({
    required String userId,
    required String title,
    required String description,
    required String location,
    required List<XFile> images,
    required List<String> tags,
  }) async {
    try {
      // 1. Télécharger les images et obtenir leurs URLs
      final List<String> imageUrls = await _uploadImages(images, userId);

      // 2. Ajouter la tenue à Firestore avec les URLs des images
      final DocumentReference docRef = await _firestore.collection('outfits').add({
        'userId': userId,
        'title': title,
        'description': description,
        'location': location,
        'imageUrls': imageUrls,
        'tags': tags,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
        'comments': [],
      });

      // 3. Mettre à jour les points de l'utilisateur (20 points pour une tenue)
      await _statusService.updateStatusPoints(userId, 20, 'Publication d\'une tenue');

      _logger.i('Tenue ajoutée avec l\'ID : ${docRef.id}');
    } catch (e) {
      _logger.e('Erreur lors de l\'ajout de la tenue', error: e);
      rethrow;
    }
  }

  /// Télécharge les images sur Firebase Storage et retourne leurs URLs.
  Future<List<String>> _uploadImages(List<XFile> images, String userId) async {
    final List<String> imageUrls = [];
    for (final XFile image in images) {
      try {
        final String fileName = 'outfit_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final Reference ref = _storage.ref().child('outfit_images/$fileName');
        final UploadTask uploadTask = ref.putFile(File(image.path));
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      } catch (e) {
        _logger.e('Erreur lors du téléchargement de l\'image ${image.path}', error: e);
        rethrow;
      }
    }
    return imageUrls;
  }

  /// Ajoute un like à une tenue.
  Future<void> likeOutfit(String outfitId, String userId) async {
    try {
      await _firestore.collection('outfits').doc(outfitId).update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
      // Optionnel : Ajouter des points pour un like (exemple : 1 point)
      await _statusService.updateStatusPoints(userId, 1, 'Like sur une tenue');
    } catch (e) {
      _logger.e('Erreur lors de l\'ajout d\'un like', error: e);
      rethrow;
    }
  }

  /// Retire un like d'une tenue.
  Future<void> unlikeOutfit(String outfitId, String userId) async {
    try {
      await _firestore.collection('outfits').doc(outfitId).update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      _logger.e('Erreur lors du retrait d\'un like', error: e);
      rethrow;
    }
  }

  /// Ajoute un commentaire à une tenue.
  Future<void> addComment(String outfitId, String userId, String commentText) async {
    try {
      await _firestore.collection('outfits').doc(outfitId).update({
        'comments': FieldValue.arrayUnion([
          {
            'userId': userId,
            'text': commentText,
            'createdAt': FieldValue.serverTimestamp(),
          }
        ]),
      });
      // Optionnel : Ajouter des points pour un commentaire (exemple : 2 points)
      await _statusService.updateStatusPoints(userId, 2, 'Commentaire sur une tenue');
    } catch (e) {
      _logger.e('Erreur lors de l\'ajout d\'un commentaire', error: e);
      rethrow;
    }
  }

  /// Récupère toutes les tenues, triées par date de création (plus récentes en premier).
  Stream<List<Outfit>> getOutfits() {
    return _firestore
        .collection('outfits')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Outfit.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Récupère les tenues d'un utilisateur spécifique.
  Stream<List<Outfit>> getOutfitsByUserId(String userId) {
    return _firestore
        .collection('outfits')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Outfit.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Supprime une tenue et ses images associées.
  Future<void> deleteOutfit(String outfitId) async {
    try {
      // 1. Récupérer les URLs des images pour les supprimer de Storage
      final DocumentSnapshot doc = await _firestore.collection('outfits').doc(outfitId).get();
      final List<String> imageUrls = List<String>.from(doc['imageUrls'] ?? []);

      // 2. Supprimer les images de Storage
      await Future.wait(
        imageUrls.map((url) => _storage.refFromURL(url).delete()),
      );

      // 3. Supprimer la tenue de Firestore
      await _firestore.collection('outfits').doc(outfitId).delete();

      _logger.i('Tenue supprimée avec succès (ID: $outfitId)');
    } catch (e) {
      _logger.e('Erreur lors de la suppression de la tenue', error: e);
      rethrow;
    }
  }
}
