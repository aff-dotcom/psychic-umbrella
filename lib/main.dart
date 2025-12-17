import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fripesfinderv2/utils/colors.dart';
import 'package:fripesfinderv2/features/shared/splash_screen.dart';
import 'package:fripesfinderv2/features/auth/login_screen.dart';
import 'package:fripesfinderv2/features/auth/signup_screen.dart';
import 'package:fripesfinderv2/features/home/home_screen.dart';
import 'package:fripesfinderv2/providers/auth_provider.dart' as auth_provider;
import 'package:fripesfinderv2/providers/rewards_provider.dart'; // Assurez-vous que ce fichier existe
import 'package:fripesfinderv2/services/home_service.dart';
import 'package:fripesfinderv2/services/outfit_service.dart';
import 'package:fripesfinderv2/services/place_service.dart';
import 'package:fripesfinderv2/services/profile_service.dart';
import 'package:fripesfinderv2/services/notification_service.dart';
import 'firebase_options.dart';

class RouteNames {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    final homeService = HomeService();
    await homeService.setQuoteOfTheDay();
  } catch (e) {
    debugPrint("Erreur lors de l'initialisation de la citation du jour : $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => auth_provider.AuthProvider()),
        ChangeNotifierProvider(create: (_) => RewardsProvider()), // Ajout du RewardsProvider
        Provider<OutfitService>(create: (_) => OutfitService()),
        Provider<PlaceService>(create: (_) => PlaceService()),
        Provider<ProfileService>(create: (_) => ProfileService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FripesFinder',
      theme: AppTheme.theme,
      initialRoute: RouteNames.splash,
      routes: {
        RouteNames.splash: (context) => const AuthWrapper(),
        RouteNames.login: (context) => const LoginScreen(),
        RouteNames.signup: (context) => const SignUpScreen(),
        RouteNames.home: (context) => const HomeScreen(),
      },
    );
  }
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryMauve,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.primaryBlue),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<auth_provider.AuthProvider>(context);
    return StreamBuilder<User?>(
      stream: authProvider.userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Une erreur s'est produite : ${snapshot.error}"),
            ),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
