class WantedRequest {
  final String id;
  final String dealerId;
  final String dealerName;
  final String dealerPhone;
  final String dealerWhatsapp;
  final String make;
  final String model;
  final int? yearMin;
  final int? yearMax;
  final int? budgetMax;
  final int? kmMax;
  final String fuelType;
  final String transmission;
  final String city;
  final String area;
  final String notes;
  final int matchingCount;
  final bool isActive;
  final DateTime createdAt;

  const WantedRequest({
    required this.id,
    required this.dealerId,
    required this.dealerName,
    required this.dealerPhone,
    required this.dealerWhatsapp,
    required this.make,
    required this.model,
    this.yearMin,
    this.yearMax,
    this.budgetMax,
    this.kmMax,
    required this.fuelType,
    required this.transmission,
    required this.city,
    required this.area,
    required this.notes,
    this.matchingCount = 0,
    this.isActive = true,
    required this.createdAt,
  });

  String get title => '$make $model'.trim().isEmpty ? 'Any Make / Model' : '$make $model';

  WantedRequest copyWith({
    String? id,
    String? dealerId,
    String? dealerName,
    String? dealerPhone,
    String? dealerWhatsapp,
    String? make,
    String? model,
    int? yearMin,
    int? yearMax,
    int? budgetMax,
    int? kmMax,
    String? fuelType,
    String? transmission,
    String? city,
    String? area,
    String? notes,
    int? matchingCount,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return WantedRequest(
      id: id ?? this.id,
      dealerId: dealerId ?? this.dealerId,
      dealerName: dealerName ?? this.dealerName,
      dealerPhone: dealerPhone ?? this.dealerPhone,
      dealerWhatsapp: dealerWhatsapp ?? this.dealerWhatsapp,
      make: make ?? this.make,
      model: model ?? this.model,
      yearMin: yearMin ?? this.yearMin,
      yearMax: yearMax ?? this.yearMax,
      budgetMax: budgetMax ?? this.budgetMax,
      kmMax: kmMax ?? this.kmMax,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      city: city ?? this.city,
      area: area ?? this.area,
      notes: notes ?? this.notes,
      matchingCount: matchingCount ?? this.matchingCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
