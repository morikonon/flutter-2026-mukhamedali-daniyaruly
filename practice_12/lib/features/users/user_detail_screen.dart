// ЗАЩИТА (Level 3 + 5): детали пользователя.
// - Ссылки: mailto:, tel: (phoneDigits), https:// + website — всё через launchUrl.
//   Uri строим через Uri(scheme:, path:) / Uri.parse со схемой.
//   launchUrl возвращает bool: false → «No app can open this» (без схемы, напр. 'kbtu.edu.kz', → false).
//   Android 11+: нужен блок <queries> в AndroidManifest, иначе система «не видит» приложения.
// - Кнопка «Copy token» только при kDebugMode — доказать, что токен есть, НЕ печатая его в лог.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/auth_model.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  Future<void> _open(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No app can open this')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = user.phoneDigits;
    final website = user.website;

    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(user.email),
            onTap: () =>
                _open(context, Uri(scheme: 'mailto', path: user.email)),
          ),
          if (phone != null)
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(user.phone ?? phone),
              onTap: () => _open(context, Uri(scheme: 'tel', path: phone)),
            ),
          if (website != null)
            ListTile(
              leading: const Icon(Icons.public),
              title: Text(website),
              onTap: () => _open(context, Uri.parse('https://$website')),
            ),
          ListTile(
            leading: const Icon(Icons.location_city),
            title: Text(user.city ?? '—'),
          ),
          if (kDebugMode)
            ListTile(
              leading: const Icon(Icons.key),
              title: const Text('Copy token to clipboard'),
              onTap: () async {
                final token = context.read<AuthModel>().token ?? '';
                await Clipboard.setData(ClipboardData(text: token));
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Token copied')));
              },
            ),
        ],
      ),
    );
  }
}
