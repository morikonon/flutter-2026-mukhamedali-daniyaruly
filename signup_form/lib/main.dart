import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Created once, here, never in build().
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();
  final _emailFocus = FocusNode();

  // Only the length lives in State; the text stays in the controller.
  int _passwordLength = 0;
  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthText]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    // The only null assertion: the Form is on screen when this runs.
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Account created')));
      setState(() => _done = true);
    }
  }

  Future<void> _pickBirth() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      initialDate: _birth ?? DateTime(2005),
    );
    // Cancel returns null: keep the old date.
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _birth = picked;
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      _birthText.text = '$day.$month.${picked.year}';
    });
  }

  void _startOver() {
    // The Form is off screen here, so _formKey.currentState is null.
    setState(() {
      for (final c in [_name, _email, _password, _confirm, _birthText]) {
        c.clear();
      }
      _group = null;
      _birth = null;
      _agreed = false;
      _passwordLength = 0;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: _done ? _buildSummary() : _buildForm(),
  );

  Widget _buildSummary() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SummaryCard(
          name: _name.text.trim(),
          email: _email.text.trim(),
          group: _group ?? '',
          birthDate: _birthText.text,
        ),
        TextButton(onPressed: _startOver, child: const Text('Start over')),
      ],
    ),
  );

  Widget _buildForm() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (v) =>
                (v ?? '').trim().length < 2 ? 'Name is too short' : null,
          ),
          TextFormField(
            controller: _email,
            focusNode: _emailFocus,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'name@kbtu.kz',
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (v) {
              final value = (v ?? '').trim();
              final at = value.indexOf('@');
              // Needs an @ and a dot somewhere after it.
              return at >= 0 && value.indexOf('.', at) > at
                  ? null
                  : 'Email looks wrong';
            },
          ),
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(
              labelText: 'Password',
              helperText: 'At least 8 characters',
            ),
            obscureText: true,
            textInputAction: TextInputAction.next,
            onChanged: (v) => setState(() => _passwordLength = v.length),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (v) =>
                (v ?? '').length < 8 ? 'Password is too short' : null,
          ),
          Text('$_passwordLength of 8', textAlign: TextAlign.end),
          TextFormField(
            controller: _confirm,
            decoration: const InputDecoration(labelText: 'Confirm password'),
            obscureText: true,
            textInputAction: TextInputAction.done,
            // Same gate as the button: the keyboard cannot bypass it.
            onFieldSubmitted: _agreed ? (_) => _submit() : null,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            // Reads another controller: must equal the password.
            validator: (v) =>
                v == _password.text ? null : 'Passwords do not match',
          ),
          DropdownButtonFormField<String>(
            initialValue: _group,
            decoration: const InputDecoration(labelText: 'Group'),
            items: [
              for (final g in groups)
                DropdownMenuItem(value: g, child: Text(g)),
            ],
            onChanged: (g) => setState(() => _group = g),
            validator: (g) => g == null ? 'Choose a group' : null,
          ),
          TextFormField(
            controller: _birthText,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Date of birth',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: _pickBirth,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (_) => _birth == null ? 'Choose a date of birth' : null,
          ),
          CheckboxListTile(
            title: const Text('I agree to the rules'),
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _agreed ? _submit : null,
            child: const Text('Sign up'),
          ),
        ],
      ),
    ),
  );
}
