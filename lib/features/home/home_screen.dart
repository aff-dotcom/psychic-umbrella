import 'package:flutter/material.dart';
import 'package:fripesfinderv2/utils/colors.dart';
import 'package:fripesfinderv2/widgets/custom_bottom_nav_bar.dart';
import 'package:fripesfinderv2/features/auth/auth_guard.dart';
import 'package:fripesfinderv2/features/map/map_screen.dart';
import 'package:fripesfinderv2/features/outfit/outfit_screen.dart';
import 'package:fripesfinderv2/features/profile/profile_screen.dart';
import 'package:fripesfinderv2/features/notification_screen.dart';
import 'package:fripesfinderv2/features/rewards/rewards_screen.dart'; // Ajoute cette ligne
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeContent(),       // Écran de contenu principal (index 0)
    const MapScreen(),         // Écran des fripes (carte) (index 1)
    const OutfitScreen(),      // Écran des outfits (index 2)
    NotificationsScreen(),     // Écran des notifications (index 3)
    const ProfileScreen(),     // Écran du profil (index 4)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/logo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implémenter la logique de recherche
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Widget interne pour le contenu de l'écran d'accueil
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section "News Fashion/Pop-up Store"
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'News Fashion / Pop-up Store',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                Card(
                  child: SizedBox(
                    width: 200,
                    child: Center(child: Text('Pop-up Store 1')),
                  ),
                ),
                Card(
                  child: SizedBox(
                    width: 200,
                    child: Center(child: Text('Pop-up Store 2')),
                  ),
                ),
              ],
            ),
          ),
          // Citation du jour
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Citation du jour : "La mode est une forme d\'expression personnelle."',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          // Barre de progression
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progression Communautaire',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.7,
                  minHeight: 10,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                SizedBox(height: 4),
                Text(
                  '70% - 150/200 pts',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Bouton "Statut" avec icône de trophée
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RewardsScreen(), // Utilise RewardsScreen
                  ),
                );
              },
              icon: const Icon(
                Icons.emoji_events,
                color: Colors.amber,
              ),
              label: const Row(
                children: [
                  Text(
                    'Statut',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '150 pts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.grey),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
