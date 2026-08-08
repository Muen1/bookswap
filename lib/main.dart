import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'theme/app_colors.dart';
import 'providers/theme_provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      print('Firebase initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Firebase: $e');
    }
    
  }
  
  // Initialize notifications with error handling
  try {
    await NotificationService.initialize();
    if (kDebugMode) {
      print('Notifications initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing notifications: $e');
    }
    
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'BookSwap',
      theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.spineGreen,
    brightness: Brightness.light,
    surface: AppColors.paper,
    secondary: AppColors.mustard,
  ),
  scaffoldBackgroundColor: AppColors.paper,
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 2,
    backgroundColor: AppColors.spineGreen,
    foregroundColor: AppColors.paper,
  ),
  cardTheme: const CardThemeData(
    color: AppColors.cardSurface,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
  ),
),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.spineGreen,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      home: const App(),
      debugShowCheckedModeBanner: false,
      // Add error handling for the entire app
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // ignore: deprecated_member_use
            textScaler: TextScaler.linear(MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2)),
          ),
          child: child!,
        );
      },
    );
  }
}