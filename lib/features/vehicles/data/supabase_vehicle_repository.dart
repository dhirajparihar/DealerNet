import 'package:flutter/foundation.dart';
import '../../../core/network/supabase_config.dart';
import '../domain/vehicle.dart';

class SupabaseVehicleRepository {
  final _client = SupabaseConfig.client;

  bool get isConnected => _client != null;

  /// Fetches vehicles from Supabase PostgreSQL
  Future<List<Vehicle>?> fetchVehicles() async {
    if (_client == null) return null;

    try {
      final response = await _client
          .from('vehicles')
          .select('*, vehicle_photos(photo_url, sort_order), dealers(business_name, contact_name, phone, whatsapp_phone, verification_status)')
          .order('published_at', ascending: false);

      final List<Vehicle> vehicles = [];
      for (final item in response as List<dynamic>) {
        final dealer = item['dealers'] as Map<String, dynamic>?;
        final photosList = item['vehicle_photos'] as List<dynamic>?;
        final photos = photosList != null
            ? photosList.map((p) => p['photo_url'] as String).toList()
            : <String>[];

        vehicles.add(
          Vehicle(
            id: item['id'] as String,
            dealerId: item['dealer_id'] as String,
            dealerName: dealer?['business_name'] as String? ?? 'Verified Dealer',
            dealerPhone: dealer?['phone'] as String? ?? '+919826012345',
            dealerWhatsapp: dealer?['whatsapp_phone'] as String? ?? '+919826012345',
            dealerVerified: (dealer?['verification_status'] as String? ?? '') == 'verified',
            make: item['make_name'] as String,
            model: item['model_name'] as String,
            variant: item['variant_name'] as String? ?? '',
            year: item['year'] as int,
            km: item['km'] as int,
            priceRupees: item['price_rupees'] as int,
            fuelType: item['fuel_type'] as String,
            transmission: item['transmission'] as String,
            city: item['city_name'] as String? ?? 'Indore',
            area: item['area'] as String? ?? 'Indore',
            colour: item['colour'] as String? ?? '',
            ownerCount: item['owner_count'] as int? ?? 1,
            registrationState: item['registration_state'] as String? ?? 'MP-09',
            insuranceStatus: item['insurance_status'] as String? ?? 'Active',
            serviceHistory: item['service_history'] as String? ?? 'Available',
            accidentCondition: item['accident_condition'] as String? ?? 'Non-Accidental',
            notes: item['notes'] as String? ?? '',
            status: _parseStatus(item['status'] as String?),
            photos: photos,
            lastAvailabilityConfirmedAt: DateTime.tryParse(item['last_availability_confirmed_at'] as String? ?? '') ?? DateTime.now(),
            publishedAt: DateTime.tryParse(item['published_at'] as String? ?? '') ?? DateTime.now(),
            createdAt: DateTime.tryParse(item['created_at'] as String? ?? '') ?? DateTime.now(),
          ),
        );
      }
      return vehicles;
    } catch (e) {
      debugPrint('Error fetching from Supabase: $e');
      return null;
    }
  }

  /// Inserts a newly published vehicle into Supabase
  Future<bool> insertVehicle(Vehicle vehicle) async {
    if (_client == null) return false;

    try {
      final insertData = {
        'id': vehicle.id,
        'dealer_id': vehicle.dealerId,
        'make_name': vehicle.make,
        'model_name': vehicle.model,
        'variant_name': vehicle.variant,
        'year': vehicle.year,
        'km': vehicle.km,
        'price_rupees': vehicle.priceRupees,
        'fuel_type': vehicle.fuelType,
        'transmission': vehicle.transmission,
        'city_name': vehicle.city,
        'area': vehicle.area,
        'colour': vehicle.colour,
        'owner_count': vehicle.ownerCount,
        'registration_state': vehicle.registrationState,
        'insurance_status': vehicle.insuranceStatus,
        'service_history': vehicle.serviceHistory,
        'accident_condition': vehicle.accidentCondition,
        'notes': vehicle.notes,
        'status': vehicle.status.name,
        'published_at': vehicle.publishedAt.toIso8601String(),
        'last_availability_confirmed_at': vehicle.lastAvailabilityConfirmedAt.toIso8601String(),
      };

      await _client.from('vehicles').insert(insertData);

      // Insert photos
      if (vehicle.photos.isNotEmpty) {
        final photosData = vehicle.photos.asMap().entries.map((entry) {
          return {
            'vehicle_id': vehicle.id,
            'photo_url': entry.value,
            'storage_path': 'photo_${entry.key}.jpg',
            'sort_order': entry.key,
          };
        }).toList();
        await _client.from('vehicle_photos').insert(photosData);
      }

      return true;
    } catch (e) {
      debugPrint('Error inserting vehicle to Supabase: $e');
      return false;
    }
  }

  /// Updates vehicle status (available, reserved, sold) in Supabase
  Future<bool> updateStatus(String vehicleId, VehicleStatus status) async {
    if (_client == null) return false;

    try {
      await _client.from('vehicles').update({
        'status': status.name,
        'last_availability_confirmed_at': DateTime.now().toIso8601String(),
      }).eq('id', vehicleId);
      return true;
    } catch (e) {
      debugPrint('Error updating vehicle status in Supabase: $e');
      return false;
    }
  }

  VehicleStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return VehicleStatus.available;
      case 'reserved':
        return VehicleStatus.reserved;
      case 'sold':
        return VehicleStatus.sold;
      case 'draft':
        return VehicleStatus.draft;
      case 'expired':
        return VehicleStatus.expired;
      default:
        return VehicleStatus.available;
    }
  }
}
