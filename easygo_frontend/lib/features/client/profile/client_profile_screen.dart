import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../auth/screens/login_screen.dart';
import '../notifications/notifications_screen.dart';
import 'help_support_screen.dart';
import 'personal_information_screen.dart';
import 'settings_screen.dart';

class ClientProfileScreen
    extends StatefulWidget {
  const ClientProfileScreen({
    super.key,
  });

  @override
  State<ClientProfileScreen> createState() =>
      _ClientProfileScreenState();
}

class _ClientProfileScreenState
    extends State<ClientProfileScreen> {
  String _fullName = 'Demo Client';
  String _email = 'client@easygo.cm';
  String _phone = '+237 6XX XXX XXX';

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const NotificationsScreen(),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SettingsScreen(),
      ),
    );
  }

  void _openHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const HelpSupportScreen(),
      ),
    );
  }

  Future<void>
      _openPersonalInformation() async {
    final result =
        await Navigator.push<
            Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PersonalInformationScreen(
          initialFullName: _fullName,
          initialEmail: _email,
          initialPhone: _phone,
        ),
      ),
    );

    if (result == null ||
        !mounted) {
      return;
    }

    setState(() {
      _fullName =
          result['fullName'] ??
              _fullName;

      _email =
          result['email'] ??
              _email;

      _phone =
          result['phone'] ??
              _phone;
    });

    final l10n =
        AppLocalizations.of(context);

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          l10n.profileUpdated,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final l10n =
        AppLocalizations.of(context);

    final bool? shouldLogout =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            l10n.logout,
          ),
          content: Text(
            l10n.logoutQuestion,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                l10n.cancel,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                l10n.logout,
                style: const TextStyle(
                  color:
                      AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true ||
        !mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _showAboutDialog() {
    final l10n =
        AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.travel_explore,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  l10n.aboutEasyGo,
                ),
              ),
            ],
          ),
          content:
              SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Text(
                  l10n.appName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Theme.of(context)
                            .colorScheme
                            .primary,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  l10n.tagline,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w500,
                    color:
                        AppColors.secondary,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                Text(
                  l10n.aboutDescription,
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                Text(
                  l10n.version,
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodySmall,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: Text(
                l10n.close,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient:
              _backgroundGradient(),
        ),
        child: SafeArea(
          child: ListView(
            padding:
                const EdgeInsets.all(
              20,
            ),
            children: [
              _buildPageTitle(
                l10n,
              ),

              const SizedBox(
                height: 18,
              ),

              _buildProfileHeader(),

              const SizedBox(
                height: 26,
              ),

              _buildSectionTitle(
                l10n.account,
              ),

              const SizedBox(
                height: 12,
              ),

              GlassContainer(
                padding:
                    EdgeInsets.zero,
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons
                          .person_outline,
                      title: l10n
                          .personalInformation,
                      subtitle: l10n
                          .personalInformationSubtitle,
                      onTap:
                          _openPersonalInformation,
                    ),

                    const _MenuDivider(),

                    _ProfileMenuItem(
                      icon: Icons
                          .notifications_outlined,
                      title: l10n
                          .notifications,
                      subtitle: l10n
                          .notificationsSubtitle,
                      onTap:
                          _openNotifications,
                    ),

                    const _MenuDivider(),

                    _ProfileMenuItem(
                      icon: Icons
                          .settings_outlined,
                      title:
                          l10n.settings,
                      subtitle: l10n
                          .settingsSubtitle,
                      onTap:
                          _openSettings,
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 26,
              ),

              _buildSectionTitle(
                l10n.support,
              ),

              const SizedBox(
                height: 12,
              ),

              GlassContainer(
                padding:
                    EdgeInsets.zero,
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons
                          .help_outline_rounded,
                      title: l10n
                          .helpSupport,
                      subtitle: l10n
                          .helpSupportSubtitle,
                      onTap:
                          _openHelpSupport,
                    ),

                    const _MenuDivider(),

                    _ProfileMenuItem(
                      icon: Icons
                          .info_outline,
                      title: l10n
                          .aboutEasyGo,
                      subtitle: l10n
                          .aboutEasyGoSubtitle,
                      onTap:
                          _showAboutDialog,
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 26,
              ),

              GlassContainer(
                padding:
                    EdgeInsets.zero,
                child:
                    _ProfileMenuItem(
                  icon: Icons.logout,
                  title:
                      l10n.logout,
                  subtitle: l10n
                      .logoutSubtitle,
                  iconColor:
                      AppColors.error,
                  titleColor:
                      AppColors.error,
                  showArrow: false,
                  onTap: _logout,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              _buildFooter(
                l10n,
              ),

              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient
      _backgroundGradient() {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF09111F),
          Color(0xFF0D1B2A),
          Color(0xFF10253B),
        ],
      );
    }

    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFF2F8FF),
        Color(0xFFF7FBFF),
        Color(0xFFF1FFF6),
      ],
    );
  }

  Widget _buildPageTitle(
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.profile,
            style:
                Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        IconButton.filledTonal(
          tooltip:
              l10n.settings,
          onPressed:
              _openSettings,
          icon: const Icon(
            Icons.settings_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    String title,
  ) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(
            fontWeight:
                FontWeight.bold,
          ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          begin: Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary
                .withValues(
              alpha: 0.20,
            ),
            blurRadius: 24,
            offset:
                const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration:
                BoxDecoration(
              color: Colors.white
                  .withValues(
                alpha: 0.18,
              ),
              shape:
                  BoxShape.circle,
              border: Border.all(
                color: Colors.white
                    .withValues(
                  alpha: 0.45,
                ),
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  _fullName,
                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  _email,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        Colors.white70,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  _phone,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    AppLocalizations l10n,
  ) {
    return Center(
      child: Column(
        children: [
          Text(
            l10n.appName,
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            l10n.tagline,
            textAlign:
                TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),

          const SizedBox(height: 5),

          Text(
            l10n.version,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;
  final bool showArrow;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
    this.showArrow = true,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final Color effectiveIconColor =
        iconColor ??
            Theme.of(context)
                .colorScheme
                .primary;

    final Color effectiveTitleColor =
        titleColor ??
            Theme.of(context)
                .colorScheme
                .onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                    BoxDecoration(
                  color:
                      effectiveIconColor
                          .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color:
                      effectiveIconColor,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight
                                .w600,
                        color:
                            effectiveTitleColor,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        color:
                            Theme.of(
                          context,
                        )
                                .colorScheme
                                .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              if (showArrow)
                Icon(
                  Icons.chevron_right,
                  color:
                      Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuDivider
    extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        left: 73,
      ),
      child: Divider(
        height: 1,
        color: Theme.of(context)
            .dividerColor,
      ),
    );
  }
}