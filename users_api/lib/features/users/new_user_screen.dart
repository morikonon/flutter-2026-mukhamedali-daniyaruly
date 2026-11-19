import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_model.dart';

// Форма POST /users. Save -> UsersModel.create -> repo.create.
// Успех: пользователь с id от сервера встаёт в начало списка, форма закрывается.
// Ошибка: SnackBar, форма остаётся открытой с введёнными данными.
class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final model = context.read<UsersModel>();
    // Второй тап до перерисовки кнопки: запрос уже в полёте — выходим.
    if (model.saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await model.create(
        User.draft(
          name: _name.text.trim(),
          username: _username.text.trim(),
          email: _email.text.trim(),
        ),
      );
      // После await экран мог закрыться — проверяем mounted перед Navigator.
      // (mounted живёт здесь, в State, а не в модели.)
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_message(e))));
    }
  }

  String _message(ApiException e) => switch (e) {
    NoConnectionException() => 'No connection. Try again.',
    ServerException(:final status) => 'Server error $status. Try again later.',
    BadResponseException() => 'The server answer could not be read.',
    NotFoundException() || UnauthorizedException() => 'Request was rejected.',
  };

  @override
  Widget build(BuildContext context) {
    // Кнопка выключена, пока POST в полёте (флаг из модели).
    final saving = context.select<UsersModel, bool>((m) => m.saving);
    return Scaffold(
      appBar: AppBar(title: const Text('New user')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v ?? '').trim().length < 2 ? 'Name is too short' : null,
            ),
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
              textInputAction: TextInputAction.next,
              autocorrect: false,
              validator: (v) => RegExp(r'^[A-Za-z0-9_.]{3,}$').hasMatch(v ?? '')
                  ? null
                  : 'At least 3 letters, digits, _ or .',
            ),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              validator: (v) {
                final value = (v ?? '').trim();
                final at = value.indexOf('@');
                // Нужна @ и точка где-то после неё.
                return at > 0 && value.indexOf('.', at) > at
                    ? null
                    : 'Email looks wrong';
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              // null = кнопка неактивна: второй тап просто некуда нажать.
              onPressed: saving ? null : _save,
              child: saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
