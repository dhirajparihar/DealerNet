import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/vehicle.dart';
import 'mock_data.dart';
import 'supabase_vehicle_repository.dart';
import '../../auth/data/auth_repository.dart';

enum SortOption {
  newest,
  confirmed,
  priceLowToHigh,
  priceHighToLow,
  kmLowToHigh,
}

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.newest:
        return 'Newest First';
      case SortOption.confirmed:
        return 'Recently Confirmed';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.kmLowToHigh:
        return 'KM: Low to High';
    }
  }
}

class VehicleFilterState {
  final String query;
  final Set<String> selectedMakes;
  final Set<String> selectedFuelTypes;
  final Set<String> selectedTransmissions;
  final double maxPrice;
  final double maxKm;
  final int minYear;
  final SortOption sortOption;

  const VehicleFilterState({
    this.query = '',
    this.selectedMakes = const {},
    this.selectedFuelTypes = const {},
    this.selectedTransmissions = const {},
    this.maxPrice = 3500000,
    this.maxKm = 120000,
    this.minYear = 2016,
    this.sortOption = SortOption.newest,
  });

  bool get hasActiveFilters =>
      query.isNotEmpty ||
      selectedMakes.isNotEmpty ||
      selectedFuelTypes.isNotEmpty ||
      selectedTransmissions.isNotEmpty ||
      maxPrice < 3500000 ||
      maxKm < 120000 ||
      minYear > 2016;

