import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String? photoUrl;
  final String bio;
  final int statusPoints;
  final Map<String, int> dailyPoints;
  final DateTime lastPointsReset;
  final Map<String, int> badges;
  final DateTime lastActionTimestamp;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    required this.bio,
    required this.statusPoints,
    required this.dailyPoints,
    required this.lastPointsReset,
    required this.badges,
    required this.lastActionTimestamp,
  });

  // Méthode pour convertir un Map en UserProfile
  factory UserProfile.fromMap(Map<String, dynamic> data, String id) {
    return UserProfile(
      uid: id,
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'] ?? '',
      statusPoints: data['statusPoints'] ?? 0,
      dailyPoints: Map<String, int>.from(data['dailyPoints'] ?? {}),
      lastPointsReset: (data['lastPointsReset'] as Timestamp?)?.toDate() ?? DateTime.now(),
      badges: Map<String, int>.from(data['badges'] ?? {}),
      lastActionTimestamp: (data['lastActionTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Méthode pour convertir un UserProfile en Map (compatible Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'statusPoints': statusPoints,
      'dailyPoints': dailyPoints,
      'lastPointsReset': lastPointsReset,
      'badges': badges,
      'lastActionTimestamp': lastActionTimestamp,
    };
  }

  // Méthode pour convertir un UserProfile en Map avec Timestamp (pour Firestore)
  Map<String, dynamic> toFirestoreMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'statusPoints': statusPoints,
      'dailyPoints': dailyPoints,
      'lastPointsReset': Timestamp.fromDate(lastPointsReset),
      'badges': badges,
      'lastActionTimestamp': Timestamp.fromDate(lastActionTimestamp),
    };
  }

  // Méthode pour créer une copie avec des propriétés mises à jour
  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? photoUrl,
    String? bio,
    int? statusPoints,
    Map<String, int>? dailyPoints,
    DateTime? lastPointsReset,
    Map<String, int>? badges,
    DateTime? lastActionTimestamp,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      statusPoints: statusPoints ?? this.statusPoints,
      dailyPoints: dailyPoints ?? this.dailyPoints,
      lastPointsReset: lastPointsReset ?? this.lastPointsReset,
      badges: badges ?? this.badges,
      lastActionTimestamp: lastActionTimestamp ?? this.lastActionTimestamp,
    );
  }

  // Méthodes pour mettre à jour les propriétés (retournent une nouvelle instance)
  UserProfile updateStatusPoints(int points) {
    return copyWith(statusPoints: points);
  }

  UserProfile updateLastPointsReset(DateTime date) {
    return copyWith(lastPointsReset: date);
  }

  UserProfile addDailyPoints(String dateKey, int points) {
    final updatedDailyPoints = Map<String, int>.from(dailyPoints)..[dateKey] = points;
    return copyWith(dailyPoints: updatedDailyPoints);
  }

  UserProfile updateLastActionTimestamp(DateTime date) {
    return copyWith(lastActionTimestamp: date);
  }

  UserProfile updateBadge(String badgeType, int count) {
    final updatedBadges = Map<String, int>.from(badges)..[badgeType] = count;
    return copyWith(badges: updatedBadges);
  }

  // Méthode pour ajouter des points à une date donnée (incrémentation)
  UserProfile incrementDailyPoints(String dateKey, int pointsToAdd) {
    final updatedDailyPoints = Map<String, int>.from(dailyPoints);
    updatedDailyPoints[dateKey] = (updatedDailyPoints[dateKey] ?? 0) + pointsToAdd;
    return copyWith(dailyPoints: updatedDailyPoints);
  }

  // Méthode pour incrémenter un badge
  UserProfile incrementBadge(String badgeType) {
    final updatedBadges = Map<String, int>.from(badges);
    updatedBadges[badgeType] = (updatedBadges[badgeType] ?? 0) + 1;
    return copyWith(badges: updatedBadges);
  }
}
