class StatusLevel {
  final String name;
  final int minPoints;
  final List<String> rewards;

  StatusLevel({
    required this.name,
    required this.minPoints,
    required this.rewards,
  });
}

final statusLevels = [
  StatusLevel(
    name: 'Débutant',
    minPoints: 0,
    rewards: ['Accès aux événements locaux'],
  ),
  StatusLevel(
    name: 'Confirmé',
    minPoints: 200,
    rewards: ['Accès aux événements locaux', 'Réductions chez nos partenaires'],
  ),
  StatusLevel(
    name: 'Expert',
    minPoints: 500,
    rewards: ['Accès VIP aux pop-up stores'],
  ),
  StatusLevel(
    name: 'Légende',
    minPoints: 800,
    rewards: ['Invitations exclusives'],
  ),
];
