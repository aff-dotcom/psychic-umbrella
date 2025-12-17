import 'package:cloud_firestore/cloud_firestore.dart';

class Outfit {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<String> imageUrls;
  final List<String> tags;
  final DateTime createdAt;
  final int likes;
  final List<String> likedBy;
  final List<Comment> comments;

  Outfit({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.tags,
    required this.createdAt,
    required this.likes,
    required this.likedBy,
    required this.comments,
  });

  // Convertir un Outfit en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'tags': tags,
      'createdAt': createdAt,
      'likes': likes,
      'likedBy': likedBy,
      'comments': comments.map((comment) => comment.toMap()).toList(),
    };
  }

  // Créer un Outfit depuis un DocumentSnapshot
  factory Outfit.fromMap(Map<String, dynamic> map, String id) {
    return Outfit(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      comments: (map['comments'] as List<dynamic>?)
              ?.map((comment) => Comment.fromMap(comment))
              .toList() ??
          [],
    );
  }
}

class Comment {
  final String userId;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'text': text,
      'createdAt': createdAt,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userId: map['userId'] ?? '',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
