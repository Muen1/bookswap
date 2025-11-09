import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
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
        ],
      ),
    );
  }
}