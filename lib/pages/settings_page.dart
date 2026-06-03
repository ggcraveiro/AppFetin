import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Manage notification preferences'),
            trailing: Switch(
              value: true,
              onChanged: (bool value) {},
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            trailing: Switch(
              value: false,
              onChanged: (bool value) {},
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Language'),
            subtitle: const Text('Select your language'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: const Text('Privacy Policy'),
            subtitle: const Text('View our privacy policy'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
