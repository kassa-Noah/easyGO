import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/glass_container.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.adminProfile)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassContainer(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 38,
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l.administrator,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text('admin@easygo.cm'),
                const SizedBox(height: 8),
                Chip(label: Text(l.platformAdministration)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(l.settings),
                  subtitle: Text(l.settingsSubtitle),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: Text(l.language),
                  subtitle: Text(l.languageDescription),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: Text(l.appearance),
                  subtitle: Text(l.appearanceDescription),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(child: Text(l.adminProfileNotice)),
        ],
      ),
    );
  }
}
