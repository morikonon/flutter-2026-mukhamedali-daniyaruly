import 'package:flutter/material.dart';

// Экраны-состояния для switch в UsersScreen.
// Retry есть только там, где он имеет смысл: нет сети и 5xx.

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class OfflineView extends StatelessWidget {
  const OfflineView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _StatusView(
    icon: Icons.wifi_off,
    title: 'No connection',
    message: 'Check the network and try again.',
    onRetry: onRetry,
  );
}

class ServerErrorView extends StatelessWidget {
  const ServerErrorView(this.status, {super.key, required this.onRetry});

  final int status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _StatusView(
    icon: Icons.cloud_off,
    title: 'Server error $status',
    message: 'The server is having trouble. Try again later.',
    onRetry: onRetry,
  );
}

// 4xx: ошибка в нашем запросе — повтор того же запроса не поможет.
class RequestErrorView extends StatelessWidget {
  const RequestErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) =>
      _StatusView(icon: Icons.block, title: 'Request failed', message: message);
}

// Нечитаемый JSON — это баг, а не плохая сеть: Retry не предлагаем.
class GenericErrorView extends StatelessWidget {
  const GenericErrorView({super.key});

  @override
  Widget build(BuildContext context) => const _StatusView(
    icon: Icons.bug_report_outlined,
    title: 'Something went wrong',
    message: 'The server sent data the app could not read.',
  );
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (retry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
