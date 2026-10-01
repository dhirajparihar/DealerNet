import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/vehicle_card.dart';
import '../data/vehicles_provider.dart';
import '../domain/vehicle.dart';

class MyStockView extends ConsumerStatefulWidget {
  const MyStockView({super.key});

  @override
  ConsumerState<MyStockView> createState() => _MyStockViewState();
}

class _MyStockViewState extends ConsumerState<MyStockView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showStatusChangeSheet(Vehicle vehicle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Text(
                    'Change Status: ${vehicle.title}',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                ),
                const Divider(color: AppColors.border),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.statusAvailableBg, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.check_circle_rounded, color: AppColors.statusAvailable, size: 20),
                  ),
                  title: const Text('Mark Available (In Stock)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  subtitle: const Text('Visible to all 30+ Indore dealers in search', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    ref.read(vehiclesProvider.notifier).updateStatus(vehicle.id, VehicleStatus.available);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${vehicle.title} marked as Available.')),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.statusReservedBg, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.hourglass_top_rounded, color: AppColors.statusReserved, size: 20),
                  ),
                  title: const Text('Mark Reserved (Token Received)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  subtitle: const Text('Shows as booked / token taken', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    ref.read(vehiclesProvider.notifier).updateStatus(vehicle.id, VehicleStatus.reserved);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${vehicle.title} marked as Reserved.')),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.statusSoldBg, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.lock_rounded, color: AppColors.statusSold, size: 20),
                  ),
                  title: const Text('Mark Sold', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  subtitle: const Text('Archived from active marketplace', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    ref.read(vehiclesProvider.notifier).updateStatus(vehicle.id, VehicleStatus.sold);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${vehicle.title} marked as Sold.')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final myStock = ref.watch(myStockProvider);

    final activeVehicles = myStock.where((v) => v.status == VehicleStatus.available).toList();
    final reservedVehicles = myStock.where((v) => v.status == VehicleStatus.reserved).toList();
    final soldVehicles = myStock.where((v) => v.status == VehicleStatus.sold).toList();
    final draftVehicles = myStock.where((v) => v.status == VehicleStatus.draft || v.status == VehicleStatus.expired).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: [
              Tab(text: 'Active (${activeVehicles.length})'),
              Tab(text: 'Reserved (${reservedVehicles.length})'),
              Tab(text: 'Sold (${soldVehicles.length})'),
              Tab(text: 'Draft (${draftVehicles.length})'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStockList(activeVehicles, 'active'),
          _buildStockList(reservedVehicles, 'reserved'),
          _buildStockList(soldVehicles, 'sold'),
          _buildStockList(draftVehicles, 'draft'),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accent, AppColors.accentHover],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/vehicle/add'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.add_rounded, color: AppColors.textOnPrimary, size: 22),
          label: const Text('Add Vehicle', style: TextStyle(color: AppColors.textOnPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildStockList(List<Vehicle> list, String type) {
    if (list.isEmpty) {
      return EmptyState(
        icon: Icons.directions_car_filled_outlined,
        title: type == 'active' ? 'No active inventory listed.' : 'No $type vehicles.',
        subtitle: type == 'active'
            ? 'Publish your first car to get direct buyer calls & WhatsApp enquiries.'
            : null,
        actionLabel: type == 'active' ? 'Add your first vehicle' : null,
        onAction: type == 'active' ? () => context.push('/vehicle/add') : null,
      );
    }

    return Column(
      children: [
        if (type == 'active')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.statusAvailableBg,
              border: Border(bottom: BorderSide(color: Color(0xFFBBF7D0), width: 1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: AppColors.statusAvailable, size: 19),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Keep your stock fresh for Indore dealers',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    for (final v in list) {
                      ref.read(vehiclesProvider.notifier).confirmAvailability(v.id);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Freshness confirmed for all active vehicles.')),
                    );
                  },
                  icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.statusAvailable),
                  label: const Text(
                    'Confirm All Available',
                    style: TextStyle(color: AppColors.statusAvailable, fontWeight: FontWeight.w900, fontSize: 11.5),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final vehicle = list[index];
              return VehicleCard(
                vehicle: vehicle,
                isOwnerView: true,
                onTap: () => context.push('/vehicle/${vehicle.id}'),
                onStatusChanged: () => _showStatusChangeSheet(vehicle),
                onConfirmFreshness: () {
                  ref.read(vehiclesProvider.notifier).confirmAvailability(vehicle.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Freshness confirmed for ${vehicle.title}.')),
                  );
                },
                onEdit: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Editing details mode...')),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

