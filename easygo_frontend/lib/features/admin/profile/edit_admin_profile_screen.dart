import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/settings/app_settings_scope.dart';
import '../../../shared/widgets/glass_container.dart';
import '../models/admin_console.dart';
import '../services/admin_service.dart';

/// The account as it stands after a successful save.
class AdminProfileData {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const AdminProfileData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  factory AdminProfileData.fromAccount(AdminAccount account) {
    return AdminProfileData(
      firstName: account.firstName,
      lastName: account.lastName,
      email: account.email,
      phone: account.phone ?? '',
    );
  }
}

class EditAdminProfileScreen extends StatefulWidget {
  final String initialFirstName;
  final String initialLastName;

  /// Shown because it identifies the account, but not editable here: the
  /// backend's profile route accepts a name and phone only.
  final String email;

  final String initialPhone;

  const EditAdminProfileScreen({
    super.key,
    required this.initialFirstName,
    required this.initialLastName,
    required this.email,
    required this.initialPhone,
  });

  @override
  State<EditAdminProfileScreen> createState() => _EditAdminProfileScreenState();
}

class _EditAdminProfileScreenState extends State<EditAdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;

  bool _isSaving = false;

  String _t(AppSettingsController settings, String en, String fr) =>
      settings.isFrench ? fr : en;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.initialFirstName);
    _lastNameController = TextEditingController(text: widget.initialLastName);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final AdminAccount updated = await AdminService.instance.updateMyAccount(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, AdminProfileData.fromAccount(updated));
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() => _isSaving = false);

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
          _t(
            settings,
            'Edit Admin Profile',
            'Modifier le profil administrateur',
          ),
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
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: _t(settings, 'First name', 'Prénom'),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return _t(
                                settings,
                                'Please enter your first name.',
                                'Veuillez saisir votre prénom.',
                              );
                            }
                            if (value.trim().length < 2) {
                              return _t(
                                settings,
                                'The first name is too short.',
                                'Le prénom est trop court.',
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: _t(settings, 'Last name', 'Nom'),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return _t(
                                settings,
                                'Please enter your last name.',
                                'Veuillez saisir votre nom.',
                              );
                            }
                            if (value.trim().length < 2) {
                              return _t(
                                settings,
                                'The last name is too short.',
                                'Le nom est trop court.',
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          initialValue: widget.email,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: _t(
                              settings,
                              'Email (sign-in address)',
                              'E-mail (adresse de connexion)',
                            ),
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: _t(
                              settings,
                              'Phone number',
                              'Numéro de téléphone',
                            ),
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return _t(
                                settings,
                                'Please enter a phone number.',
                                'Veuillez saisir un numéro de téléphone.',
                              );
                            }
                            if (value.trim().length < 8) {
                              return _t(
                                settings,
                                'Please enter a valid phone number.',
                                'Veuillez saisir un numéro de téléphone valide.',
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
                        const Icon(Icons.info_outline),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _t(
                              settings,
                              'Your name and phone number are saved to your account. The email address identifies the account and is not changed here.',
                              'Votre nom et votre numéro de téléphone sont enregistrés sur votre compte. L’adresse e-mail identifie le compte et n’est pas modifiée ici.',
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
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _t(
                          settings,
                          'Save changes',
                          'Enregistrer les modifications',
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
