// ЗАЩИТА (Level 2 + 3): экран настроек.
// - SwitchListTile → setDark (сохраняется в shared_preferences).
// - DropdownButtonFormField городов: список берётся из загруженных пользователей,
//   null = «All cities» (ключ удаляется).
// - Sign out → AuthModel.logout() → токен удаляется из secure storage.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../profile/profile_screen.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final cities = {
      for (final u in context.watch<UsersModel>().items) ?u.city,
    }.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.dark,
            onChanged: settings.setDark,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String?>(
              initialValue: cities.contains(settings.city)
                  ? settings.city
                  : null,
              decoration: const InputDecoration(labelText: 'City filter'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All cities')),
                for (final c in cities)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: settings.setCity,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile photo'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () {
              Navigator.of(context).popUntil((r) => r.isFirst);
              context.read<AuthModel>().logout();
            },
          ),
        ],
      ),
    );
  }
}
