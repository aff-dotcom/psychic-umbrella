import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:fripesfinderv2/models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Récupère le profil utilisateur en temps réel (Stream).
  /// Si le profil n'existe pas, il est créé avec des valeurs par défaut.
  Stream<UserProfile> getUserProfile(String userId) {
    return _firestore
        .collection('profiles')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        // Création d'un profil par défaut si inexistant
        final newProfile = UserProfile(
          uid: userId,
          displayName: '',
          photoUrl: null,
          bio: '',
          statusPoints: 0,
          dailyPoints: {}, // Map<String, int> vide
          lastPointsReset: DateTime.now(),
          badges: {},
          lastActionTimestamp: DateTime.now(),
        );
        // Sauvegarde le profil par défaut dans Firestore
        _firestore.collection('profiles').doc(userId).set(newProfile.toMap(), SetOptions(merge: true));
        return newProfile;
      }
      return UserProfile.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  /// Récupère le profil utilisateur une seule fois.
  /// Utile pour les services comme RewardService.
  Future<UserProfile> getUserProfileOnce(String userId) async {
    final doc = await _firestore.collection('profiles').doc(userId).get();
    if (!doc.exists || doc.data() == null) {
      final newProfile = UserProfile(
        uid: userId,
        displayName: '',
        photoUrl: null,
        bio: '',
        statusPoints: 0,
        dailyPoints: {}, // Map<String, int> vide
        lastPointsReset: DateTime.now(),
        badges: {},
        lastActionTimestamp: DateTime.now(),
      );
      await _firestore.collection('profiles').doc(userId).set(newProfile.toMap());
      return newProfile;
    }
    return UserProfile.fromMap(doc.data()!, doc.id);
  }

  /// Met à jour les informations de base du profil.
  Future<void> updateProfile({
    required String userId,
    required String displayName,
    String? photoUrl,
    required String bio,
  }) async {
    await _firestore.collection('profiles').doc(userId).set({
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
    }, SetOptions(merge: true));
  }

  /// Met à jour la photo de profil.
  Future<String?> uploadProfilePhoto(String userId, XFile image) async {
    try {
      String fileName = 'profile_$userId${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('profile_photos/$fileName');
      UploadTask uploadTask = ref.putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await _firestore.collection('profiles').doc(userId).update({
        'photoUrl': downloadUrl,
      });
      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors du téléchargement de la photo : $e');
    }
  }

  /// Met à jour les données liées aux récompenses (points, badges, etc.).
  Future<void> updateRewardData(UserProfile profile) async {
    await _firestore.collection('profiles').doc(profile.uid).update({
      'statusPoints': profile.statusPoints,
      'dailyPoints': profile.dailyPoints,
      'lastPointsReset': profile.lastPointsReset,
      'badges': profile.badges,
      'lastActionTimestamp': profile.lastActionTimestamp,
    });
  }
}

// Exemple d'utilisation avec StreamBuilder
class ProfileWidget extends StatelessWidget {
  final ProfileService profileService;
  final String userId;

  const ProfileWidget({super.key, required this.profileService, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile>(
      stream: profileService.getUserProfile(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Profil introuvable'));
        }

        final userProfile = snapshot.data!;

        // Vérification de l'UID (redondant ici car UserProfile a toujours un uid valide)
        if (userProfile.uid.isEmpty) {
          return const Center(child: Text('Profil invalide'));
        }

        // Utilisation directe des propriétés de UserProfile
        final statusPoints = userProfile.statusPoints;

        // Le reste de votre code...
        return Column(
          children: [
            Text('Points de statut: $statusPoints'),
            // Autres widgets utilisant userProfile
          ],
        );
      },
    );
  }
}
