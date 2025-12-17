import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fripesfinderv2/services/outfit_service.dart';
import 'package:fripesfinderv2/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class PublishOutfitScreen extends StatefulWidget {
  const PublishOutfitScreen({super.key});

  @override
  State<PublishOutfitScreen> createState() => _PublishOutfitScreenState();
}

class _PublishOutfitScreenState extends State<PublishOutfitScreen> {
  final _formKey = GlobalKey<FormState>();
  final OutfitService _outfitService = OutfitService();
  final ImagePicker _picker = ImagePicker();

  String _title = '';
  String _description = '';
  String _location = '';
  List<XFile>? _images;
  final Set<String> _tags = {};
  final List<String> _availableTags = [
    'Vintage', 'Chic', 'Streetwear', 'Casual', 'Luxe', 'Été', 'Hiver', 'Printemps', 'Automne'
  ];
  bool _isLoading = false;

  // Fonction pour sélectionner des images depuis la galerie
  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _images = pickedFiles;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection des images : $e')),
        );
      }
    }
  }

  // Fonction pour soumettre le formulaire
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (_images == null || _images!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins une photo.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user!;
      await _outfitService.addOutfit(
        userId: user.uid,
        title: _title,
        description: _description,
        location: _location,
        images: _images!,
        tags: _tags.toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tenue publiée avec succès !')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la publication : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publier une tenue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Champ pour le titre
              TextFormField(
                decoration: const InputDecoration(labelText: 'Titre*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              // Champ pour la description
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 16),
              // Champ pour le lieu
              TextFormField(
                decoration: const InputDecoration(labelText: 'Lieu (optionnel)'),
                onSaved: (value) => _location = value ?? '',
              ),
              const SizedBox(height: 16),
              // Bouton pour ajouter des photos
              ElevatedButton(
                onPressed: _pickImages,
                child: const Text('Ajouter des photos'),
              ),
              const SizedBox(height: 8),
              const Text('Ajoutez au moins une photo', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              // Affichage des images sélectionnées
              if (_images != null && _images!.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            Image.file(
                              File(_images![index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _images!.removeAt(index);
                                  });
                                },
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.close, size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              // Sélection des tags
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Tags :'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: _availableTags.map((tag) {
                  return FilterChip(
                    label: Text(tag),
                    selected: _tags.contains(tag),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _tags.add(tag);
                        } else {
                          _tags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Bouton de publication
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Publier'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
