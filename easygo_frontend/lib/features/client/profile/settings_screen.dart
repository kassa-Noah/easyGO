import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/settings/app_settings_controller.dart';
import '../../../../core/settings/app_settings_scope.dart';
import '../../../../shared/widgets/glass_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppSettingsController settings = AppSettingsScope.of(context);

    final AppLocalizations l10n = AppLocalizations.of(context);

    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: _backgroundGradient(context)),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            children: [
              _buildTopBar(context, l10n),

              const SizedBox(height: 24),

              Text(
                l10n.settings,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(l10n.settingsDescription, style: theme.textTheme.bodyMedium),

              const SizedBox(height: 26),

              _buildAppearanceSection(context, settings, l10n),

              const SizedBox(height: 20),

              _buildLanguageSection(context, settings, l10n),

              const SizedBox(height: 20),

              _buildInformationCard(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _backgroundGradient(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF09111F), Color(0xFF0D1B2A), Color(0xFF10253B)],
      );
    }

    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF2F8FF), Color(0xFFF7FBFF), Color(0xFFF1FFF6)],
    );
  }

  Widget _buildTopBar(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),

        const Spacer(),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(width: 6),

              Text(
                l10n.preferences,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    AppSettingsController settings,
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.palette_outlined,
            title: l10n.appearance,
            subtitle: l10n.appearanceDescription,
          ),

          const SizedBox(height: 18),

          _ThemeOption(
            icon: Icons.settings_suggest_outlined,
            title: l10n.system,
            subtitle: l10n.systemDescription,
            selected: settings.themeMode == ThemeMode.system,
            onTap: () {
              settings.setThemeMode(ThemeMode.system);
            },
          ),

          const SizedBox(height: 10),

          _ThemeOption(
            icon: Icons.light_mode_outlined,
            title: l10n.light,
            subtitle: l10n.lightDescription,
            selected: settings.themeMode == ThemeMode.light,
            onTap: () {
              settings.setThemeMode(ThemeMode.light);
            },
          ),

          const SizedBox(height: 10),

          _ThemeOption(
            icon: Icons.dark_mode_outlined,
            title: l10n.dark,
            subtitle: l10n.darkDescription,
            selected: settings.themeMode == ThemeMode.dark,
            onTap: () {
              settings.setThemeMode(ThemeMode.dark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    AppSettingsController settings,
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.language_outlined,
            title: l10n.language,
            subtitle: l10n.languageDescription,
          ),

          const SizedBox(height: 18),

          _LanguageOption(
            code: 'EN',
            title: l10n.english,
            selected: settings.language == AppLanguage.english,
            onTap: () {
              settings.setLanguage(AppLanguage.english);
            },
          ),

          const SizedBox(height: 10),

          _LanguageOption(
            code: 'FR',
            title: l10n.french,
            selected: settings.language == AppLanguage.french,
            onTap: () {
              settings.setLanguage(AppLanguage.french);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              l10n.settingsInformation,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: selected ? primary.withValues(alpha: 0.10) : Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? primary : Theme.of(context).dividerColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: selected
                    ? Icon(
                        Icons.check_circle,
                        key: ValueKey(title),
                        color: primary,
                      )
                    : const SizedBox(width: 24, height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String code;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.code,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: selected ? primary.withValues(alpha: 0.10) : Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? primary : Theme.of(context).dividerColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              if (selected) Icon(Icons.check_circle, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}
