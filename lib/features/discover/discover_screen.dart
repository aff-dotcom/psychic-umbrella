import 'package:flutter/material.dart';
import 'package:fripesfinderv2/utils/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ajoutez cette ligne
import 'package:fripesfinderv2/services/home_service.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(48.8566, 2.3522); // Paris

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Date non spécifiée';
    final date = timestamp.toDate();
    return 'Le ${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Découvrir'),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController, // Assurez-vous que le TabBar utilise le même TabController
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Événements'),
            Tab(text: 'Pop-up Stores'),
          ],
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: HomeService().getNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune donnée disponible'));
          }
          final newsList = snapshot.data!;
          final events = newsList.where((news) => news['type'] == 'event').toList();
          final popUps = newsList.where((news) => news['type'] == 'pop-up').toList();
          return TabBarView(
            controller: _tabController,
            children: [
              _buildEventsTab(events),
              _buildPopUpStoresTab(popUps),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventsTab(List<Map<String, dynamic>> events) {
    if (events.isEmpty) {
      return const Center(child: Text('Aucun événement disponible'));
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  event['imageUrl'] ?? '', // Valeur par défaut si imageUrl est null
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Icon(Icons.error)),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'] ?? 'Titre non disponible',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(event['location'] ?? 'Lieu non spécifié'),
                    const SizedBox(height: 8),
                    Text(_formatDate(event['date'])),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Inscription enregistrée !')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('S\'inscrire'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPopUpStoresTab(List<Map<String, dynamic>> popUps) {
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 12.0,
            ),
            markers: popUps.map((popUp) {
              return Marker(
                markerId: MarkerId(popUp['title'] ?? 'marker_${popUps.indexOf(popUp)}'),
                position: LatLng(
                  popUp['latitude'] ?? _center.latitude,
                  popUp['longitude'] ?? _center.longitude,
                ),
                infoWindow: InfoWindow(
                  title: popUp['title'] ?? 'Pop-up Store',
                  snippet: popUp['location'] ?? 'Lieu non spécifié',
                ),
              );
            }).toSet(),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Pop-up Stores à proximité',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popUps.length,
            itemBuilder: (context, index) {
              final popUp = popUps[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(left: 16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        popUp['imageUrl'] ?? '',
                        height: 100,
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            height: 100,
                            width: 200,
                            child: Center(child: Icon(Icons.error)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      popUp['title'] ?? 'Titre non disponible',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      popUp['location'] ?? 'Lieu non spécifié',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
