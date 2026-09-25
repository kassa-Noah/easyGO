import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/settings/app_settings_scope.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../auth/screens/change_password_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/services/auth_service.dart';
import '../models/admin_console.dart';
import '../services/admin_service.dart';
import 'edit_admin_profile_screen.dart';

/// The signed-in administrator's own account.
///
/// Everything shown here comes from `/users/me`, so the name, email and phone
/// are the ones the backend holds for the token that opened the screen.
class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  AdminAccount? _account;

  bool _isLoading = true;

  String? _errorMessage;

  String _t(AppSettingsController settings, String en, String fr) =>
      settings.isFrench ? fr : en;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final AdminAccount account = await AdminService.instance.getMyAccount();

      if (!mounted) {
        return;
      }

      setState(() {
        _account = account;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _editProfile() async {
    final AdminAccount? account = _account;

    if (account == null) {
      return;
    }

    final AdminProfileData? result = await Navigator.push<AdminProfileData>(
      context,
      MaterialPageRoute(
        builder: (_) => EditAdminProfileScreen(
          initialFirstName: account.firstName,
          initialLastName: account.lastName,
          email: account.email,
          initialPhone: account.phone ?? '',
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    // The save already returned the stored record; re-reading keeps this screen
    // honest if anything else about the account changed in the meantime.
    await _loadAccount();
  }

  Future<void> _selectLanguage(AppSettingsController settings) async {
    final selected = await showDialog<AppLanguage>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(_t(settings, 'Language', 'Langue')),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, AppLanguage.english),
            child: const ListTile(
              leading: Icon(Icons.language),
              title: Text('English'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, AppLanguage.french),
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

  Future<void> _selectTheme(AppSettingsController settings) async {
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(_t(settings, 'Appearance', 'Apparence')),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, ThemeMode.system),
            child: ListTile(
              leading: const Icon(Icons.settings_suggest_outlined),
              title: Text(_t(settings, 'System default', 'Réglage système')),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, ThemeMode.light),
            child: ListTile(
              leading: const Icon(Icons.light_mode_outlined),
              title: Text(_t(settings, 'Light', 'Clair')),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, ThemeMode.dark),
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

  Future<void> _logout(AppSettingsController settings) async {
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
            child: Text(_t(settings, 'Log out', 'Se déconnecter')),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    await AuthService.instance.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.adminProfile)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildError(context)
          : _buildContent(context, settings, l),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40),
            const SizedBox(height: 14),
            Text(
              'Unable to load your account',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            TextButton(onPressed: _loadAccount, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppSettingsController settings,
    AppLocalizations l,
  ) {
    final AdminAccount account = _account!;
    final theme = Theme.of(context);

    return ListView(
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
                        account.fullName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(account.email),
                      const SizedBox(height: 10),
                      Chip(
                        avatar: const Icon(
                          Icons.verified_user_outlined,
                          size: 18,
                        ),
                        label: Text(l.platformAdministration),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: _t(settings, 'Account', 'Compte')),
                const SizedBox(height: 10),
                GlassContainer(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(
                          _t(settings, 'Edit profile', 'Modifier le profil'),
                        ),
                        subtitle: Text(
                          _t(
                            settings,
                            'Update your name and phone number',
                            'Modifier votre nom et votre téléphone',
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
                            'Update your sign-in password',
                            'Modifier votre mot de passe de connexion',
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChangePasswordScreen(),
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
                        value: account.fullName,
                      ),
                      const Divider(),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: account.email,
                      ),
                      const Divider(),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: _t(settings, 'Phone', 'Téléphone'),
                        value: account.phone?.isNotEmpty == true
                            ? account.phone!
                            : '—',
                      ),
                      const Divider(),
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: _t(settings, 'Role', 'Rôle'),
                        value: l.platformAdministration,
                      ),
                      const Divider(),
                      _InfoRow(
                        icon: Icons.toggle_on_outlined,
                        label: _t(settings, 'Status', 'Statut'),
                        value: account.statusLabel,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: _t(settings, 'Preferences', 'Préférences')),
                const SizedBox(height: 10),
                GlassContainer(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language_outlined),
                        title: Text(_t(settings, 'Language', 'Langue')),
                        subtitle: Text(
                          settings.isFrench ? 'Français' : 'English',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _selectLanguage(settings),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.brightness_6_outlined),
                        title: Text(_t(settings, 'Appearance', 'Apparence')),
                        subtitle: Text(_themeLabel(settings)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _selectTheme(settings),
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
                    label: Text(_t(settings, 'Log out', 'Se déconnecter')),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 14),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
