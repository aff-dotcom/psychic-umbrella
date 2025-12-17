import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fripesfinderv2/services/profile_service.dart';
import 'package:fripesfinderv2/models/user_profile.dart';
import 'package:fripesfinderv2/features/profile/edit_profile_screen.dart';
import 'package:fripesfinderv2/features/outfit/outfit_detail_screen.dart';
import 'package:fripesfinderv2/models/outfit.dart';
import 'package:fripesfinderv2/services/outfit_service.dart';
import 'package:fripesfinderv2/providers/auth_provider.dart' as auth_provider;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final user = Provider.of<auth_provider.AuthProvider>(context, listen: false).user!;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(userId: user.uid),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<auth_provider.AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user!;
          final profileService = ProfileService();
          return StreamBuilder<UserProfile>(
            stream: profileService.getUserProfile(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('Profil introuvable'));
              }
              final profile = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profile.photoUrl != null
                          ? NetworkImage(profile.photoUrl!)
                          : null,
                      child: profile.photoUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      profile.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),


                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        profile.bio,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Statut : ${profile.statusPoints} points'),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Mes tenues',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<List<Outfit>>(
                      stream: OutfitService()
                          .getOutfits()
                          .map((outfits) => outfits
                              .where((outfit) => outfit.userId == user.uid)
                              .toList()),
                      builder: (context, outfitSnapshot) {
                        if (outfitSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!outfitSnapshot.hasData || outfitSnapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Center(child: Text('Aucune tenue publiée.')),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 1,
                            ),
                            itemCount: outfitSnapshot.data!.length,
                            itemBuilder: (context, index) {
                              final outfit = outfitSnapshot.data![index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => OutfitDetailScreen(
                                        id: outfit.id,
                                        outfit: outfit,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 150,
                                    child: Image.network(
                                      outfit.imageUrls.first,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

