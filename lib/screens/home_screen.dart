import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'browse_screen.dart';
import 'my_listings_screen.dart';
import 'swap_offers_screen.dart';
import 'chat_list_screen.dart';
import 'settings_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BrowseScreen(),
    const MyListingsScreen(),
    const SwapOffersScreen(),
    const ChatListScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;
    final pendingOffersCount = currentUser != null
        ? ref.watch(pendingOffersCountProvider(currentUser.uid)).value ?? 0
        : 0;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Browse',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.swap_horiz),
                if (pendingOffersCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        pendingOffersCount > 9 ? '9+' : '$pendingOffersCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Offers',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}