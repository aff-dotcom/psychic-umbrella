import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fripesfinderv2/services/place_service.dart';
import 'package:fripesfinderv2/models/place.dart';
import 'package:fripesfinderv2/features/map/add_place_screen.dart' hide Place;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(48.8566, 2.3522);
  final PlaceService _placeService = PlaceService();
  final Set<Marker> _markers = {};
  final Set<Marker> _allMarkers = {};
  String? _selectedType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    try {
      final customIcon = await _getCustomMarker();
      final places = await _placeService.getPlaces();
      if (!mounted) return;
      setState(() {
        _allMarkers.clear();
        for (Place place in places) {
          _allMarkers.add(
            Marker(
              markerId: MarkerId(place.id),
              position: LatLng(place.latitude, place.longitude),
              infoWindow: InfoWindow(
                title: place.name,
                snippet: place.type,
              ),
              icon: customIcon,
              onTap: () => _onMarkerTapped(MarkerId(place.id)),
            ),
          );
        }
        _filterByType(_selectedType);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des lieux: $e')),
      );
    }
  }

  Future<BitmapDescriptor> _getCustomMarker() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/custom_marker.png',
    );
  }

  void _filterByType(String? type) {
    setState(() {
      _selectedType = type;
      _markers.clear();
      if (type == null) {
        _markers.addAll(_allMarkers);
      } else {
        _markers.addAll(
          _allMarkers.where((marker) => marker.infoWindow.snippet == type),
        );
      }
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295;
    final double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _onMarkerTapped(MarkerId markerId) {
    final marker = _allMarkers.firstWhere((m) => m.markerId == markerId);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                marker.infoWindow.title ?? 'Lieu inconnu',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                marker.infoWindow.snippet ?? 'Aucune description',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des Fripes'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _filterByType,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: null,
                  child: Text('Tous'),
                ),
                const PopupMenuItem<String>(
                  value: 'Friperie',
                  child: Text('Friperie'),
                ),
                const PopupMenuItem<String>(
                  value: 'Dépôt-vente',
                  child: Text('Dépôt-vente'),
                ),
                const PopupMenuItem<String>(
                  value: 'Pop-up Store',
                  child: Text('Pop-up Store'),
                ),
                const PopupMenuItem<String>(
                  value: 'Boutique',
                  child: Text('Boutique'),
                ),
              ];
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 12.0,
              ),
              markers: _markers,
              onTap: (LatLng latLng) {
                for (Marker marker in _markers) {
                  final double distance = _calculateDistance(
                    latLng.latitude,
                    latLng.longitude,
                    marker.position.latitude,
                    marker.position.longitude,
                  );
                  if (distance < 0.01) {
                    _onMarkerTapped(marker.markerId);
                    break;
                  }
                }
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddPlaceScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFFecbdae),
        child: const Icon(Icons.add, color: Color.fromARGB(255, 0, 0, 0)),
      ),
    );
  }
}

