// ЗАЩИТА (Level 5): фото профиля и обработка «Нет».
// - Разрешение запрашиваем В МОМЕНТ НАЖАТИЯ (не в initState) — пользователь понимает зачем.
// - switch по статусу: granted → камера; permanentlyDenied → СВОЙ диалог → openAppSettings();
//   denied/остальные → SnackBar с объяснением. Android: 2 отказа → permanentlyDenied.
// - pickImage возвращает null при Cancel: проверка на null, mounted, затем setState/сохранение.
//   Нигде нет ! после await устройства.
// - Файл копируем в Documents как avatar.jpg (picker кладёт во временную папку),
//   путь — в shared_preferences → фото переживает перезапуск.
// - Главное: без фото фича продолжает работать — показываем инициал.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final saved = await File(picked.path).copy('${dir.path}/avatar.jpg');
    // тот же путь avatar.jpg → убираем старую картинку из кэша изображений
    await FileImage(saved).evict();
    if (!mounted) return;
    await context.read<SettingsModel>().setAvatar(saved.path);
  }

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted || PermissionStatus.limited:
        await _pick(ImageSource.camera);
      case PermissionStatus.permanentlyDenied:
        await _showSettingsDialog();
      case PermissionStatus.denied ||
          PermissionStatus.restricted ||
          PermissionStatus.provisional:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera access is needed to take a profile photo.'),
          ),
        );
    }
  }

  Future<void> _showSettingsDialog() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Camera is blocked'),
        content: const Text(
          'You declined camera access. Turn it on in Settings to take a photo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open ?? false) await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final path = context.watch<SettingsModel>().avatarPath;
    final file = path == null ? null : File(path);
    final hasPhoto = file != null && file.existsSync();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundImage: hasPhoto ? FileImage(file) : null,
              child: hasPhoto
                  ? null
                  : const Text('M', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo),
              label: const Text('Choose photo'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take photo'),
            ),
          ],
        ),
      ),
    );
  }
}
