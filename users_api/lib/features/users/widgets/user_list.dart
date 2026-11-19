import 'package:flutter/material.dart';

import '../user.dart';
import '../user_detail_screen.dart';

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key, required this.onRefresh});

  final List<User> users;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    // RefreshIndicator ждёт Future: спиннер крутится, пока load() не завершится.
    onRefresh: onRefresh,
    child: ListView.separated(
      // Чтобы pull-to-refresh работал, даже если список короче экрана.
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final user = users[i];
        return ListTile(
          leading: CircleAvatar(child: Text(user.name[0])),
          title: Text(user.name),
          subtitle: Text('${user.email} · ${user.address.city}'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => UserDetailScreen(user: user),
            ),
          ),
        );
      },
    ),
  );
}
