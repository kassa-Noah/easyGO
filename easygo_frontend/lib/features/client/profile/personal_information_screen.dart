import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class PersonalInformationScreen
    extends StatefulWidget {
  final String initialFullName;
  final String initialEmail;
  final String initialPhone;

  const PersonalInformationScreen({
    super.key,
    required this.initialFullName,
    required this.initialEmail,
    required this.initialPhone,
  });

  @override
  State<PersonalInformationScreen>
      createState() =>
          _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController
      _fullNameController;

  late final TextEditingController
      _emailController;

  late final TextEditingController
      _phoneController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _fullNameController =
        TextEditingController(
      text: widget.initialFullName,
    );

    _emailController =
        TextEditingController(
      text: widget.initialEmail,
    );

    _phoneController =
        TextEditingController(
      text: widget.initialPhone,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  String? _validateFullName(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Full name is required.';
    }

    if (value.trim().length < 3) {
      return 'Enter a valid full name.';
    }

    return null;
  }

  String? _validateEmail(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Email address is required.';
    }

    final emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailPattern.hasMatch(
      value.trim(),
    )) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  String? _validatePhone(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Phone number is required.';
    }

    final normalized = value
        .replaceAll(' ', '')
        .replaceAll('-', '');

    if (normalized.length < 9) {
      return 'Enter a valid phone number.';
    }

    return null;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    /*
     * FRONTEND DEMONSTRATION ONLY.
     *
     * Later this will become:
     *
     * PATCH /api/users/me
     *
     * or the equivalent profile endpoint
     * implemented by the backend.
     */

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    Navigator.pop(
      context,
      {
        'fullName':
            _fullNameController.text.trim(),
        'email':
            _emailController.text.trim(),
        'phone':
            _phoneController.text.trim(),
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Personal Information',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
                const EdgeInsets.all(20),
            children: [
              _buildProfileAvatar(),

              const SizedBox(height: 28),

              const Text(
                'Account Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Keep your information accurate so that transport agencies can identify and contact you when necessary.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color:
                      AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller:
                    _fullNameController,
                textInputAction:
                    TextInputAction.next,
                validator:
                    _validateFullName,
                decoration:
                    const InputDecoration(
                  labelText: 'Full Name',
                  hintText:
                      'Enter your full name',
                  prefixIcon: Icon(
                    Icons.person_outline,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _emailController,
                keyboardType:
                    TextInputType
                        .emailAddress,
                textInputAction:
                    TextInputAction.next,
                validator: _validateEmail,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Email Address',
                  hintText:
                      'Enter your email address',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _phoneController,
                keyboardType:
                    TextInputType.phone,
                textInputAction:
                    TextInputAction.done,
                validator: _validatePhone,
                onFieldSubmitted: (_) {
                  if (!_isSaving) {
                    _saveChanges();
                  }
                },
                decoration:
                    const InputDecoration(
                  labelText:
                      'Phone Number',
                  hintText:
                      '+237 6XX XXX XXX',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              _buildSecurityNotice(),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : _saveChanges,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor:
                    AppColors.primary,
                child: Icon(
                  Icons.person,
                  size: 55,
                  color: Colors.white,
                ),
              ),

              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color:
                        AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            'Client Account',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color:
                  AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primaryLight
            .withValues(
          alpha: 0.08,
        ),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryLight
              .withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.security_outlined,
            size: 21,
            color: AppColors.primary,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Your profile information is associated with your easyGO account. Authentication and identity verification will be handled securely by the backend.',
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color:
                    AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}