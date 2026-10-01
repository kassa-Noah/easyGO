import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Read from the theme. Onboarding is the first screen a new reader sees,
    // and it used to be hardcoded light.
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // The content fills the screen when there is enough
            // room and scrolls on shorter screens so that no
            // content is clipped.
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                    child: Column(
                      children: [
                        // easyGO brand
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'easy',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                            Text(
                              'GO',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: colors.secondary,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Main illustration
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.route_rounded,
                                size: 110,
                                color: colors.primary.withValues(alpha: 0.35),
                              ),
                              Positioned(
                                top: 32,
                                right: 38,
                                child: Icon(
                                  Icons.location_on,
                                  size: 45,
                                  color: colors.secondary,
                                ),
                              ),
                              Positioned(
                                bottom: 35,
                                left: 35,
                                child: Icon(
                                  Icons.directions_bus_rounded,
                                  size: 45,
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 42),

                        Text(
                          'Your complete interurban journey',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Discover transport agencies, book your journey, '
                          'travel door-to-door and track your luggage or parcels '
                          'with ease.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: colors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Feature indicators
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _FeatureItem(
                              icon: Icons.directions_bus_outlined,
                              label: 'Travel',
                            ),
                            _FeatureItem(
                              icon: Icons.local_taxi_outlined,
                              label: 'Door-to-Door',
                            ),
                            _FeatureItem(
                              icon: Icons.luggage_outlined,
                              label: 'Track',
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Get Started
                        ElevatedButton(
                          // Login navigation will be connected
                          // in the next step.
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          AppStrings.tagline,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).dividerTheme.color!),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 27,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
