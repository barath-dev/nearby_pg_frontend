import 'package:json_annotation/json_annotation.dart';

/// Enum for booking status
enum BookingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('checked_in')
  checkedIn,
  @JsonValue('checked_out')
  checkedOut,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('refunded')
  refunded,
}

/// Enum for gender preference
enum GenderPreference {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('co_ed')
  coEd,
  @JsonValue('any')
  any,
}

/// Enum for occupation type
enum OccupationType {
  @JsonValue('student')
  student,
  @JsonValue('working_professional')
  workingProfessional,
  @JsonValue('any')
  any, other,
}

/// Enum for room type
enum RoomType {
  @JsonValue('single')
  single,
  @JsonValue('double')
  double,
  @JsonValue('triple')
  triple,
  @JsonValue('dormitory')
  dormitory, other,
}

/// Enum for amenity types
enum AmenityType {
  @JsonValue('wifi')
  wifi,
  @JsonValue('ac')
  ac,
  @JsonValue('meals')
  meals,
  @JsonValue('laundry')
  laundry,
  @JsonValue('parking')
  parking,
  @JsonValue('gym')
  gym,
  @JsonValue('security')
  security,
  @JsonValue('housekeeping')
  housekeeping,
  @JsonValue('hot_water')
  hotWater,
  @JsonValue('power_backup')
  powerBackup,
  @JsonValue('cctv')
  cctv,
  @JsonValue('study_room')
  studyRoom,
  @JsonValue('recreation_room')
  recreationRoom,
  @JsonValue('other')
  other,
}

/// PG Property model representing a paying guest accommodation
@JsonSerializable()
class PGProperty {
  /// Unique identifier for the PG property
  final String id;

  /// Name of the PG
  final String name;

  /// Complete address of the PG
  final String address;

  /// City where the PG is located
  final String city;

  /// State where the PG is located
  final String state;

  /// Postal code
  final String pincode;

  /// Latitude coordinate
  final double latitude;

  /// Longitude coordinate
  final double longitude;

  /// Monthly rent amount
  final double monthlyRent;

  /// Security deposit amount
  final double securityDeposit;

  /// Maintenance fee (if applicable)
  final double? maintenanceFee;

  /// Number of available rooms
  final int availableRooms;

  /// Total number of rooms
  final int totalRooms;

  /// Average rating (1-5 scale)
  final double rating;

  /// Total number of reviews
  final int reviewCount;

  /// List of available amenities
  final List<AmenityType> amenities;

  /// List of property images URLs
  final List<String> images;

  /// Gender preference for residents
  final GenderPreference genderPreference;

  /// Whether meals are included
  final bool mealsIncluded;

  /// Meal price (if meals are optional)
  final double? mealPrice;

  /// Room types available
  final List<RoomType> roomTypes;

  /// Preferred occupation type
  final OccupationType occupationType;

  /// Property owner/manager name
  final String ownerName;

  /// Contact phone number
  final String contactPhone;

  /// Contact email
  final String? contactEmail;

  /// Check-in time
  final String checkInTime;

  /// Check-out time
  final String checkOutTime;

  /// Property description
  final String description;

  /// House rules
  final List<String> houseRules;

  /// Nearby landmarks
  final List<String> nearbyLandmarks;

  /// Distance to nearest metro/railway station (in km)
  final double? nearestStationDistance;

  /// Whether the property is verified
  final bool isVerified;

  /// Whether the property is featured
  final bool isFeatured;

  /// Whether the property is currently active
  final bool isActive;

  /// Date when the property was created
  final DateTime createdAt;

  /// Date when the property was last updated
  final DateTime updatedAt;

  /// Available from date
  final DateTime? availableFrom;

