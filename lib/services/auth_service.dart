import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupérer l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Écouter les changements d'état de l'utilisateur
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Se connecter avec email/mot de passe
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Erreur de connexion : ${e.message}");
      rethrow; // Propager l'erreur pour une gestion ultérieure
    }
  }

  // S'inscrire avec email/mot de passe
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Erreur d'inscription : ${e.message}");
      rethrow; // Propager l'erreur pour une gestion ultérieure
    }
  }

  // Se déconnecter
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print("Erreur de réinitialisation du mot de passe : ${e.message}");
      rethrow; // Propager l'erreur pour une gestion ultérieure
    }
  }
}
