import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/widgets/vehicle_card.dart';
import '../../vehicles/data/vehicles_provider.dart';
import '../../wanted/data/wanted_provider.dart';
import '../../vehicles/domain/vehicle.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'SUV', 'Sedan', 'Hatchback', 'Luxury'];

  @override
  Widget build(BuildContext context) {
    final myStock = ref.watch(myStockProvider);
    final myActiveCount = myStock.where((v) => v.status == VehicleStatus.available).length;
    final allVehicles = ref.watch(vehiclesProvider);
    final availableVehicles = allVehicles.where((v) => v.status == VehicleStatus.available).toList();
    final wantedRequests = ref.watch(wantedProvider);

    // Filter available vehicles by quick category chip if selected
    final displayedVehicles = _selectedCategory == 'All'
        ? availableVehicles
        : availableVehicles.where((v) {
            final titleLower = v.title.toLowerCase();
            if (_selectedCategory == 'SUV') return titleLower.contains('creta') || titleLower.contains('thar') || titleLower.contains('harrier') || titleLower.contains('scorpio') || titleLower.contains('brezza');
            if (_selectedCategory == 'Sedan') return titleLower.contains('city') || titleLower.contains('verna') || titleLower.contains('dzire') || titleLower.contains('ciaz');
            if (_selectedCategory == 'Hatchback') return titleLower.contains('swift') || titleLower.contains('i20') || titleLower.contains('baleno') || titleLower.contains('kwid');
            if (_selectedCategory == 'Luxury') return titleLower.contains('bmw') || titleLower.contains('audi') || titleLower.contains('mercedes') || titleLower.contains('jaguar');
            return true;
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Editorial Search Banner
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2009090B),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.hub_rounded, color: Colors.amberAccent, size: 14),
                                  SizedBox(width: 5),
                                  Text(
                                    'INDORE B2B EXCHANGE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.statusAvailableBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.statusAvailable,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${availableVehicles.length} Live',
                                style: const TextStyle(
                                  color: AppColors.statusAvailable,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Source Verified Cars Across 30+ Indore Dealerships',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Search Bar Input Trigger
                    InkWell(
                      onTap: () => context.go('/search'),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Search Creta, Swift, Thar, under ₹12 Lakh...',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              child: Icon(Icons.tune_rounded, size: 16, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Quick Action CTAs
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.accentHover],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/vehicle/add'),
                        icon: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
                        label: const Text(
                          'Add Vehicle',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/wanted/add'),
                      icon: const Icon(Icons.campaign_outlined, size: 19, color: AppColors.primary),
                      label: const Text(
                        'Post Wanted',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Network Summary KPIs Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'My Stock',
                      count: '$myActiveCount',
                      subtitle: 'Active live',
                      color: AppColors.statusAvailable,
                      icon: Icons.inventory_2_outlined,
                      onTap: () => context.go('/my-stock'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Indore Market',
                      count: '${availableVehicles.length}',
                      subtitle: 'Available cars',
                      color: AppColors.verified,
                      icon: Icons.directions_car_outlined,
                      onTap: () => context.go('/search'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Wanted',
                      count: '${wantedRequests.length}',
                      subtitle: 'Dealer leads',
                      color: AppColors.goldAccent,
                      icon: Icons.campaign_outlined,
                      onTap: () => context.go('/wanted'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Filter Category Chips + Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recently Added in Indore',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/search'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View All', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary)),
                        SizedBox(width: 2),
                        Icon(Icons.arrow_forward_rounded, size: 15, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Filter category pill bar
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedCategory = category);
                        },
                        selectedColor: AppColors.primary,
                        checkmarkColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 12.5,
                        ),
                        backgroundColor: AppColors.surface,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // List of available cars
              displayedVehicles.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(30),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 40, color: AppColors.textMuted),
                          SizedBox(height: 8),
                          Text('No vehicles match this category', style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedVehicles.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final vehicle = displayedVehicles[index];
                        return VehicleCard(
                          vehicle: vehicle,
                          onTap: () => context.push('/vehicle/${vehicle.id}'),
                        );
                      },
                    ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Icon(icon, size: 18, color: color.withValues(alpha: 0.7)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
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

