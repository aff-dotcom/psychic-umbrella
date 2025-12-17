import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../utils/quotes.dart'; // Vérifie que le chemin est correct

class QuoteService {
  static const String _lastQuoteIndexKey = 'last_quote_index';
  static const String _secondLastQuoteIndexKey = 'second_last_quote_index';

  Future<Citation> getRandomQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final lastIndex = prefs.getInt(_lastQuoteIndexKey) ?? -1;
    final secondLastIndex = prefs.getInt(_secondLastQuoteIndexKey) ?? -1;

    // Utilise `allQuotes` au lieu de `citations`
    final availableIndices = List<int>.generate(
      allQuotes.length,
      (i) => i,
    ).where((index) => index != lastIndex && index != secondLastIndex).toList();

    int randomIndex;
    if (availableIndices.isEmpty) {
      // Réinitialise si toutes les citations ont été utilisées
      randomIndex = 0;
      await prefs.setInt(_secondLastQuoteIndexKey, -1);
      await prefs.setInt(_lastQuoteIndexKey, 0);
    } else {
      // Utilise Random pour éviter les répétitions prévisibles
      final random = Random();
      randomIndex = availableIndices[random.nextInt(availableIndices.length)];
      await prefs.setInt(_secondLastQuoteIndexKey, lastIndex);
      await prefs.setInt(_lastQuoteIndexKey, randomIndex);
    }

    return allQuotes[randomIndex]; // Retourne un objet `Citation` depuis la liste globale
  }
}

