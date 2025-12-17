import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart'; // Assure-toi que le chemin est correct

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ajouter une notification
  Future<void> addNotification(
    String userId,
    String title,
    String body,
    String type,
    String referenceId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': title,
        'body': body,
        'type': type, // 'like', 'comment', 'follow'
        'referenceId': referenceId, // ID de la tenue ou du lieu concerné
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de l\'ajout de la notification : $e');
      throw Exception('Erreur lors de l\'ajout de la notification');
    }
  }

  // Récupérer les notifications d'un utilisateur
  Stream<List<Notification>> getNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notification.fromMap(doc.data(), doc.id))
            .toList());
  }
}
