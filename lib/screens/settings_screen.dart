import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notification reminders'),
            value: true,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: const Text('Email Updates'),
            value: true,
            onChanged: (value) {},
          ),
          const AboutListTile(
            icon: Icon(Icons.info),
            applicationName: 'BookSwap',
            applicationVersion: '1.0.0',
          ),
          if (user != null) ...[
            const Divider(),
            ListTile(
              title: Text('Logged in as: ${user.email}'),
            ),
            ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.logout),
              onTap: () {
                ref.read(authServiceProvider).signOut();
              },
            ),
          ],
        ],
      ),
    );
  }
}