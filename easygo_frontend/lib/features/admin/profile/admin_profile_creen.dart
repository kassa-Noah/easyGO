import 'package:flutter/material.dart';

import '../../../core/settings/app_settings_controller.dart';
import '../../../core/settings/app_settings_scope.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../auth/screens/login_screen.dart';
import 'admin_change_password_screen.dart';
import 'edit_admin_profile_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  String _name = 'Platform Administrator';
  String _email = 'admin@easygo.cm';
  String _phone = '+237 6 00 00 00 00';

  String _t(
    AppSettingsController settings,
    String en,
    String fr,
  ) =>
      settings.isFrench ? fr : en;

  Future<void> _editProfile() async {
    final result = await Navigator.push<AdminProfileData>(
      context,
      MaterialPageRoute(
        builder: (_) => EditAdminProfileScreen(
          initialName: _name,
          initialEmail: _email,
          initialPhone: _phone,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _name = result.name;
      _email = result.email;
      _phone = result.phone;
    });
  }

  Future<void> _selectLanguage(
    AppSettingsController settings,
  ) async {
    final selected = await showDialog<AppLanguage>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(_t(settings, 'Language', 'Langue')),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(
              dialogContext,
              AppLanguage.english,
            ),
            child: const ListTile(
              leading: Icon(Icons.language),
              title: Text('English'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(
              dialogContext,
              AppLanguage.french,
            ),
            child: const ListTile(
              leading: Icon(Icons.language),
              title: Text('Français'),
            ),
          ),
        ],
      ),
    );

    if (selected != null) {
      settings.setLanguage(selected);
    }
  }

  Future<void> _selectTheme(
    AppSettingsController settings,
  ) async {
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(_t(settings, 'Appearance', 'Apparence')),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(
              dialogContext,
              ThemeMode.system,
            ),
            child: ListTile(
              leading: const Icon(Icons.settings_suggest_outlined),
              title: Text(
                _t(
                  settings,
                  'System default',
                  'Réglage système',
                ),
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(
              dialogContext,
              ThemeMode.light,
            ),
            child: ListTile(
              leading: const Icon(Icons.light_mode_outlined),
              title: Text(_t(settings, 'Light', 'Clair')),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(
              dialogContext,
              ThemeMode.dark,
            ),
            child: ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: Text(_t(settings, 'Dark', 'Sombre')),
            ),
          ),
        ],
      ),
    );

    if (selected != null) {
      settings.setThemeMode(selected);
    }
  }

  String _themeLabel(AppSettingsController settings) {
    switch (settings.themeMode) {
      case ThemeMode.system:
        return _t(settings, 'System default', 'Réglage système');
      case ThemeMode.light:
        return _t(settings, 'Light', 'Clair');
      case ThemeMode.dark:
        return _t(settings, 'Dark', 'Sombre');
    }
  }

  Future<void> _logout(
    AppSettingsController settings,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_t(settings, 'Log out', 'Déconnexion')),
        content: Text(
          _t(
            settings,
            'Are you sure you want to log out of the administrator portal?',
            'Voulez-vous vraiment vous déconnecter du portail administrateur ?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_t(settings, 'Cancel', 'Annuler')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              _t(settings, 'Log out', 'Se déconnecter'),
            ),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _t(
            settings,
            'Admin Profile',
            'Profil administrateur',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: [
                  GlassContainer(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 42,
                          child: Icon(
                            Icons.admin_panel_settings_outlined,
                            size: 42,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _name,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(_email),
                        const SizedBox(height: 10),
                        Chip(
                          avatar: const Icon(
                            Icons.verified_user_outlined,
                            size: 18,
                          ),
                          label: Text(
                            _t(
                              settings,
                              'Platform Administrator',
                              'Administrateur de la plateforme',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    title: _t(settings, 'Account', 'Compte'),
                  ),
                  const SizedBox(height: 10),
                  GlassContainer(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(
                            _t(
                              settings,
                              'Edit profile',
                              'Modifier le profil',
                            ),
                          ),
                          subtitle: Text(
                            _t(
                              settings,
                              'Update administrator information',
                              'Modifier les informations administrateur',
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _editProfile,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.lock_outline),
                          title: Text(
                            _t(
                              settings,
                              'Change password',
                              'Modifier le mot de passe',
                            ),
                          ),
                          subtitle: Text(
                            _t(
                              settings,
                              'Update account security credentials',
                              'Modifier les identifiants de sécurité',
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AdminChangePasswordScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    title: _t(
                      settings,
                      'Administrator information',
                      'Informations administrateur',
                    ),
                  ),
                  const SizedBox(height: 10),
                  GlassContainer(
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: _t(settings, 'Name', 'Nom'),
                          value: _name,
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: _email,
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: _t(settings, 'Phone', 'Téléphone'),
                          value: _phone,
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.badge_outlined,
                          label: _t(settings, 'Role', 'Rôle'),
                          value: _t(
                            settings,
                            'Platform Administrator',
                            'Administrateur de la plateforme',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    title: _t(
                      settings,
                      'Preferences',
                      'Préférences',
                    ),
                  ),
                  const SizedBox(height: 10),
                  GlassContainer(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.language_outlined),
                          title: Text(
                            _t(settings, 'Language', 'Langue'),
                          ),
                          subtitle: Text(
                            settings.isFrench ? 'Français' : 'English',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _selectLanguage(settings),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.brightness_6_outlined,
                          ),
                          title: Text(
                            _t(settings, 'Appearance', 'Apparence'),
                          ),
                          subtitle: Text(_themeLabel(settings)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _selectTheme(settings),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlassContainer(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.security_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _t(
                              settings,
                              'Administrator privileges must come from the authenticated account and be validated by the backend. Profile and password changes are simulated locally until the authentication API is connected.',
                              'Les privilèges administrateur doivent provenir du compte authentifié et être validés par le backend. Les modifications du profil et du mot de passe sont simulées localement jusqu’à la connexion de l’API d’authentification.',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _logout(settings),
                      icon: const Icon(Icons.logout),
                      label: Text(
                        _t(
                          settings,
                          'Log out',
                          'Se déconnecter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
