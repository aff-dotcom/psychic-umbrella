import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fripesfinderv2/features/outfit/outfit_detail_screen.dart';
import 'package:fripesfinderv2/models/notification.dart' as model;

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key}); // Retiré `const` car FirebaseFirestore.instance n'est pas const

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // Retiré `const` car AppBar n'est pas const par défaut
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('notifications').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement des notifications'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucune notification disponible'));
          }

          final notifications = snapshot.data!.docs
              .map((doc) => model.Notification.fromFirestore(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ))
              .toList();

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(
                  notification.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(notification.body),
                onTap: () {
                  if (notification.type == 'outfit') {
                    // Utilisation de addPostFrameCallback pour éviter les erreurs de navigation
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OutfitDetailScreen(
                            id: notification.referenceId,
                            outfit: null, // OK si OutfitDetailScreen accepte un Outfit nullable
                          ),
                        ),
                      );
                    });
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