  const PGProperty({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.monthlyRent,
    required this.securityDeposit,
    this.maintenanceFee,
    required this.availableRooms,
    required this.totalRooms,
    required this.rating,
    required this.reviewCount,
    required this.amenities,
    required this.images,
    required this.genderPreference,
    required this.mealsIncluded,
    this.mealPrice,
    required this.roomTypes,
    required this.occupationType,
    required this.ownerName,
    required this.contactPhone,
    this.contactEmail,
    required this.checkInTime,
    required this.checkOutTime,
    required this.description,
    required this.houseRules,
    required this.nearbyLandmarks,
    this.nearestStationDistance,
    required this.isVerified,
    required this.isFeatured,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.availableFrom,
  });

  factory PGProperty.fromJson(Map<String, dynamic> json) {
    return PGProperty(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      monthlyRent: (json['monthlyRent'] as num).toDouble(),
      securityDeposit: (json['securityDeposit'] as num).toDouble(),
      maintenanceFee:
          json['maintenanceFee'] != null
              ? (json['maintenanceFee'] as num).toDouble()
              : null,
      availableRooms: json['availableRooms'] as int,
      totalRooms: json['totalRooms'] as int,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      amenities:
          (json['amenities'] as List<dynamic>)
              .map(
                (e) => AmenityType.values.firstWhere((a) => a.toString() == e),
              )
              .toList(),
      images: List<String>.from(json['images'] as List),
      genderPreference: GenderPreference.values.firstWhere(
        (g) => g.toString() == json['genderPreference'],
      ),
      mealsIncluded: json['mealsIncluded'] as bool,
      mealPrice:
          json['mealPrice'] != null
              ? (json['mealPrice'] as num).toDouble()
              : null,
      roomTypes:
          (json['roomTypes'] as List<dynamic>)
              .map((e) => RoomType.values.firstWhere((r) => r.toString() == e))
              .toList(),
      occupationType: OccupationType.values.firstWhere(
        (o) => o.toString() == json['occupationType'],
      ),
      ownerName: json['ownerName'] as String,
      contactPhone: json['contactPhone'] as String,
      contactEmail: json['contactEmail'] as String?,
      checkInTime: json['checkInTime'] as String,
      checkOutTime: json['checkOutTime'] as String,
      description: json['description'] as String,
      houseRules: List<String>.from(json['houseRules'] as List),
      nearbyLandmarks: List<String>.from(json['nearbyLandmarks'] as List),
      nearestStationDistance:
          json['nearestStationDistance'] != null
              ? (json['nearestStationDistance'] as num).toDouble()
              : null,
      isVerified: json['isVerified'] as bool,
      isFeatured: json['isFeatured'] as bool,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      availableFrom:
          json['availableFrom'] != null
              ? DateTime.parse(json['availableFrom'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'monthlyRent': monthlyRent,
      'securityDeposit': securityDeposit,
      'maintenanceFee': maintenanceFee,
      'availableRooms': availableRooms,
      'totalRooms': totalRooms,
      'rating': rating,
      'reviewCount': reviewCount,
      'amenities': amenities.map((a) => a.toString()).toList(),
      'images': images,
      'genderPreference': genderPreference.toString(),
      'mealsIncluded': mealsIncluded,
      'mealPrice': mealPrice,
      'roomTypes': roomTypes.map((r) => r.toString()).toList(),
      'occupationType': occupationType.toString(),
      'ownerName': ownerName,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'description': description,
      'houseRules': houseRules,
      'nearbyLandmarks': nearbyLandmarks,
      'nearestStationDistance': nearestStationDistance,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'availableFrom': availableFrom?.toIso8601String(),
    };
  }

  /// Calculate total monthly cost including optional fees
  double get totalMonthlyCost {
    double total = monthlyRent;
    if (maintenanceFee != null) total += maintenanceFee!;
    if (mealsIncluded && mealPrice != null) total += mealPrice!;
    return total;
  }

  /// Check if the property has specific amenity
  bool hasAmenity(AmenityType amenity) => amenities.contains(amenity);

  /// Get formatted rating string
  String get formattedRating => rating.toStringAsFixed(1);

  /// Check if property is available
  bool get isAvailable => isActive && availableRooms > 0;

  /// Get urgency message based on available rooms
  String? get urgencyMessage {
    if (availableRooms <= 0) return 'Fully Booked';
    if (availableRooms <= 2) return 'Only $availableRooms rooms left!';
    if (availableRooms <= 5) return '$availableRooms rooms available';
    return null;
  }

  /// Copy with method for creating modified instances
  PGProperty copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? state,
    String? pincode,
    double? latitude,
    double? longitude,
    double? monthlyRent,
    double? securityDeposit,
    double? maintenanceFee,
    int? availableRooms,
    int? totalRooms,
    double? rating,
    int? reviewCount,
    List<AmenityType>? amenities,
    List<String>? images,
    GenderPreference? genderPreference,
    bool? mealsIncluded,
    double? mealPrice,
    List<RoomType>? roomTypes,
    OccupationType? occupationType,
    String? ownerName,
    String? contactPhone,
    String? contactEmail,
    String? checkInTime,
    String? checkOutTime,
    String? description,
    List<String>? houseRules,
    List<String>? nearbyLandmarks,
    double? nearestStationDistance,
    bool? isVerified,
    bool? isFeatured,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? availableFrom,
  }) {
    return PGProperty(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      maintenanceFee: maintenanceFee ?? this.maintenanceFee,
      availableRooms: availableRooms ?? this.availableRooms,
      totalRooms: totalRooms ?? this.totalRooms,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
      genderPreference: genderPreference ?? this.genderPreference,
      mealsIncluded: mealsIncluded ?? this.mealsIncluded,
      mealPrice: mealPrice ?? this.mealPrice,
      roomTypes: roomTypes ?? this.roomTypes,
      occupationType: occupationType ?? this.occupationType,
      ownerName: ownerName ?? this.ownerName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      description: description ?? this.description,
      houseRules: houseRules ?? this.houseRules,
      nearbyLandmarks: nearbyLandmarks ?? this.nearbyLandmarks,
      nearestStationDistance:
          nearestStationDistance ?? this.nearestStationDistance,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      availableFrom: availableFrom ?? this.availableFrom,
    );
  }
}

