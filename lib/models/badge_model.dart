enum BadgeType {
  addPlace,       // Ajouter un lieu
  updatePhotos,   // Mettre à jour les photos d'un lieu
  comment,        // Commenter un lieu ou un outfit
  postOutfit,     // Poster un outfit
}

class Badge {
  final BadgeType type;
  final String name;
  final List<int> thresholds; // Seuil pour chaque niveau (ex: [1, 5, 10, 20])

  Badge({required this.type, required this.name, required this.thresholds});
}

final badges = [
  Badge(
    type: BadgeType.addPlace,
    name: 'Explorateur',
    thresholds: [1, 5, 10, 20],
  ),
  Badge(
    type: BadgeType.updatePhotos,
    name: 'Photographe',
    thresholds: [1, 5, 10, 20],
  ),
  Badge(
    type: BadgeType.comment,
    name: 'Critique',
    thresholds: [1, 5, 10, 20],
  ),
  Badge(
    type: BadgeType.postOutfit,
    name: 'Styliste',
    thresholds: [1, 5, 10, 20],
  ),
];
