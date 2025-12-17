import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fripesfinderv2/models/outfit.dart';

class OutfitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Ajouter une tenue
  Future<void> addOutfit({
    required String userId,
    required String title,
    required String description,
    required List<XFile> images,
    required List<String> tags,
  }) async {
    try {
      // 1. Télécharger les images
      List<String> imageUrls = await _uploadImages(images);

      // 2. Ajouter la tenue à Firestore
      await _firestore.collection('outfits').add({
        'userId': userId,
        'title': title,
        'description': description,
        'imageUrls': imageUrls,
        'tags': tags,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
        'comments': [],
      });
    } catch (e) {
      print('Erreur lors de l\'ajout de la tenue : $e');
      throw Exception('Erreur lors de l\'ajout de la tenue');
    }
  }

  // Télécharger les images et retourner leurs URLs
  Future<List<String>> _uploadImages(List<XFile> images) async {
    List<String> imageUrls = [];
    for (XFile image in images) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('outfit_images/$fileName');
      UploadTask uploadTask = ref.putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  // Récupérer toutes les tenues, triées par date de création
  Stream<List<Outfit>> getOutfits() {
    return _firestore
        .collection('outfits')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Outfit.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Ajouter un like à une tenue
  Future<void> likeOutfit({
    required String outfitId,
    required String userId,
    required String currentUserDisplayName,
    required String outfitUserId, // ID de l'utilisateur qui a publié la tenue
  }) async {
    try {
      // Mettre à jour les likes dans Firestore
      await _firestore.collection('outfits').doc(outfitId).update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });

      // Envoyer une notification à l'utilisateur qui a publié la tenue
      await NotificationService().addNotification(
        outfitUserId,
        'Nouveau like',
        '$currentUserDisplayName a aimé votre tenue',
        'like',
        outfitId,
      );
    } catch (e) {
      print('Erreur lors de l\'ajout d\'un like : $e');
      throw Exception('Erreur lors de l\'ajout d\'un like');
    }
  }

  // Retirer un like d'une tenue
  Future<void> unlikeOutfit(String outfitId, String userId) async {
    try {
      await _firestore.collection('outfits').doc(outfitId).update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      print('Erreur lors du retrait d\'un like : $e');
      throw Exception('Erreur lors du retrait d\'un like');
    }
  }

  // Ajouter un commentaire à une tenue
  Future<void> addComment({
    required String outfitId,
    required String userId,
    required String currentUserDisplayName,
    required String commentText,
    required String outfitUserId, // ID de l'utilisateur qui a publié la tenue
  }) async {
    try {
      // Ajouter le commentaire dans Firestore
      await _firestore.collection('outfits').doc(outfitId).update({
        'comments': FieldValue.arrayUnion([
          {
            'userId': userId,
            'text': commentText,
            'createdAt': FieldValue.serverTimestamp(),
          }
        ]),
      });

      // Envoyer une notification à l'utilisateur qui a publié la tenue
      await NotificationService().addNotification(
        outfitUserId,
        'Nouveau commentaire',
        '$currentUserDisplayName a commenté votre tenue',
        'comment',
        outfitId,
      );
    } catch (e) {
      print('Erreur lors de l\'ajout d\'un commentaire : $e');
      throw Exception('Erreur lors de l\'ajout d\'un commentaire');
    }
  }
}
