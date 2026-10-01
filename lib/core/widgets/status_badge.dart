import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../features/vehicles/domain/vehicle.dart';

class StatusBadge extends StatelessWidget {
  final VehicleStatus status;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case VehicleStatus.available:
        bg = AppColors.statusAvailableBg;
        fg = AppColors.statusAvailable;
        icon = Icons.check_circle_rounded;
        break;
      case VehicleStatus.reserved:
        bg = AppColors.statusReservedBg;
        fg = AppColors.statusReserved;
        icon = Icons.hourglass_top_rounded;
        break;
      case VehicleStatus.sold:
        bg = AppColors.statusSoldBg;
        fg = AppColors.statusSold;
        icon = Icons.lock_rounded;
        break;
      case VehicleStatus.draft:
        bg = AppColors.statusDraftBg;
        fg = AppColors.statusDraft;
        icon = Icons.edit_note_rounded;
        break;
      case VehicleStatus.expired:
        bg = AppColors.statusExpiredBg;
        fg = AppColors.statusExpired;
        icon = Icons.timer_off_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 11,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.25), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 12 : 14, color: fg),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: fg,
              fontSize: isCompact ? 10.5 : 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class VerifiedDealerBadge extends StatelessWidget {
  const VerifiedDealerBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.verifiedBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.verified.withValues(alpha: 0.2), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 12, color: AppColors.verified),
          SizedBox(width: 3.5),
          Text(
            'VERIFIED',
            style: TextStyle(
              color: AppColors.verified,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

