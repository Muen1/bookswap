import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/email_verification_screen.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    _setupFCMToken();
  }

  Future<void> _setupFCMToken() async {
    // Wait for auth state to be available
    await Future.delayed(const Duration(seconds: 2));
    
    final authService = ref.read(authServiceProvider);
    final currentUser = ref.read(authStateProvider).value;
    
    if (currentUser != null) {
      await authService.updateUserFCMToken(currentUser.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // Update FCM token when user logs in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(authServiceProvider).updateUserFCMToken(user.uid);
          });

          if (!user.emailVerified) {
            return EmailVerificationScreen(user: user);
          }
          return const HomeScreen();
        }
        return const AuthScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => ref.invalidate(authStateProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}