  VehicleFilterState copyWith({
    String? query,
    Set<String>? selectedMakes,
    Set<String>? selectedFuelTypes,
    Set<String>? selectedTransmissions,
    double? maxPrice,
    double? maxKm,
    int? minYear,
    SortOption? sortOption,
  }) {
    return VehicleFilterState(
      query: query ?? this.query,
      selectedMakes: selectedMakes ?? this.selectedMakes,
      selectedFuelTypes: selectedFuelTypes ?? this.selectedFuelTypes,
      selectedTransmissions: selectedTransmissions ?? this.selectedTransmissions,
      maxPrice: maxPrice ?? this.maxPrice,
      maxKm: maxKm ?? this.maxKm,
      minYear: minYear ?? this.minYear,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  VehicleFilterState reset() {
    return const VehicleFilterState();
  }
}

class VehiclesNotifier extends StateNotifier<List<Vehicle>> {
  final SupabaseVehicleRepository _supabaseRepo = SupabaseVehicleRepository();

  VehiclesNotifier() : super(MockData.getInitialVehicles()) {
    _loadFromSupabaseIfAvailable();
  }

  void _loadFromSupabaseIfAvailable() async {
    if (_supabaseRepo.isConnected) {
      final remoteList = await _supabaseRepo.fetchVehicles();
      if (remoteList != null && remoteList.isNotEmpty) {
        state = remoteList;
      }
    }
  }

  void addVehicle(Vehicle vehicle) {
    state = [vehicle, ...state];
    if (_supabaseRepo.isConnected) {
      _supabaseRepo.insertVehicle(vehicle);
    }
  }

  void updateVehicle(Vehicle updated) {
    state = [
      for (final v in state)
        if (v.id == updated.id) updated else v,
    ];
  }

  void updateStatus(String vehicleId, VehicleStatus newStatus) {
    state = [
      for (final v in state)
        if (v.id == vehicleId)
          v.copyWith(
            status: newStatus,
            lastAvailabilityConfirmedAt: DateTime.now(),
          )
        else
          v,
    ];
    if (_supabaseRepo.isConnected) {
      _supabaseRepo.updateStatus(vehicleId, newStatus);
    }
  }

  void confirmAvailability(String vehicleId) {
    state = [
      for (final v in state)
        if (v.id == vehicleId)
          v.copyWith(lastAvailabilityConfirmedAt: DateTime.now())
        else
          v,
    ];
    if (_supabaseRepo.isConnected) {
      _supabaseRepo.updateStatus(vehicleId, VehicleStatus.available);
    }
  }

  void reportVehicle(String vehicleId, String reason, String? notes) {
    // In real app, persist report to Supabase vehicle_reports
  }
}

final vehiclesProvider =
    StateNotifierProvider<VehiclesNotifier, List<Vehicle>>((ref) {
  return VehiclesNotifier();
});

class FilterNotifier extends StateNotifier<VehicleFilterState> {
  FilterNotifier() : super(const VehicleFilterState());

  void setQuery(String q) => state = state.copyWith(query: q);

  void toggleMake(String make) {
    final updated = Set<String>.from(state.selectedMakes);
    if (updated.contains(make)) {
      updated.remove(make);
    } else {
      updated.add(make);
    }
    state = state.copyWith(selectedMakes: updated);
  }

  void toggleFuel(String fuel) {
    final updated = Set<String>.from(state.selectedFuelTypes);
    if (updated.contains(fuel)) {
      updated.remove(fuel);
    } else {
      updated.add(fuel);
    }
    state = state.copyWith(selectedFuelTypes: updated);
  }

  void toggleTransmission(String trans) {
    final updated = Set<String>.from(state.selectedTransmissions);
    if (updated.contains(trans)) {
      updated.remove(trans);
    } else {
      updated.add(trans);
    }
    state = state.copyWith(selectedTransmissions: updated);
  }

  void setMaxPrice(double price) => state = state.copyWith(maxPrice: price);
  void setMaxKm(double km) => state = state.copyWith(maxKm: km);
  void setMinYear(int year) => state = state.copyWith(minYear: year);
  void setSortOption(SortOption sort) => state = state.copyWith(sortOption: sort);
  void reset() => state = state.reset();
}

final vehicleFilterProvider =
    StateNotifierProvider<FilterNotifier, VehicleFilterState>((ref) {
  return FilterNotifier();
});

/// Filtered and sorted active listings for discovery
final filteredVehiclesProvider = Provider<List<Vehicle>>((ref) {
  final all = ref.watch(vehiclesProvider);
  final filter = ref.watch(vehicleFilterProvider);

  // Discovery only shows available vehicles
  var results = all.where((v) => v.status == VehicleStatus.available).toList();

  if (filter.query.isNotEmpty) {
    final q = filter.query.toLowerCase();
    results = results.where((v) {
      return v.title.toLowerCase().contains(q) ||
          v.make.toLowerCase().contains(q) ||
          v.model.toLowerCase().contains(q) ||
          v.area.toLowerCase().contains(q);
    }).toList();
  }

  if (filter.selectedMakes.isNotEmpty) {
    results = results.where((v) => filter.selectedMakes.contains(v.make)).toList();
  }

  if (filter.selectedFuelTypes.isNotEmpty) {
    results = results.where((v) => filter.selectedFuelTypes.contains(v.fuelType)).toList();
  }

  if (filter.selectedTransmissions.isNotEmpty) {
    results = results.where((v) => filter.selectedTransmissions.contains(v.transmission)).toList();
  }

  results = results.where((v) {
    return v.priceRupees <= filter.maxPrice &&
        v.km <= filter.maxKm &&
        v.year >= filter.minYear;
  }).toList();

  // Sorting
  switch (filter.sortOption) {
    case SortOption.newest:
      results.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      break;
    case SortOption.confirmed:
      results.sort((a, b) => b.lastAvailabilityConfirmedAt.compareTo(a.lastAvailabilityConfirmedAt));
      break;
    case SortOption.priceLowToHigh:
      results.sort((a, b) => a.priceRupees.compareTo(b.priceRupees));
      break;
    case SortOption.priceHighToLow:
      results.sort((a, b) => b.priceRupees.compareTo(a.priceRupees));
      break;
    case SortOption.kmLowToHigh:
      results.sort((a, b) => a.km.compareTo(b.km));
      break;
  }

  return results;
});

/// My Stock provider: filters current dealer's inventory
final myStockProvider = Provider<List<Vehicle>>((ref) {
  final all = ref.watch(vehiclesProvider);
  final dealerId = ref.watch(authProvider).currentDealer?.id ?? 'dealer-indore-01';
  return all.where((v) => v.dealerId == dealerId).toList();
});
