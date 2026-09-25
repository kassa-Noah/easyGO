import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/settings/app_settings_scope.dart';
import '../../../shared/widgets/glass_container.dart';
import '../services/auth_service.dart';

/// Changes the signed-in account's password.
///
/// Any signed-in role can use this: the backend takes the account from the
/// access token, so there is no account to choose and no way to reach somebody
/// else's password through this screen.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

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
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await AuthService.instance.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );

      if (!mounted) return;

      _currentController.clear();
      _newController.clear();
      _confirmController.clear();

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline),
          title: Text(
            _t(settings, 'Password updated', 'Mot de passe mis à jour'),
          ),
          content: Text(
            _t(
              settings,
              'Your password has been changed. Use the new password the next time you sign in.',
              'Votre mot de passe a été modifié. Utilisez le nouveau mot de passe lors de votre prochaine connexion.',
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
      Navigator.pop(context);
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
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
                              'Your current password is required, and the new password must differ from it. The change applies to the account you are signed in with.',
                              'Votre mot de passe actuel est requis, et le nouveau doit en différer. Le changement s’applique au compte avec lequel vous êtes connecté.',
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
                      onPressed: _isSubmitting ? null : () => _submit(settings),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.lock_reset_outlined),
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
