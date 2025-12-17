class Notification {
  final String id;
  final String title;
  final String body;
  final String type;
  final String referenceId;
  final bool isRead;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.referenceId,
    required this.isRead,
  });

  // Méthode pour convertir un document Firestore en un objet Notification
  factory Notification.fromFirestore(Map<String, dynamic> data, String id) {
    return Notification(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? '',
      referenceId: data['referenceId'] ?? '',
      isRead: data['isRead'] ?? false,
    );
  }

  // Méthode pour convertir une Map en un objet Notification
  factory Notification.fromMap(Map<String, dynamic> data, String id) {
    return Notification(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? '',
      referenceId: data['referenceId'] ?? '',
      isRead: data['isRead'] ?? false,
    );
  }
}
