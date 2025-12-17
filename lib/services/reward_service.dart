import 'package:fripesfinderv2/models/status_level.dart';
import 'package:fripesfinderv2/services/profile_service.dart';
import '../models/user_profile.dart';
import '../models/badge_model.dart';

class RewardService {
  final ProfileService _profileService;

  // Exemple de niveaux de statut (à adapter selon ta logique métier)
  final List<StatusLevel> statusLevels = [
    StatusLevel(name: 'Débutant', minPoints: 0, rewards: []),
    StatusLevel(name: 'Amateur', minPoints: 50, rewards: []),
    StatusLevel(name: 'Confirmé', minPoints: 200, rewards: []),
    StatusLevel(name: 'Expert', minPoints: 500, rewards: []),
    StatusLevel(name: 'Maître', minPoints: 800, rewards: []),
  ];

  RewardService(this._profileService);

  /// Ajoute des points à un utilisateur pour une action donnée.
  /// Retourne `true` si les points ont été ajoutés, `false` si la limite quotidienne est atteinte.
  Future<bool> addPoints(String uid, int points, BadgeType type) async {
    final userProfile = await _profileService.getUserProfileOnce(uid);
    final today = DateTime.now();
    final todayKey = _formatDate(today);

    // Vérifie la limite quotidienne (20 points max)
    final todayPoints = userProfile.dailyPoints[todayKey] ?? 0;
    if (todayPoints + points > 20) {
      return false;
    }

    // Vérifie la réinitialisation trimestrielle (tous les 90 jours)
    UserProfile updatedProfile = userProfile;
    if (today.difference(userProfile.lastPointsReset).inDays >= 90) {
      updatedProfile = updatedProfile
          .updateStatusPoints(0)
          .updateLastPointsReset(today)
          .copyWith(dailyPoints: {});
    }

    // Met à jour les points
    updatedProfile = updatedProfile
        .updateStatusPoints(userProfile.statusPoints + points)
        .addDailyPoints(todayKey, todayPoints + points)
        .updateLastActionTimestamp(today);

    // Met à jour les badges
    updatedProfile = _updateBadges(updatedProfile, type);

    // Sauvegarde les modifications
    await _profileService.updateRewardData(updatedProfile);
    return true;
  }

  /// Met à jour les badges de l'utilisateur en fonction de l'action effectuée.
  UserProfile _updateBadges(UserProfile userProfile, BadgeType type) {
    final currentCount = userProfile.badges[type.name] ?? 0;
    return userProfile.updateBadge(type.name, currentCount + 1);
  }

  /// Formate une date en chaîne "YYYY-MM-DD" pour les clés du dictionnaire dailyPoints.
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Retourne le statut actuel de l'utilisateur en fonction de ses points.
  StatusLevel getCurrentStatusLevel(int points) {
    return statusLevels.lastWhere(
      (level) => points >= level.minPoints,
      orElse: () => statusLevels.first,
    );
  }

  /// Retourne le prochain statut à atteindre et les points manquants.
  Map<String, dynamic> getNextStatusInfo(int points) {
    final currentLevel = getCurrentStatusLevel(points);
    final nextLevel = statusLevels.firstWhere(
      (level) => points < level.minPoints,
      orElse: () => currentLevel,
    );
    if (nextLevel == currentLevel) {
      return {'reachedMax': true, 'message': 'Vous avez atteint le niveau maximal !'};
    }
    return {
      'nextLevel': nextLevel,
      'pointsNeeded': nextLevel.minPoints - points,
      'message': 'Il vous manque ${nextLevel.minPoints - points} points pour atteindre le niveau ${nextLevel.name}.',
    };
  }
}
