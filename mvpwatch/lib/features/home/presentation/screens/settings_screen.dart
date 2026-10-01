import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Resolve adaptive colors from the active theme
    final surfaceColor = isDark ? AppColors.surface : AppLightColors.surface;
    final textPrimary = isDark ? AppColors.textPrimary : AppLightColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppLightColors.textSecondary;
    final accentColor = isDark ? AppColors.primary : AppLightColors.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          final isSystemMode = themeMode == ThemeMode.system;
          final isDarkMode = themeMode == ThemeMode.dark;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // ── Section: Appearance ───────────────────────────────────────
              _SectionHeader(label: 'Appearance', textColor: accentColor),
              const SizedBox(height: 12),

              // Dark / Light toggle tile
              _SettingsTile(
                surfaceColor: surfaceColor,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: SwitchListTile.adaptive(
                    key: ValueKey(isDarkMode),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    secondary: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: accentColor,
                      ),
                    ),
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      isDarkMode ? 'Cosmic dark enabled' : 'Light mode active',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                    value: isDarkMode,
                    activeColor: accentColor,
                    onChanged: isSystemMode
                        ? null
                        : (val) {
                            context.read<ThemeCubit>().setTheme(
                                  val ? ThemeMode.dark : ThemeMode.light,
                                );
                          },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // System Default toggle tile
              _SettingsTile(
                surfaceColor: surfaceColor,
                child: SwitchListTile.adaptive(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.phone_android_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  title: Text(
                    'Use System Default',
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    'Follows your device light/dark setting',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                  value: isSystemMode,
                  activeColor: AppColors.secondary,
                  onChanged: (val) {
                    if (val) {
                      context.read<ThemeCubit>().setTheme(ThemeMode.system);
                    } else {
                      // Revert to dark when turning off system mode
                      context.read<ThemeCubit>().setTheme(ThemeMode.dark);
                    }
                  },
                ),
              ),

              const SizedBox(height: 28),

              // ── Section: Account ─────────────────────────────────────────
              _SectionHeader(label: 'Account', textColor: accentColor),
              const SizedBox(height: 12),

              _SettingsTile(
                surfaceColor: surfaceColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.person_rounded, color: accentColor),
                  ),
                  title: Text(
                    'View Profile',
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    'Edit personal details and health metrics',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: textSecondary,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // ── App Version ───────────────────────────────────────────────
              Center(
                child: Text(
                  'Flex Beat v1.0.0 · Powered by Wormhole.ai',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color textColor;

  const _SectionHeader({required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final Widget child;
  final Color surfaceColor;

  const _SettingsTile({required this.child, required this.surfaceColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
