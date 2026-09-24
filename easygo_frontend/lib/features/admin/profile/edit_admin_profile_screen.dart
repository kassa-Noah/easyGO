import 'package:flutter/material.dart';

import '../../../core/settings/app_settings_controller.dart';
import '../../../core/settings/app_settings_scope.dart';
import '../../../shared/widgets/glass_container.dart';

class AdminProfileData {
  final String name;
  final String email;
  final String phone;

  const AdminProfileData({
    required this.name,
    required this.email,
    required this.phone,
  });
}

class EditAdminProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;

  const EditAdminProfileScreen({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhone,
  });

  @override
  State<EditAdminProfileScreen> createState() =>
      _EditAdminProfileScreenState();
}

class _EditAdminProfileScreenState
    extends State<EditAdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  String _t(
    AppSettingsController settings,
    String en,
    String fr,
  ) =>
      settings.isFrench ? fr : en;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      AdminProfileData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      ),
    );
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
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: _t(
                              settings,
                              'Full name',
                              'Nom complet',
                            ),
                            prefixIcon: const Icon(
                              Icons.person_outline,
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return _t(
                                settings,
                                'Please enter the administrator name.',
                                'Veuillez saisir le nom de l’administrateur.',
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return _t(
                                settings,
                                'Please enter an email address.',
                                'Veuillez saisir une adresse e-mail.',
                              );
                            }
                            final regex = RegExp(
                              r'^[\w\.-]+@[\w\.-]+\.\w+$',
                            );
                            if (!regex.hasMatch(value.trim())) {
                              return _t(
                                settings,
                                'Please enter a valid email address.',
                                'Veuillez saisir une adresse e-mail valide.',
                              );
                            }
                            return null;
                          },
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
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return _t(
                                settings,
                                'Please enter a phone number.',
                                'Veuillez saisir un numéro de téléphone.',
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
                              'Prototype mode: changes are kept only for the current frontend session. The backend will persist administrator information in production.',
                              'Mode prototype : les modifications sont conservées uniquement pendant la session frontend actuelle. Le backend enregistrera les informations administrateur en production.',
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
                      onPressed: _save,
                      icon: const Icon(Icons.save_outlined),
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
