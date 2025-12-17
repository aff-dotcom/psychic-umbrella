import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer les 5 actualités les plus récentes
  Stream<List<Map<String, dynamic>>> getNews() {
    return _firestore
        .collection('news')
        .orderBy('date', descending: true)
        .limit(5) // Limiter à 5 actualités récentes
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }

  // Récupérer la citation du jour (basée sur la date actuelle)
  Stream<Map<String, dynamic>?> getQuoteOfTheDay() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _firestore
        .collection('quotes')
        .where('date', isEqualTo: today)
        .limit(1)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : null);
  }

  // Définir la citation du jour (à appeler une fois par jour via une fonction Cloud)
  Future<void> setQuoteOfTheDay() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Vérifier si une citation du jour existe déjà
    final existingQuote = await _firestore
        .collection('quotes')
        .where('date', isEqualTo: today)
        .limit(1)
        .get();

    if (existingQuote.docs.isEmpty) {
      // Sélectionner une citation aléatoire parmi les citations actives
      final quotesSnapshot = await _firestore
          .collection('quotes')
          .where('isActive', isEqualTo: true)
          .get();

      if (quotesSnapshot.docs.isNotEmpty) {
        // Choisir une citation aléatoire
        final randomIndex = DateTime.now().millisecondsSinceEpoch % quotesSnapshot.docs.length;
        final randomQuote = quotesSnapshot.docs[randomIndex].data();

        // Définir la citation du jour dans Firestore
        await _firestore.collection('quotes').doc(today).set({
          'text': randomQuote['text'],
          'author': randomQuote['author'],
          'date': today,
          'isActive': true, // Optionnel : marquer comme active si nécessaire
        });
      }
    }
  }
}
