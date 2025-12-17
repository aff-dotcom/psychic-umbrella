import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fripesfinderv2/models/outfit.dart';
import 'package:fripesfinderv2/services/outfit_service.dart';
import 'package:provider/provider.dart';
import 'package:fripesfinderv2/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class OutfitDetailScreen extends StatefulWidget {
  final Outfit? outfit;
  final String id;

  const OutfitDetailScreen({
    super.key,
    this.outfit,
    required this.id,
  });

  @override
  State<OutfitDetailScreen> createState() => _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends State<OutfitDetailScreen> {
  final OutfitService _outfitService = OutfitService();
  final TextEditingController _commentController = TextEditingController();
  late bool _isLiked;
  late String _currentUserId;
  late Outfit _outfit;
  bool _isLoadingComments = false;
  bool _isLoadingOutfit = true;

  @override
  void initState() {
    super.initState();
    _currentUserId = Provider.of<AuthProvider>(context, listen: false).user!.uid;
    if (widget.outfit != null) {
      _outfit = widget.outfit!;
      _isLiked = _outfit.likedBy.contains(_currentUserId);
      _isLoadingOutfit = false;
    } else {
      _fetchOutfit(widget.id);
    }
  }

  Future<void> _fetchOutfit(String outfitId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('outfits').doc(outfitId).get();
      if (mounted) {
        setState(() {
          _outfit = Outfit.fromMap(doc.data()!, doc.id);
          _isLiked = _outfit.likedBy.contains(_currentUserId);
          _isLoadingOutfit = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement de la tenue : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    try {
      if (_isLiked) {
        await _outfitService.unlikeOutfit(_outfit.id, _currentUserId);
        if (mounted) {
          setState(() {
            _isLiked = false;
            _outfit = Outfit(
              id: _outfit.id,
              userId: _outfit.userId,
              title: _outfit.title,
              description: _outfit.description,
              imageUrls: _outfit.imageUrls,
              tags: _outfit.tags,
              createdAt: _outfit.createdAt,
              likes: _outfit.likes - 1,
              likedBy: List.from(_outfit.likedBy)..remove(_currentUserId),
              comments: _outfit.comments,
            );
          });
        }
      } else {
        await _outfitService.likeOutfit(_outfit.id, _currentUserId);
        if (mounted) {
          setState(() {
            _isLiked = true;
            _outfit = Outfit(
              id: _outfit.id,
              userId: _outfit.userId,
              title: _outfit.title,
              description: _outfit.description,
              imageUrls: _outfit.imageUrls,
              tags: _outfit.tags,
              createdAt: _outfit.createdAt,
              likes: _outfit.likes + 1,
              likedBy: List.from(_outfit.likedBy)..add(_currentUserId),
              comments: _outfit.comments,
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour du like : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) {
      return;
    }
    setState(() => _isLoadingComments = true);
    try {
      await _outfitService.addComment(
        _outfit.id,
        _currentUserId,
        _commentController.text.trim(),
      );
      _commentController.clear();
      final updatedOutfit = await _fetchUpdatedOutfit(_outfit.id);
      if (mounted) {
        setState(() {
          _outfit = updatedOutfit;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout du commentaire : $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoadingComments = false);
      }
    }
  }

  Future<Outfit> _fetchUpdatedOutfit(String outfitId) async {
    final doc = await FirebaseFirestore.instance.collection('outfits').doc(outfitId).get();
    return Outfit.fromMap(doc.data()!, doc.id);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingOutfit) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_outfit.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galerie d'images
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: _outfit.imageUrls.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    _outfit.imageUrls[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      );
                    },
                  );
                },
              ),
            ),
            // Titre, description et tags
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _outfit.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _outfit.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _outfit.tags
                        .map((tag) => Chip(
                              label: Text(tag),
                              labelStyle: const TextStyle(fontSize: 12),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            // Bouton Like et nombre de likes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.grey,
                    ),
                    onPressed: _toggleLike,
                  ),
                  Text(
                    '${_outfit.likes} ${_outfit.likes > 1 ? 'likes' : 'like'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            // Section des commentaires
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Commentaires',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            // Liste des commentaires
            _outfit.comments.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Aucun commentaire pour le moment.'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _outfit.comments.length,
                    itemBuilder: (context, index) {
                      final comment = _outfit.comments[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                        title: Text(comment.text),
                        subtitle: Text(
                          'Posté le ${DateFormat('dd/MM/yyyy – HH:mm').format(comment.createdAt)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
            // Champ pour ajouter un commentaire
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Ajouter un commentaire...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _isLoadingComments
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.send, color: Colors.blue),
                    onPressed: _isLoadingComments ? null : _addComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
