import 'package:flutter/material.dart';
import 'package:fripesfinderv2/features/home/reward_screen.dart';
import 'package:fripesfinderv2/utils/quotes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
// Assurez-vous que le chemin est correct

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => __HomeContentState();
}

class __HomeContentState extends State<_HomeContent> {
  late Citation currentQuote;
  final QuoteService quoteService = QuoteService();

  @override
  void initState() {
    super.initState();
    _loadRandomQuote();
  }

  Future<void> _loadRandomQuote() async {
    try {
      final quote = await quoteService.getRandomQuote();
      setState(() {
        currentQuote = quote;
      });
    } catch (e) {
      setState(() {
        currentQuote = Citation(
          author: "Inconnu",
          isActive: true,
          text: "La mode est une forme d'expression personnelle.",
          source: "",
        );
      });
    }
  }

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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(text: 'Citation du jour : "'),
                  TextSpan(text: currentQuote.text),
                  TextSpan(text: '"\n— ${currentQuote.author}'),
                ],
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
                    color: Color.fromARGB(255, 0, 0, 0),
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
                // Assurez-vous que `RewardScreen` est importé ou défini ailleurs
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RewardScreen(),
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

class QuoteService {
  static const String _lastQuoteIndexKey = 'last_quote_index';
  static const String _secondLastQuoteIndexKey = 'second_last_quote_index';

  Future<Citation> getRandomQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final lastIndex = prefs.getInt(_lastQuoteIndexKey) ?? -1;
    final secondLastIndex = prefs.getInt(_secondLastQuoteIndexKey) ?? -1;

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
      final random = Random();
      randomIndex = availableIndices[random.nextInt(availableIndices.length)];
      await prefs.setInt(_secondLastQuoteIndexKey, lastIndex);
      await prefs.setInt(_lastQuoteIndexKey, randomIndex);
    }

    return allQuotes[randomIndex];
  }
}
