import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Retourne l'utilisateur actuel
  User? get user => _firebaseAuth.currentUser;

  // Retourne un Stream<User?> pour suivre les changements d'état de l'utilisateur
  Stream<User?> get userChanges => _firebaseAuth.authStateChanges();

  // Méthode pour se connecter avec un email et un mot de passe
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners(); // Notifie les écouteurs après une connexion réussie
      return userCredential.user;
    } catch (e) {
      print("Erreur de connexion: $e");
      return null;
    }
  }

  // Méthode pour s'inscrire avec un email et un mot de passe
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners(); // Notifie les écouteurs après une inscription réussie
      return userCredential.user;
    } catch (e) {
      print("Erreur d'inscription: $e");
      return null;
    }
  }

  // Méthode pour se déconnecter
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    notifyListeners(); // Notifie les écouteurs après une déconnexion
  }
}
