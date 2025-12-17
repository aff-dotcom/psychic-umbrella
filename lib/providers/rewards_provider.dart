import 'package:flutter/material.dart';
import 'package:fripesfinderv2/models/reward.dart';

class RewardsProvider with ChangeNotifier {
  final List<Reward> _rewards = [
    Reward(
      title: "Niveau Or",
      progress: 0.7,
      points: "150/200 pts",
      icon: Icons.emoji_events,
      color: Colors.amber,
    ),
    Reward(
      title: "Collectionneur",
      progress: 0.4,
      points: "80/200 pts",
      icon: Icons.checkroom,
      color: Colors.blue,
    ),
    Reward(
      title: "Explorateur",
      progress: 0.9,
      points: "180/200 pts",
      icon: Icons.star,
      color: Colors.purple,
    ),
  ];

  List<Reward> get rewards => _rewards;

  void updateProgress(int index, double newProgress) {
    _rewards[index].progress = newProgress;
    notifyListeners();
  }
}
