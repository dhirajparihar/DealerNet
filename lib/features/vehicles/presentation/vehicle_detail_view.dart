import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/url_helper.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/vehicles_provider.dart';
import 'report_dialog.dart';

class VehicleDetailView extends ConsumerStatefulWidget {
  final String vehicleId;

  const VehicleDetailView({super.key, required this.vehicleId});

  @override
  ConsumerState<VehicleDetailView> createState() => _VehicleDetailViewState();
}

class _VehicleDetailViewState extends ConsumerState<VehicleDetailView> {
  int _activePhotoIndex = 0;
  bool _interestSent = false;

  @override
  Widget build(BuildContext context) {
    final allVehicles = ref.watch(vehiclesProvider);
    final vehicle = allVehicles.firstWhere(
      (v) => v.id == widget.vehicleId,
      orElse: () => allVehicles.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(vehicle.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined, size: 22),
            tooltip: 'Report Listing',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ReportDialog(vehicleId: vehicle.id),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 22),
            tooltip: 'Share Listing',
            onPressed: () {
              UrlHelper.openWhatsApp(
                phoneNumber: '',
                message:
                    'Check out this ${vehicle.title} on DealerNet Indore!\nAsking Price: ${CurrencyFormatter.formatCompact(vehicle.priceRupees)}\nSpecs: ${vehicle.fuelType} • ${vehicle.transmission} • ${CurrencyFormatter.formatKm(vehicle.km)}\nLocation: ${vehicle.area}, Indore',
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Gallery Carousel with Glass Indicators
            Stack(
              children: [
                SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: PageView.builder(
                    itemCount: vehicle.photos.length,
                    onPageChanged: (idx) => setState(() => _activePhotoIndex = idx),
                    itemBuilder: (context, index) {
                      return Image.network(
                        vehicle.photos[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.surfaceMuted,
                          child: const Center(
                            child: Icon(Icons.directions_car_rounded, size: 64, color: AppColors.textMuted),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Gradient Scrim Overlay for Contrast
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Status Badge Top Left
                Positioned(
                  top: 14,
                  left: 14,
                  child: StatusBadge(status: vehicle.status),
                ),
                // Freshness Tag Top Right
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 14, color: Colors.amberAccent),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatFreshness(vehicle.lastAvailabilityConfirmedAt),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Indicator dots
                if (vehicle.photos.length > 1)
                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        vehicle.photos.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _activePhotoIndex == index ? 20 : 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _activePhotoIndex == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Asking Price Hero Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'B2B DEALER ASKING PRICE',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textMuted,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  CurrencyFormatter.formatCompact(vehicle.priceRupees),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                CurrencyFormatter.formatRupees(vehicle.priceRupees),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 12),
                        // Freshness & Listing info
                        Row(
                          children: [
                            const Icon(Icons.bolt_rounded, color: Colors.amber, size: 18),
                            const SizedBox(width: 5),
                            Text(
                              DateFormatter.formatFreshness(vehicle.lastAvailabilityConfirmedAt),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Listed ${DateFormatter.formatListedDate(vehicle.publishedAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Vehicle Specifications Overview
                  const Text(
                    'Vehicle Specifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.4,
                    children: [
                      _buildSpecItem(Icons.calendar_today_outlined, 'Year Model', '${vehicle.year} Model'),
                      _buildSpecItem(Icons.speed_rounded, 'Odometer', CurrencyFormatter.formatKm(vehicle.km)),
                      _buildSpecItem(Icons.local_gas_station_outlined, 'Fuel Type', vehicle.fuelType),
                      _buildSpecItem(Icons.settings_outlined, 'Transmission', vehicle.transmission),
                      _buildSpecItem(Icons.person_outline_rounded, 'Ownership', '${vehicle.ownerCount} Owner'),
                      _buildSpecItem(Icons.app_registration_rounded, 'Registration', vehicle.registrationState),
                      _buildSpecItem(Icons.palette_outlined, 'Colour', vehicle.colour),
                      _buildSpecItem(Icons.shield_outlined, 'Insurance', vehicle.insuranceStatus),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Condition & Record Verification Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified_user_outlined, size: 20, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Condition & Inspection Record',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow('Service History', vehicle.serviceHistory),
                        const Divider(height: 20, color: AppColors.border),
                        _buildDetailRow('Accident Check', vehicle.accidentCondition),
                        if (vehicle.notes.isNotEmpty) ...[
                          const Divider(height: 20, color: AppColors.border),
                          _buildDetailRow('Dealer Notes', vehicle.notes),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dealer Information Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A09090B),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      vehicle.dealerName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (vehicle.dealerVerified) ...[
                                    const SizedBox(width: 6),
                                    const VerifiedDealerBadge(),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${vehicle.area}, ${vehicle.city}',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      // Sticky Bottom Contact Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Interest Toggle Heart Button
              IconButton(
                onPressed: () {
                  setState(() => _interestSent = !_interestSent);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_interestSent
                          ? '❤️ Interest saved! ${vehicle.dealerName} notified.'
                          : 'Removed from saved vehicles.'),
                    ),
                  );
                },
                icon: Icon(
                  _interestSent ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _interestSent ? Colors.red : AppColors.textSecondary,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceMuted,
                  minimumSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
              const SizedBox(width: 10),
              // WhatsApp CTA Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    UrlHelper.openWhatsApp(
                      phoneNumber: vehicle.dealerWhatsapp,
                      message:
                          'Hi ${vehicle.dealerName}, I am interested in your ${vehicle.title} listed on DealerNet Indore for ${CurrencyFormatter.formatCompact(vehicle.priceRupees)}. Is it available for deal?',
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF15803D), size: 18),
                  label: const Text(
                    'WhatsApp',
                    style: TextStyle(
                      color: Color(0xFF15803D),
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.whatsappBorder, width: 1.0),
                    backgroundColor: AppColors.whatsappBg,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Call Dealer Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => UrlHelper.makePhoneCall(vehicle.dealerPhone),
                  icon: const Icon(Icons.call_rounded, color: AppColors.textOnPrimary, size: 18),
                  label: const Text(
                    'Call Dealer',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textOnPrimary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.phoneCall,
                    foregroundColor: AppColors.textOnPrimary,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary, height: 1.4, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

