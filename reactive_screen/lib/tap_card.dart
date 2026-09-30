import 'package:flutter/material.dart';

class TapCard extends StatefulWidget {
  const TapCard({super.key});

  @override
  State<TapCard> createState() => _TapCardState();
}

class _TapCardState extends State<TapCard> {
  int _taps = 0;

  void _onTap() {
    setState(() {
      _taps++;
    });
  }

  Future<void> _onLongPress() async {
    final reset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset the count?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (reset == true) {
      setState(() {
        _taps = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: _onTap,
        onLongPress: _onLongPress,
        child: ListTile(
          title: const Text('Tap this card'),
          trailing: Text('$_taps'),
        ),
      ),
    );
  }
}
