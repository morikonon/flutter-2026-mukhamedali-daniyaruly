import 'package:flutter/material.dart';

import 'user.dart';

// Показывает всё, что есть в модели. Телефон и сайт пока «тапаются» в
// пустоту — url_launcher появится в Practice 12.
class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    final website = user.website;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          _Row(
            icon: Icons.alternate_email,
            label: 'Username',
            value: user.username,
          ),
          _Row(icon: Icons.email_outlined, label: 'Email', value: user.email),
          _Row(
            icon: Icons.phone,
            label: 'Phone',
            value: user.phone,
            onTap: () {}, // Practice 12: tel:${user.phoneDigits}
          ),
          if (website != null)
            _Row(
              icon: Icons.language,
              label: 'Website',
              value: website,
              onTap: () {}, // Practice 12: https://$website
            ),
          const Divider(),
          _Row(
            icon: Icons.home_outlined,
            label: 'Address',
            value: '${a.street}, ${a.suite}\n${a.city} ${a.zipcode}',
          ),
          _Row(
            icon: Icons.place_outlined,
            label: 'Geo',
            value: '${a.geo.lat}, ${a.geo.lng}',
          ),
          const Divider(),
          _Row(
            icon: Icons.business,
            label: 'Company',
            value: '${user.company.name}\n${user.company.catchPhrase}',
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    subtitle: Text(value),
    onTap: onTap,
  );
}
