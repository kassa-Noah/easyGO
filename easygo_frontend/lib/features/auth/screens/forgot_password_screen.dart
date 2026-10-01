import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// There is no self-service reset: the backend has no reset endpoint, so no
  /// mail is sent. This used to answer "Password reset request is valid.", which
  /// told somebody locked out of their account to wait for a message that was
  /// never going to arrive. The screen now says what is true and keeps the
  /// address on screen so it can be quoted to whoever resets the password.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String email = _emailController.text.trim();

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.info_outline),
        title: const Text('No reset email will be sent'),
        content: Text(
          'easyGO has no self-service password reset, so nothing has been sent '
          'to $email and no reset link is on its way.\n\n'
          'A platform administrator can set a new password on the account. Give '
          'them that email address so they can find the right account.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Read from the theme: the auth screens are the first thing anyone sees,
    // and they used to be hardcoded light.
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.lock_reset_outlined,
                    size: 32,
                    color: colors.primary,
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'Forgot your password?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Enter the email address linked to your easyGO account. A platform '
                  'administrator uses it to find the account and set a new password.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'easyGO cannot reset a password for you yet, so no reset '
                          'email is sent from this screen.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email address.';
                    }

                    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid email address.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: () {
                    _submit();
                  },
                  child: const Text(
                    'I cannot sign in',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 18),

                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
