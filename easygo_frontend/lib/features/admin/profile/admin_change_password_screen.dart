import 'package:flutter/material.dart';

import '../../../core/settings/app_settings_controller.dart';
import '../../../core/settings/app_settings_scope.dart';
import '../../../shared/widgets/glass_container.dart';

class AdminChangePasswordScreen extends StatefulWidget {
  const AdminChangePasswordScreen({super.key});

  @override
  State<AdminChangePasswordScreen> createState() =>
      _AdminChangePasswordScreenState();
}

class _AdminChangePasswordScreenState extends State<AdminChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String _t(AppSettingsController settings, String en, String fr) =>
      settings.isFrench ? fr : en;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppSettingsController settings) async {
    if (!_formKey.currentState!.validate()) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline),
        title: Text(
          _t(
            settings,
            'Password update simulated',
            'Modification du mot de passe simulée',
          ),
        ),
        content: Text(
          _t(
            settings,
            'The form is valid. In production, password verification and modification will be performed securely by the authenticated backend. No password is stored by this frontend prototype.',
            'Le formulaire est valide. En production, la vérification et la modification du mot de passe seront effectuées de manière sécurisée par le backend authentifié. Aucun mot de passe n’est enregistré par ce prototype frontend.',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    _currentController.clear();
    _newController.clear();
    _confirmController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _t(settings, 'Change Password', 'Modifier le mot de passe'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GlassContainer(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _currentController,
                          obscureText: _obscureCurrent,
                          decoration: InputDecoration(
                            labelText: _t(
                              settings,
                              'Current password',
                              'Mot de passe actuel',
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscureCurrent = !_obscureCurrent,
                              ),
                              icon: Icon(
                                _obscureCurrent
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return _t(
                                settings,
                                'Enter your current password.',
                                'Saisissez votre mot de passe actuel.',
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _newController,
                          obscureText: _obscureNew,
                          decoration: InputDecoration(
                            labelText: _t(
                              settings,
                              'New password',
                              'Nouveau mot de passe',
                            ),
                            prefixIcon: const Icon(Icons.password_outlined),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscureNew = !_obscureNew),
                              icon: Icon(
                                _obscureNew
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return _t(
                                settings,
                                'Enter a new password.',
                                'Saisissez un nouveau mot de passe.',
                              );
                            }
                            if (value.length < 8) {
                              return _t(
                                settings,
                                'Use at least 8 characters.',
                                'Utilisez au moins 8 caractères.',
                              );
                            }
                            if (value == _currentController.text) {
                              return _t(
                                settings,
                                'The new password must be different from the current password.',
                                'Le nouveau mot de passe doit être différent du mot de passe actuel.',
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: _t(
                              settings,
                              'Confirm new password',
                              'Confirmer le nouveau mot de passe',
                            ),
                            prefixIcon: const Icon(Icons.password_outlined),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return _t(
                                settings,
                                'Confirm the new password.',
                                'Confirmez le nouveau mot de passe.',
                              );
                            }
                            if (value != _newController.text) {
                              return _t(
                                settings,
                                'The passwords do not match.',
                                'Les mots de passe ne correspondent pas.',
                              );
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GlassContainer(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.security_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _t(
                              settings,
                              'This prototype validates the password form only. Password verification and persistence belong to the backend authentication layer.',
                              'Ce prototype valide uniquement le formulaire du mot de passe. La vérification et l’enregistrement du mot de passe appartiennent à la couche d’authentification du backend.',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _submit(settings),
                      icon: const Icon(Icons.lock_reset_outlined),
                      label: Text(
                        _t(
                          settings,
                          'Update password',
                          'Modifier le mot de passe',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
