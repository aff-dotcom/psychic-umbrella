import 'package:flutter/material.dart';
import 'package:fripesfinderv2/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:fripesfinderv2/providers/auth_provider.dart';
import 'package:fripesfinderv2/services/profile_service.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;
    final profileService = ProfileService();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Récompenses'),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: profileService.getUserProfile(user.uid).map((userProfile) => userProfile.toMap()),
        builder: (context, snapshot) {
          // Affichage d'un indicateur de chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Gestion des erreurs
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          // Vérification de la présence et de la validité des données
          if (!snapshot.hasData || snapshot.data!['uid'] == null) {
            return const Center(child: Text('Profil introuvable'));
          }

          final profile = snapshot.data!;
          print("Profile data: $profile"); // Log pour débogage

          final statusPoints = profile['statusPoints'] ?? 0;
          final statusLabel = _getStatusLabel(statusPoints);
          final progress = statusPoints / 200;
          final rewards = _getRewardsForStatus(statusPoints);
          final nextRewards = _getNextRewards(statusPoints);

          return Row(
            children: [
              // Barre latérale avec les icônes de récompenses
              Container(
                width: 70,
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRewardIcon(Icons.emoji_events, statusPoints >= 50, 'Niveau Or'),
                    const SizedBox(height: 20),
                    _buildRewardIcon(Icons.checkroom, statusPoints >= 100, 'Collectionneur'),
                    const SizedBox(height: 20),
                    _buildRewardIcon(Icons.star, statusPoints >= 200, 'Explorateur'),
                    const Spacer(),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(Icons.arrow_upward, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // Section principale avec les informations de statut et de progression
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Vos Récompenses',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 20),
                        // Carte de statut actuel
                        _buildStatusCard(
                          context: context,
                          statusLabel: statusLabel,
                          progress: progress,
                          points: statusPoints,
                          rewards: rewards,
                        ),
                        const SizedBox(height: 20),
                        // Titre "Prochaines Récompenses"
                        Text(
                          'Prochaines Récompenses',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 10),
                        // Carte des prochaines récompenses
                        _buildNextRewardsCard(context, nextRewards, statusPoints),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRewardIcon(IconData icon, bool isUnlocked, String label) {
    return Tooltip(
      message: label,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked ? Colors.amber : Colors.grey[400],
              border: Border.all(color: Colors.black, width: 2),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 5),
          if (isUnlocked)
            const Icon(Icons.check, color: Colors.green, size: 16)
          else
            const Icon(Icons.lock, color: Colors.red, size: 16),
        ],
      ),
    );
  }

  // Widget pour la carte de statut actuel
  Widget _buildStatusCard({
    required BuildContext context,
    required String statusLabel,
    required double progress,
    required int points,
    required List<String> rewards,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut Actuel: $statusLabel',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Barre de progression avec indication du niveau
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  minHeight: 10,
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$points / 200 points'),
                    Text(
                      _getProgressPercentage(progress),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Titre "Avantages"
            const Text(
              'Avantages:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            // Liste des récompenses actuelles
            Column(
              children: rewards
                  .map(
                    (reward) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.star, color: Colors.amber),
                      title: Text(reward),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour la carte des prochaines récompenses
  Widget _buildNextRewardsCard(
    BuildContext context,
    List<String> nextRewards,
    int currentPoints,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Atteignez le niveau suivant pour débloquer:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            // Liste des prochaines récompenses
            Column(
              children: nextRewards
                  .map(
                    (reward) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.lock, color: Colors.grey),
                      title: Text(reward),
                      subtitle: _getPointsRemainingText(reward, currentPoints),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Retourne le label du statut en fonction des points
  String _getStatusLabel(int points) {
    if (points < 50) return 'Débutant';
    if (points < 100) return 'Confirmé';
    return 'Expert';
  }

  // Retourne les récompenses pour le statut actuel
  List<String> _getRewardsForStatus(int points) {
    if (points < 50) {
      return ['Accès aux événements locaux'];
    } else if (points < 100) {
      return [
        'Accès aux événements locaux',
        'Réductions chez nos partenaires',
      ];
    } else {
      return [
        'Accès aux événements locaux',
        'Réductions chez nos partenaires',
        'Accès VIP aux pop-up stores',
      ];
    }
  }

  // Retourne les prochaines récompenses à débloquer
  List<String> _getNextRewards(int points) {
    if (points < 50) {
      return ['Réductions chez nos partenaires (à 50 points)'];
    } else if (points < 100) {
      return ['Accès VIP aux pop-up stores (à 100 points)'];
    } else if (points < 200) {
      return ['Accès exclusif aux ventes privées (à 200 points)'];
    } else {
      return ['Vous avez débloqué toutes les récompenses !'];
    }
  }

  // Retourne le pourcentage de progression
  String _getProgressPercentage(double progress) {
    return '${(progress * 100).toStringAsFixed(0)}%';
  }

  // Retourne le texte indiquant les points restants
  Widget? _getPointsRemainingText(String reward, int currentPoints) {
    if (reward.contains('(à 50 points)') && currentPoints < 50) {
      return Text('Il vous manque ${50 - currentPoints} points');
    } else if (reward.contains('(à 100 points)') && currentPoints < 100) {
      return Text('Il vous manque ${100 - currentPoints} points');
    } else if (reward.contains('(à 200 points)') && currentPoints < 200) {
      return Text('Il vous manque ${200 - currentPoints} points');
    }
    return null;
  }
}
