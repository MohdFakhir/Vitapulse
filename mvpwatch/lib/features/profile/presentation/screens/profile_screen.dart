import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/profile_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ClinicalColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Confirm Logout',
            style: TextStyle(
              color: ClinicalColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of your health monitoring dashboard?',
            style: TextStyle(color: ClinicalColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: ClinicalColors.textTertiary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ClinicalColors.heart,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(LogoutEvent());
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: ClinicalColors.background,
        appBar: AppBar(
          backgroundColor: ClinicalColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: ClinicalColors.textPrimary),
          title: const Text(
            'Biometric Profile',
            style: TextStyle(
              color: ClinicalColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(
                child: CircularProgressIndicator(color: ClinicalColors.heart),
              );
            } else if (state is ProfileError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: ClinicalColors.heart),
                ),
              );
            } else if (state is ProfileLoaded) {
              final user = state.user;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ClinicalColors.surface,
                            border: Border.all(
                              color: ClinicalColors.heart.withValues(alpha: 0.3),
                              width: 3,
                            ),
                            boxShadow: ClinicalColors.cardShadow,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 52,
                              color: ClinicalColors.heart,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: ClinicalColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: ClinicalColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Info Cards
                        _buildInfoCard(
                          context,
                          'Personal Details',
                          [
                            _buildInfoRow('Age', '${user.age} years'),
                            _buildInfoRow(
                              'DOB',
                              DateFormat('MMM dd, yyyy').format(user.dateOfBirth),
                            ),
                            if (user.gender != null)
                              _buildInfoRow('Gender', user.gender!),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildInfoCard(
                          context,
                          'Physical Metrics',
                          [
                            _buildInfoRow('Weight', '${user.weight} kg'),
                            _buildInfoRow('Height', '${user.height} cm'),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildInfoCard(
                          context,
                          'Clinical Health Targets',
                          [
                            _buildInfoRow(
                              'Water Intake Target',
                              '${user.waterGoal} L / day',
                            ),
                          ],
                        ),

                        const SizedBox(height: 36),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showLogoutDialog(context),
                            icon: const Icon(Icons.logout, color: ClinicalColors.heart),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                color: ClinicalColors.heart,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(
                                color: ClinicalColors.heart,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ClinicalColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ClinicalColors.border),
        boxShadow: ClinicalColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ClinicalColors.heart,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: ClinicalColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: ClinicalColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
