enum VerificationStatus {
  mobileVerified,
  pending,
  verified,
  rejected,
  suspended,
}

class Dealer {
  final String id;
  final String businessName;
  final String contactName;
  final String phone;
  final String whatsappPhone;
  final String city;
  final String area;
  final String? logoUrl;
  final VerificationStatus verificationStatus;
  final bool isActive;
  final int activeStockCount;
  final DateTime createdAt;

  const Dealer({
    required this.id,
    required this.businessName,
    required this.contactName,
    required this.phone,
    required this.whatsappPhone,
    required this.city,
    required this.area,
    this.logoUrl,
    required this.verificationStatus,
    this.isActive = true,
    this.activeStockCount = 0,
    required this.createdAt,
  });

  bool get isApproved =>
      verificationStatus == VerificationStatus.verified ||
      verificationStatus == VerificationStatus.mobileVerified;

  Dealer copyWith({
    String? id,
    String? businessName,
    String? contactName,
    String? phone,
    String? whatsappPhone,
    String? city,
    String? area,
    String? logoUrl,
    VerificationStatus? verificationStatus,
    bool? isActive,
    int? activeStockCount,
    DateTime? createdAt,
  }) {
    return Dealer(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      whatsappPhone: whatsappPhone ?? this.whatsappPhone,
      city: city ?? this.city,
      area: area ?? this.area,
      logoUrl: logoUrl ?? this.logoUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isActive: isActive ?? this.isActive,
      activeStockCount: activeStockCount ?? this.activeStockCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