/// User Profile model
@JsonSerializable()
class UserProfile {
  /// Unique user identifier
  final String userId;

  /// User's full name
  final String name;

  /// User's email address
  final String email;

  /// User's phone number
  final String phone;

  /// Profile picture URL
  final String? profilePicture;

  /// User's date of birth
  final DateTime? dateOfBirth;

  /// User's gender
  final String? gender;

  /// User's occupation type
  final OccupationType occupationType;

  /// Current city/location
  final String currentLocation;

  /// Preferred location for PG search
  final String preferredLocation;

  /// Minimum budget range
  final double budgetMin;

  /// Maximum budget range
  final double budgetMax;

  /// Preferred amenities
  final List<AmenityType> preferredAmenities;

  /// Preferred gender accommodation
  final GenderPreference genderPreference;

  /// Whether user prefers meals included
  final bool prefersMeals;

  /// Preferred room type
  final List<RoomType> preferredRoomTypes;

  /// Emergency contact name
  final String? emergencyContactName;

  /// Emergency contact phone
  final String? emergencyContactPhone;

  /// User's address
  final String? address;

  /// Whether user profile is verified
  final bool isVerified;

  /// User registration date
  final DateTime createdAt;

  /// Last profile update date
  final DateTime updatedAt;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePicture,
    this.dateOfBirth,
    this.gender,
    required this.occupationType,
    required this.currentLocation,
    required this.preferredLocation,
    required this.budgetMin,
    required this.budgetMax,
    required this.preferredAmenities,
    required this.genderPreference,
    required this.prefersMeals,
    required this.preferredRoomTypes,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.address,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profilePicture: json['profilePicture'] as String?,
      dateOfBirth:
          json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'] as String)
              : null,
      gender: json['gender'] as String?,
      occupationType: OccupationType.values.firstWhere(
        (e) => e.toString() == 'OccupationType.${json['occupationType']}',
        orElse: () => OccupationType.other,
      ),
      currentLocation: json['currentLocation'] as String,
      preferredLocation: json['preferredLocation'] as String,
      budgetMin: (json['budgetMin'] as num).toDouble(),
      budgetMax: (json['budgetMax'] as num).toDouble(),
      preferredAmenities:
          (json['preferredAmenities'] as List<dynamic>)
              .map(
                (e) => AmenityType.values.firstWhere(
                  (a) => a.toString() == 'AmenityType.$e',
                  orElse: () => AmenityType.other,
                ),
              )
              .toList(),
      genderPreference: GenderPreference.values.firstWhere(
        (e) => e.toString() == 'GenderPreference.${json['genderPreference']}',
        orElse: () => GenderPreference.any,
      ),
      prefersMeals: json['prefersMeals'] as bool,
      preferredRoomTypes:
          (json['preferredRoomTypes'] as List<dynamic>)
              .map(
                (e) => RoomType.values.firstWhere(
                  (r) => r.toString() == 'RoomType.$e',
                  orElse: () => RoomType.other,
                ),
              )
              .toList(),
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      address: json['address'] as String?,
      isVerified: json['isVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'email': email,
    'phone': phone,
    'profilePicture': profilePicture,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'gender': gender,
    'occupationType': occupationType.toString().split('.').last,
    'currentLocation': currentLocation,
    'preferredLocation': preferredLocation,
    'budgetMin': budgetMin,
    'budgetMax': budgetMax,
    'preferredAmenities':
        preferredAmenities.map((e) => e.toString().split('.').last).toList(),
    'genderPreference': genderPreference.toString().split('.').last,
    'prefersMeals': prefersMeals,
    'preferredRoomTypes':
        preferredRoomTypes.map((e) => e.toString().split('.').last).toList(),
    'emergencyContactName': emergencyContactName,
    'emergencyContactPhone': emergencyContactPhone,
    'address': address,
    'isVerified': isVerified,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Get formatted budget range
  String get formattedBudgetRange =>
      '₹${budgetMin.toInt()} - ₹${budgetMax.toInt()}';

  /// Check if profile is complete
  bool get isProfileComplete {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        preferredLocation.isNotEmpty &&
        budgetMin > 0 &&
        budgetMax > budgetMin;
  }

  /// Get age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  UserProfile copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? profilePicture,
    DateTime? dateOfBirth,
    String? gender,
    OccupationType? occupationType,
    String? currentLocation,
    String? preferredLocation,
    double? budgetMin,
    double? budgetMax,
    List<AmenityType>? preferredAmenities,
    GenderPreference? genderPreference,
    bool? prefersMeals,
    List<RoomType>? preferredRoomTypes,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? address,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      occupationType: occupationType ?? this.occupationType,
      currentLocation: currentLocation ?? this.currentLocation,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      preferredAmenities: preferredAmenities ?? this.preferredAmenities,
      genderPreference: genderPreference ?? this.genderPreference,
      prefersMeals: prefersMeals ?? this.prefersMeals,
      preferredRoomTypes: preferredRoomTypes ?? this.preferredRoomTypes,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      address: address ?? this.address,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Booking model for PG reservations
@JsonSerializable()
class Booking {
  /// Unique booking identifier
  final String bookingId;

  /// PG property ID
  final String pgPropertyId;

  /// User ID who made the booking
  final String userId;

  /// Room type booked
  final RoomType roomType;

  /// Check-in date
  final DateTime checkInDate;

  /// Check-out date (if known)
  final DateTime? checkOutDate;

  /// Monthly rent amount
  final double monthlyRent;

  /// Security deposit paid
  final double securityDeposit;

  /// Additional fees (maintenance, etc.)
  final double additionalFees;

  /// Total amount paid
  final double totalAmount;

  /// Booking status
  final BookingStatus status;

  /// Payment transaction ID
  final String? transactionId;

  /// Special requests from user
  final String? specialRequests;

  /// Booking notes
  final String? notes;

  /// Date when booking was created
  final DateTime createdAt;

  /// Date when booking was last updated
  final DateTime updatedAt;

  /// Cancellation reason (if cancelled)
  final String? cancellationReason;

  /// Refund amount (if applicable)
  final double? refundAmount;

  const Booking({
    required this.bookingId,
    required this.pgPropertyId,
    required this.userId,
    required this.roomType,
    required this.checkInDate,
    this.checkOutDate,
    required this.monthlyRent,
    required this.securityDeposit,
    required this.additionalFees,
    required this.totalAmount,
    required this.status,
    this.transactionId,
    this.specialRequests,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.cancellationReason,
    this.refundAmount,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['bookingId'] as String,
      pgPropertyId: json['pgPropertyId'] as String,
      userId: json['userId'] as String,
      roomType: RoomType.values.firstWhere(
        (e) => e.toString() == 'RoomType.${json['roomType']}',
        orElse: () => RoomType.single,
      ),
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      checkOutDate: json['checkOutDate'] != null
          ? DateTime.parse(json['checkOutDate'] as String)
          : null,
      monthlyRent: (json['monthlyRent'] as num).toDouble(),
      securityDeposit: (json['securityDeposit'] as num).toDouble(),
      additionalFees: (json['additionalFees'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${json['status']}',
        orElse: () => BookingStatus.pending,
      ),
      transactionId: json['transactionId'] as String?,
      specialRequests: json['specialRequests'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      cancellationReason: json['cancellationReason'] as String?,
      refundAmount: json['refundAmount'] != null
          ? (json['refundAmount'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'pgPropertyId': pgPropertyId,
        'userId': userId,
        'roomType': roomType.toString().split('.').last,
        'checkInDate': checkInDate.toIso8601String(),
        'checkOutDate': checkOutDate?.toIso8601String(),
        'monthlyRent': monthlyRent,
        'securityDeposit': securityDeposit,
        'additionalFees': additionalFees,
        'totalAmount': totalAmount,
        'status': status.toString().split('.').last,
        'transactionId': transactionId,
        'specialRequests': specialRequests,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'cancellationReason': cancellationReason,
        'refundAmount': refundAmount,
      };

  /// Check if booking is active
  bool get isActive =>
      status == BookingStatus.confirmed || status == BookingStatus.checkedIn;

  /// Check if booking can be cancelled
  bool get canBeCancelled =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;

  /// Get formatted status
  String get formattedStatus {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending Confirmation';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.checkedIn:
        return 'Checked In';
      case BookingStatus.checkedOut:
        return 'Checked Out';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.refunded:
        return 'Refunded';
    }
  }

  /// Get days until check-in
  int get daysUntilCheckIn {
    final now = DateTime.now();
    return checkInDate.difference(now).inDays;
  }

  /// Get duration of stay (if check-out date is set)
  int? get stayDuration {
    if (checkOutDate == null) return null;
    return checkOutDate!.difference(checkInDate).inDays;
  }

  Booking copyWith({
    String? bookingId,
    String? pgPropertyId,
    String? userId,
    RoomType? roomType,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    double? monthlyRent,
    double? securityDeposit,
    double? additionalFees,
    double? totalAmount,
    BookingStatus? status,
    String? transactionId,
    String? specialRequests,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancellationReason,
    double? refundAmount,
  }) {
    return Booking(
      bookingId: bookingId ?? this.bookingId,
      pgPropertyId: pgPropertyId ?? this.pgPropertyId,
      userId: userId ?? this.userId,
      roomType: roomType ?? this.roomType,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      additionalFees: additionalFees ?? this.additionalFees,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      specialRequests: specialRequests ?? this.specialRequests,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      refundAmount: refundAmount ?? this.refundAmount,
    );
  }
}

/// Search filter model
@JsonSerializable()
class SearchFilter {
  /// Location filter
  final String? location;

  /// Minimum budget
  final double? minBudget;

  /// Maximum budget
  final double? maxBudget;

  /// Gender preference
  final GenderPreference? genderPreference;

  /// Room type preferences
  final List<RoomType>? roomTypes;

  /// Required amenities
  final List<AmenityType>? requiredAmenities;

  /// Meal preference
  final bool? mealsIncluded;

  /// Occupation type
  final OccupationType? occupationType;

  /// Minimum rating
  final double? minRating;

  /// Maximum distance from current location (in km)
  final double? maxDistance;

  /// Sort by option
  final String? sortBy;

  /// Sort order (asc/desc)
  final String? sortOrder;

  const SearchFilter({
    this.location,
    this.minBudget,
    this.maxBudget,
    this.genderPreference,
    this.roomTypes,
    this.requiredAmenities,
    this.mealsIncluded,
    this.occupationType,
    this.minRating,
    this.maxDistance,
    this.sortBy,
    this.sortOrder,
  });

  factory SearchFilter.fromJson(Map<String, dynamic> json) {
    return SearchFilter(
      location: json['location'] as String?,
      minBudget: (json['minBudget'] as num?)?.toDouble(),
      maxBudget: (json['maxBudget'] as num?)?.toDouble(),
      genderPreference: json['genderPreference'] != null
          ? GenderPreference.values.firstWhere(
              (e) => e.toString() == 'GenderPreference.${json['genderPreference']}')
          : null,
      roomTypes: (json['roomTypes'] as List<dynamic>?)
          ?.map((e) => RoomType.values.firstWhere(
              (rt) => rt.toString() == 'RoomType.$e'))
          .toList(),
      requiredAmenities: (json['requiredAmenities'] as List<dynamic>?)
          ?.map((e) => AmenityType.values.firstWhere(
              (at) => at.toString() == 'AmenityType.$e'))
          .toList(),
      mealsIncluded: json['mealsIncluded'] as bool?,
      occupationType: json['occupationType'] != null
          ? OccupationType.values.firstWhere(
              (e) => e.toString() == 'OccupationType.${json['occupationType']}')
          : null,
      minRating: (json['minRating'] as num?)?.toDouble(),
      maxDistance: (json['maxDistance'] as num?)?.toDouble(),
      sortBy: json['sortBy'] as String?,
      sortOrder: json['sortOrder'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'genderPreference': genderPreference?.name,
      'roomTypes': roomTypes?.map((e) => e.name).toList(),
      'requiredAmenities': requiredAmenities?.map((e) => e.name).toList(),
      'mealsIncluded': mealsIncluded,
      'occupationType': occupationType?.name,
      'minRating': minRating,
      'maxDistance': maxDistance,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
  }

  /// Check if any filter is applied
  bool get hasFilters {
    return location != null ||
        minBudget != null ||
        maxBudget != null ||
        genderPreference != null ||
        (roomTypes?.isNotEmpty ?? false) ||
        (requiredAmenities?.isNotEmpty ?? false) ||
        mealsIncluded != null ||
        occupationType != null ||
        minRating != null ||
        maxDistance != null;
  }

  /// Clear all filters
  SearchFilter clearAll() {
    return const SearchFilter();
  }

  SearchFilter copyWith({
    String? location,
    double? minBudget,
    double? maxBudget,
    GenderPreference? genderPreference,
    List<RoomType>? roomTypes,
    List<AmenityType>? requiredAmenities,
    bool? mealsIncluded,
    OccupationType? occupationType,
    double? minRating,
    double? maxDistance,
    String? sortBy,
    String? sortOrder,
  }) {
    return SearchFilter(
      location: location ?? this.location,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      genderPreference: genderPreference ?? this.genderPreference,
      roomTypes: roomTypes ?? this.roomTypes,
      requiredAmenities: requiredAmenities ?? this.requiredAmenities,
      mealsIncluded: mealsIncluded ?? this.mealsIncluded,
      occupationType: occupationType ?? this.occupationType,
      minRating: minRating ?? this.minRating,
      maxDistance: maxDistance ?? this.maxDistance,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
