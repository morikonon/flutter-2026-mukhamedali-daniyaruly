import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  final String name;
  final String university;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/photo.jpg',
            width: 140,
            height: 140,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 30,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          university,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
