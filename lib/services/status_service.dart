import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class StatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mettre à jour les points de statut d'un utilisateur
  Future<void> updateStatusPoints(String userId, int pointsToAdd, String action) async {
    try {
      await _firestore.collection('profiles').doc(userId).update({
        'statusPoints': FieldValue.increment(pointsToAdd),
        'lastAction': action,
        'lastActionAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour des points : $e');
      }
      throw Exception('Erreur lors de la mise à jour des points');
    }
  }

  // Récupérer les points de statut d'un utilisateur
  Stream<int> getStatusPoints(String userId) {
    return _firestore
        .collection('profiles')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot['statusPoints'] ?? 0);
  }

  // Récupérer le statut d'un utilisateur (ex: Débutant, Confirmé, Expert)
  Stream<String> getUserStatus(String userId) {
    return _firestore
        .collection('profiles')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      int points = snapshot['statusPoints'] ?? 0;
      if (points < 50) return 'Débutant';
      if (points < 200) return 'Confirmé';
      return 'Expert';
    });
  }
}
