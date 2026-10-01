import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../health_log/presentation/screens/health_notes_screen.dart';
import '../../../reminders/presentation/screens/reminders_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../screens/bluetooth_scan_screen.dart';

class ClinicalQuickActions extends StatelessWidget {
  const ClinicalQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildActionTile(
          context: context,
          icon: Icons.note_alt_outlined,
          label: 'Notes',
          color: ClinicalColors.oxygen,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HealthNotesScreen()),
          ),
        ),
        const SizedBox(width: 10),
        _buildActionTile(
          context: context,
          icon: Icons.alarm_rounded,
          label: 'Reminders',
          color: ClinicalColors.sleep,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RemindersScreen()),
          ),
        ),
        const SizedBox(width: 10),
        _buildActionTile(
          context: context,
          icon: Icons.bluetooth_searching,
          label: 'Sync Watch',
          color: ClinicalColors.heart,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BluetoothScanScreen()),
          ),
        ),
        const SizedBox(width: 10),
        _buildActionTile(
          context: context,
          icon: Icons.person_outline_rounded,
          label: 'Profile',
          color: ClinicalColors.respiratory,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: ClinicalColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ClinicalColors.border),
            boxShadow: ClinicalColors.cardShadow,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ClinicalColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
