import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../features/vehicles/domain/vehicle.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../utils/url_helper.dart';
import 'status_badge.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;
  final bool isOwnerView;
  final VoidCallback? onStatusChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onConfirmFreshness;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
    this.isOwnerView = false,
    this.onStatusChanged,
    this.onEdit,
    this.onConfirmFreshness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primary.withValues(alpha: 0.05),
          highlightColor: AppColors.primary.withValues(alpha: 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Image Container with Overlay Badges
              Stack(
                children: [
                  Container(
                    height: 195,
                    width: double.infinity,
                    color: AppColors.surfaceMuted,
                    child: vehicle.photos.isNotEmpty
                        ? Image.network(
                            vehicle.photos.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),
                  ),
                  // Subtle Bottom Shadow Gradient over photo
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.25),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Top Left: Status Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: StatusBadge(status: vehicle.status),
                  ),

                  // Top Right: Freshness indicator badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt_rounded, size: 13, color: Colors.amberAccent),
                          const SizedBox(width: 3.5),
                          Text(
                            DateFormatter.formatFreshness(vehicle.lastAvailabilityConfirmedAt),
                            style: const TextStyle(
                              color: AppColors.textOnPrimary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Photo count pill
                  if (vehicle.photos.length > 1)
                    Positioned(
                      bottom: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_outlined, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${vehicle.photos.length}',
                              style: const TextStyle(
                                color: AppColors.textOnPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Card Body
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Compact Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            vehicle.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.25,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.formatCompact(vehicle.priceRupees),
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              CurrencyFormatter.formatRupees(vehicle.priceRupees),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Key Spec Pills (KM, Fuel, Transmission, Owners)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildSpecChip(Icons.speed_rounded, CurrencyFormatter.formatKm(vehicle.km)),
                        _buildSpecChip(Icons.local_gas_station_rounded, vehicle.fuelType),
                        _buildSpecChip(Icons.settings_rounded, vehicle.transmission),
                        _buildSpecChip(Icons.person_outline_rounded, '${vehicle.ownerCount} Owner'),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Location and Dealer line
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${vehicle.area}, ${vehicle.city}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Dealer name with verification badge
                    Row(
                      children: [
                        const Icon(Icons.storefront_rounded, size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.dealerName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (vehicle.dealerVerified) ...[
                          const SizedBox(width: 6),
                          const VerifiedDealerBadge(),
                        ],
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 12),

                    // Action Buttons (Public Marketplace View vs Dealer Inventory View)
                    if (!isOwnerView)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                UrlHelper.openWhatsApp(
                                  phoneNumber: vehicle.dealerWhatsapp,
                                  message:
                                      'Hi ${vehicle.dealerName}, I am contacting you from DealerNet Indore regarding your ${vehicle.title} (Price: ${CurrencyFormatter.formatCompact(vehicle.priceRupees)}). Is it still available?',
                                );
                              },
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF15803D)),
                              label: const Text(
                                'WhatsApp',
                                style: TextStyle(
                                  color: Color(0xFF15803D),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.whatsappBorder, width: 1.2),
                                backgroundColor: AppColors.whatsappBg,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => UrlHelper.makePhoneCall(vehicle.dealerPhone),
                              icon: const Icon(Icons.call_rounded, size: 16, color: Colors.white),
                              label: const Text(
                                'Call Dealer',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.phoneCall,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      // Owner View Stock Management Controls
                      Row(
                        children: [
                          if (vehicle.status == VehicleStatus.available) ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onConfirmFreshness,
                                icon: const Icon(Icons.bolt_rounded, size: 16, color: Colors.amber),
                                label: const Text('Confirm Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onStatusChanged,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text('Change Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined, size: 19),
                            tooltip: 'Edit Listing',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceMuted,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_rounded, size: 48, color: AppColors.textMuted.withValues(alpha: 0.6)),
          const SizedBox(height: 4),
          Text(
            vehicle.make,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

