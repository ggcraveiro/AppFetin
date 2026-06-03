import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Notificações'),
            subtitle: const Text('Ativar ou desativar as notificações'),
            trailing: Switch(
              value: true,
              onChanged: (bool value) {},
            ),
          ),
          const Divider(),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                title: const Text('Modo Escuro'),
                subtitle: const Text('Ativar ou desativar o modo escuro'),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (bool value) {
                    themeProvider.toggleDarkMode();
                  },
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Idioma'),
            subtitle: const Text('Selecione seu idioma'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: const Text('Política de Privacidade'),
            subtitle: const Text('Confira nossa política de privacidade'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
