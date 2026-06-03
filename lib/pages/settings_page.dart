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
            subtitle: const Text('Gerenciar configurações de notificação'),
            trailing: Switch(
              value: true,
              onChanged: (bool value) {},
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Ativar modo escuro'),
            trailing: Switch(
              value: false,
              onChanged: (bool value) {},
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Language'),
            subtitle: const Text('Selecione seu idioma'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: const Text('Privacy Policy'),
            subtitle: const Text('Confira nossa política de privacidade'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
