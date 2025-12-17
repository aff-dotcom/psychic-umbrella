import 'package:flutter/material.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Définition des couleurs personnalisées
    const Color backgroundColor = Color(0xFFecbdae); // Beige clair
    const Color progressColor = Color(0xFF423531);   // Marron foncé

    // Liste des récompenses (centralisée pour éviter la duplication)
    const List<RewardItem> rewards = [
      RewardItem(
        icon: Icons.emoji_events,
        title: "Niveau Or",
        progress: 0.7,
        points: "150/200 pts",
        color: Colors.amber, // Couleur or pour "Niveau Or"
      ),
      RewardItem(
        icon: Icons.checkroom,
        title: "Collectionneur",
        progress: 0.4,
        points: "80/200 pts",
        color: Colors.blue, // Couleur bleue pour "Collectionneur"
      ),
      RewardItem(
        icon: Icons.star,
        title: "Explorateur",
        progress: 0.9,
        points: "180/200 pts",
        color: Colors.purple, // Couleur violette pour "Explorateur"
      ),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Récompenses',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: progressColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Titre de la section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Vos progrès vers les récompenses :",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF423531),
              ),
            ),
          ),
          // Liste des récompenses
          Expanded(
            child: ListView(
              children: rewards,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pour un élément de récompense
class RewardItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final double progress;
  final String points;
  final Color color;

  const RewardItem({
    super.key,
    required this.icon,
    required this.title,
    required this.progress,
    required this.points,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Zone de progression (gauche)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF423531),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Barre de progression
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  // Points
                  Text(
                    points,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF97796f),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Icône de récompense (droite)
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          // Bouton de déverrouillage (flèche)
          GestureDetector(
            onTap: () {
              if (progress == 1.0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title débloquée !')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Continuez à progresser pour débloquer $title !')),
                );
              }
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: progress == 1.0 ? Colors.green : Colors.grey,
              ),
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
