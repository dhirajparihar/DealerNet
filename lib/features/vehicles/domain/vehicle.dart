enum VehicleStatus {
  available,
  reserved,
  sold,
  draft,
  expired,
}

extension VehicleStatusExtension on VehicleStatus {
  String get label {
    switch (this) {
      case VehicleStatus.available:
        return 'AVAILABLE';
      case VehicleStatus.reserved:
        return 'RESERVED';
      case VehicleStatus.sold:
        return 'SOLD';
      case VehicleStatus.draft:
        return 'DRAFT';
      case VehicleStatus.expired:
        return 'EXPIRED';
    }
  }
}

class Vehicle {
  final String id;
  final String dealerId;
  final String dealerName;
  final String dealerPhone;
  final String dealerWhatsapp;
  final bool dealerVerified;
  final String make;
  final String model;
  final String variant;
  final int year;
  final int km;
  final int priceRupees;
  final String fuelType;
  final String transmission;
  final String city;
  final String area;
  final String colour;
  final int ownerCount;
  final String registrationState;
  final String insuranceStatus;
  final String serviceHistory;
  final String accidentCondition;
  final String notes;
  final VehicleStatus status;
  final List<String> photos;
  final DateTime lastAvailabilityConfirmedAt;
  final DateTime publishedAt;
  final DateTime createdAt;

  const Vehicle({
    required this.id,
    required this.dealerId,
    required this.dealerName,
    required this.dealerPhone,
    required this.dealerWhatsapp,
    required this.dealerVerified,
    required this.make,
    required this.model,
    required this.variant,
    required this.year,
    required this.km,
    required this.priceRupees,
    required this.fuelType,
    required this.transmission,
    required this.city,
    required this.area,
    required this.colour,
    required this.ownerCount,
    required this.registrationState,
    required this.insuranceStatus,
    required this.serviceHistory,
    required this.accidentCondition,
    required this.notes,
    required this.status,
    required this.photos,
    required this.lastAvailabilityConfirmedAt,
    required this.publishedAt,
    required this.createdAt,
  });

  String get title => '$year $make $model $variant'.trim();

  Vehicle copyWith({
    String? id,
    String? dealerId,
    String? dealerName,
    String? dealerPhone,
    String? dealerWhatsapp,
    bool? dealerVerified,
    String? make,
    String? model,
    String? variant,
    int? year,
    int? km,
    int? priceRupees,
    String? fuelType,
    String? transmission,
    String? city,
    String? area,
    String colour = '',
    int? ownerCount,
    String? registrationState,
    String? insuranceStatus,
    String? serviceHistory,
    String? accidentCondition,
    String? notes,
    VehicleStatus? status,
    List<String>? photos,
    DateTime? lastAvailabilityConfirmedAt,
    DateTime? publishedAt,
    DateTime? createdAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      dealerId: dealerId ?? this.dealerId,
      dealerName: dealerName ?? this.dealerName,
      dealerPhone: dealerPhone ?? this.dealerPhone,
      dealerWhatsapp: dealerWhatsapp ?? this.dealerWhatsapp,
      dealerVerified: dealerVerified ?? this.dealerVerified,
      make: make ?? this.make,
      model: model ?? this.model,
      variant: variant ?? this.variant,
      year: year ?? this.year,
      km: km ?? this.km,
      priceRupees: priceRupees ?? this.priceRupees,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      city: city ?? this.city,
      area: area ?? this.area,
      colour: colour.isNotEmpty ? colour : this.colour,
      ownerCount: ownerCount ?? this.ownerCount,
      registrationState: registrationState ?? this.registrationState,
      insuranceStatus: insuranceStatus ?? this.insuranceStatus,
      serviceHistory: serviceHistory ?? this.serviceHistory,
      accidentCondition: accidentCondition ?? this.accidentCondition,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      photos: photos ?? this.photos,
      lastAvailabilityConfirmedAt:
          lastAvailabilityConfirmedAt ?? this.lastAvailabilityConfirmedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
