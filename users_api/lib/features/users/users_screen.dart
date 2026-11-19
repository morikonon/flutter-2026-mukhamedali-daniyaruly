import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'users_model.dart';
import 'widgets/status_views.dart';
import 'widgets/user_list.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // watch: экран перестраивается на каждый notifyListeners() модели.
    final m = context.watch<UsersModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const NewUserScreen())),
        icon: const Icon(Icons.person_add),
        label: const Text('New user'),
      ),
      body: m.loading ? const LoadingView() : _body(m),
    );
  }

  // Исчерпывающий switch по sealed ApiException? — без default.
  // Убери любую ветку, и код не скомпилируется:
  // "The type 'ApiException?' is not exhaustively matched".
  Widget _body(UsersModel m) => switch (m.error) {
    null => UserList(m.items, onRefresh: m.load),
    NoConnectionException() => OfflineView(onRetry: m.load),
    NotFoundException() => const RequestErrorView(message: 'Not found (404).'),
    UnauthorizedException() => const RequestErrorView(
      message: 'Not authorized (401).',
    ),
    ServerException(:final status) => ServerErrorView(status, onRetry: m.load),
    BadResponseException() => const GenericErrorView(),
  };
}
