import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Instance unique

  // Getter pour obtenir l'utilisateur actuel
  User? get user => _auth.currentUser;

  // Stream pour écouter les changements d'état de l'utilisateur
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Méthode pour se connecter avec e-mail et mot de passe
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
    } catch (e) {
      throw Exception("Échec de la connexion : ${e.toString()}");
    }
  }

  // Méthode pour s'inscrire avec e-mail et mot de passe
  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      notifyListeners();
    } catch (e) {
      throw Exception("Échec de l'inscription : ${e.toString()}");
    }
  }

  // Méthode pour se déconnecter
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Déconnexion Google
      await _auth.signOut(); // Déconnexion Firebase
      notifyListeners();
    } catch (e) {
      throw Exception("Échec de la déconnexion : ${e.toString()}");
    }
  }

  // Méthode pour la connexion avec Google
  Future<void> signInWithGoogle() async {
    try {
      // Initialiser GoogleSignIn
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception("Connexion Google annulée par l'utilisateur.");
      }

      // Récupérer les détails d'authentification de Google (avec await)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Créer une credential Firebase avec le token d'ID Google
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Se connecter avec Firebase
      await _auth.signInWithCredential(credential);
      notifyListeners();
    } catch (e) {
      throw Exception("Échec de la connexion Google : ${e.toString()}");
    }
  }
}
