// ЗАЩИТА (Level 2 + 4): список пользователей.
// - Фильтр по городу берётся из SettingsModel (сохранён в prefs → применён сразу после перезапуска).
// - Баннер «Saved data · no connection · Retry» показывается ТОЛЬКО когда fromCache == true.
// - Ошибка без данных → switch по sealed ApiException (компилятор проверяет все случаи);
//   NoConnectionException без кэша = честный Offline-экран, а не пустой список.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final city = context.watch<SettingsModel>().city;
    final users = [
      for (final u in model.items)
        if (city == null || u.city == city) u,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(city == null ? 'Users' : 'Users · $city'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (model.fromCache)
            MaterialBanner(
              content: const Text('Saved data · no connection'),
              leading: const Icon(Icons.cloud_off),
              actions: [
                TextButton(onPressed: model.load, child: const Text('Retry')),
              ],
            ),
          Expanded(child: _body(model, users)),
        ],
      ),
    );
  }

  Widget _body(UsersModel model, List<User> users) {
    if (model.loading && model.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (model.error case final e?) {
      final message = switch (e) {
        NoConnectionException() => 'Offline: no connection and no saved data',
        ServerException(:final status) => 'Server error ($status)',
        NotFoundException() => 'Not found',
        UnauthorizedException() => 'Please sign in again',
        BadResponseException() => 'Unexpected response — please report it',
      };
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 12),
            FilledButton(onPressed: model.load, child: const Text('Retry')),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: model.load,
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, i) {
          final u = users[i];
          return ListTile(
            title: Text(u.name),
            subtitle: Text('${u.email} · ${u.city ?? '—'}'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => UserDetailScreen(user: u),
              ),
            ),
          );
        },
      ),
    );
  }
}
