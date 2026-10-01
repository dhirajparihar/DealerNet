import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/vehicle_card.dart';
import '../../vehicles/data/mock_data.dart';
import '../../vehicles/data/vehicles_provider.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(vehicleFilterProvider).query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _showSortModal() {
    final currentSort = ref.read(vehicleFilterProvider).sortOption;
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Text(
                    'Sort Listings By',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ),
                const Divider(color: AppColors.border),
                ...SortOption.values.map((sort) {
                  final isSelected = currentSort == sort;
                  return ListTile(
                    title: Text(
                      sort.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected ? AppColors.accent : AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 20)
                        : null,
                    onTap: () {
                      ref.read(vehicleFilterProvider.notifier).setSortOption(sort);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredVehicles = ref.watch(filteredVehiclesProvider);
    final filterState = ref.watch(vehicleFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search & Filter Header Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          ref.read(vehicleFilterProvider.notifier).setQuery(val);
                        },
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search make, model, area...',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(vehicleFilterProvider.notifier).setQuery('');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Filter Action Button
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: filterState.hasActiveFilters ? AppColors.primary : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: filterState.hasActiveFilters ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune_rounded,
                          color: filterState.hasActiveFilters ? Colors.white : AppColors.primary,
                          size: 22,
                        ),
                        tooltip: 'Filter Options',
                        onPressed: _showFilterModal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Make & Sort Filter Quick Chips
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.sort_rounded, size: 16, color: AppColors.primary),
                        label: Text(filterState.sortOption.label),
                        onPressed: _showSortModal,
                        backgroundColor: AppColors.surfaceContainerLow,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      ...MockData.makes.take(7).map((make) {
                        final isSelected = filterState.selectedMakes.contains(make);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: FilterChip(
                            label: Text(make),
                            selected: isSelected,
                            onSelected: (_) {
                              ref.read(vehicleFilterProvider.notifier).toggleMake(make);
                            },
                            selectedColor: AppColors.primary,
                            checkmarkColor: AppColors.textOnPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 12,
                            ),
                            backgroundColor: AppColors.surfaceContainerLow,
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Result Counter & Filter Clear Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
            ),
            child: Row(
              children: [
                Text(
                  '${filteredVehicles.length} Vehicles Available',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
                if (filterState.hasActiveFilters)
                  TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      ref.read(vehicleFilterProvider.notifier).reset();
                    },
                    icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.accent),
                    label: const Text(
                      'Clear Filters',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.accent.withValues(alpha: 0.3), width: 1.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Results Stream
          Expanded(
            child: filteredVehicles.isEmpty
                ? EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No vehicles match these criteria.',
                    subtitle: 'Try adjusting your budget, fuel type, or clear active filters.',
                    actionLabel: 'Reset All Filters',
                    onAction: () {
                      _searchController.clear();
                      ref.read(vehicleFilterProvider.notifier).reset();
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    itemCount: filteredVehicles.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final vehicle = filteredVehicles[index];
                      return VehicleCard(
                        vehicle: vehicle,
                        onTap: () => context.push('/vehicle/${vehicle.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(vehicleFilterProvider);
    final filterNotifier = ref.read(vehicleFilterProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Sheet Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Inventory',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () => filterNotifier.reset(),
                  child: const Text('Reset All', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Scrollable Filter Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Fuel Type Pills
                const Text('Fuel Type', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MockData.fuelTypes.map((fuel) {
                    final isSelected = filterState.selectedFuelTypes.contains(fuel);
                    return FilterChip(
                      label: Text(fuel),
                      selected: isSelected,
                      onSelected: (_) => filterNotifier.toggleFuel(fuel),
                      selectedColor: AppColors.primary,
                      checkmarkColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Transmission Pills
                const Text('Transmission', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: MockData.transmissions.map((trans) {
                    final isSelected = filterState.selectedTransmissions.contains(trans);
                    return FilterChip(
                      label: Text(trans),
                      selected: isSelected,
                      onSelected: (_) => filterNotifier.toggleTransmission(trans),
                      selectedColor: AppColors.primary,
                      checkmarkColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Max Budget Slider Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Max Asking Price', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                          Text(
                            CurrencyFormatter.formatCompact(filterState.maxPrice),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                          ),
                        ],
                      ),
                      Slider(
                        value: filterState.maxPrice,
                        min: 300000,
                        max: 5000000,
                        divisions: 47,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.border,
                        onChanged: (val) => filterNotifier.setMaxPrice(val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Max Kilometers Slider Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Max Kilometers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                          Text(
                            CurrencyFormatter.formatKm(filterState.maxKm.toInt()),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                          ),
                        ],
                      ),
                      Slider(
                        value: filterState.maxKm,
                        min: 10000,
                        max: 150000,
                        divisions: 14,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.border,
                        onChanged: (val) => filterNotifier.setMaxKm(val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Minimum Year Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Minimum Registration Year', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                          Text(
                            '${filterState.minYear}+',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                          ),
                        ],
                      ),
                      Slider(
                        value: filterState.minYear.toDouble(),
                        min: 2012,
                        max: 2024,
                        divisions: 12,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.border,
                        onChanged: (val) => filterNotifier.setMinYear(val.toInt()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Apply CTA
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56), // match 8px grid app button height
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

