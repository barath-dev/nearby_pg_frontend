// lib/shared/models/app_models.dart

/// PG Property model
class PGProperty {
  /// Unique identifier
  final String id;

  /// PG name
  final String name;

  /// Full address
  final String address;

  /// Latitude
  final double latitude;

  /// Longitude
  final double longitude;

  /// Monthly rent
  final double price;

  /// Security deposit
  final double securityDeposit;

  /// Rating (0-5)
  final double rating;

  /// Number of reviews
  final int reviewCount;

  /// Available amenities
  final List<String> amenities;

  /// Property images
  final List<String> images;

  /// Gender preference (MALE, FEMALE, ANY)
  final String genderPreference;

  /// Available room types
  final List<String> roomTypes;

  /// Occupation type (STUDENT, PROFESSIONAL, ANY)
  final String occupationType;

  /// Owner name
  final String ownerName;

  /// Contact phone
  final String contactPhone;

  /// Contact email
  final String? contactEmail;

  /// Full description
  final String description;

  /// House rules
  final List<String> houseRules;

  /// Nearby landmarks
  final List<String> nearbyLandmarks;

  /// Distance to nearest metro/bus station (in km)

  /// Whether property is verified
  final bool isVerified;

  /// Whether property is featured
  final bool isFeatured;

  /// Whether property is active
  final bool isActive;

  /// Creation date
  final DateTime createdAt;

  /// Last update date
  final DateTime updatedAt;

  /// Available from date
  final DateTime? availableFrom;

  //available rooms
  final int availableRooms;

  //total rooms
  final int totalRooms;

  final String area;

  /// Constructor
  const PGProperty({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.securityDeposit,
    required this.rating,
    required this.reviewCount,
    required this.amenities,
    required this.images,
    required this.genderPreference,
    required this.roomTypes,
    required this.occupationType,
    required this.ownerName,
    required this.contactPhone,
    this.contactEmail,
    required this.description,
    required this.houseRules,
    required this.nearbyLandmarks,
    required this.isVerified,
    required this.isFeatured,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.totalRooms,
    required this.availableRooms,
    this.availableFrom,
    required this.area,
  });

  /// Create from JSON
  factory PGProperty.fromJson(Map<String, dynamic> json) {
    return PGProperty(
      id: json['id'] as String,
      name: json['name'] as String,
      area: json['area'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      securityDeposit: (json['securityDeposit'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      genderPreference: json['genderPreference'] as String? ?? 'ANY',
      roomTypes: (json['roomTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      occupationType: json['occupationType'] as String? ?? 'ANY',
      ownerName: json['ownerName'] as String? ?? 'Property Owner',
      contactPhone: json['contactPhone'] as String? ?? '',
      contactEmail: json['contactEmail'] as String?,
      description: json['description'] as String? ?? '',
      houseRules: (json['houseRules'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      nearbyLandmarks: (json['nearbyLandmarks'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isVerified: json['isVerified'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      availableFrom: json['availableFrom'] != null
          ? DateTime.parse(json['availableFrom'] as String)
          : null,
      totalRooms: json['totalRooms'] as int? ?? 0,
      availableRooms: json['availableRooms'] as int? ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'area': area,
      'longitude': longitude,
      'price': price,
      'securityDeposit': securityDeposit,
      'rating': rating,
      'reviewCount': reviewCount,
      'amenities': amenities,
      'images': images,
      'genderPreference': genderPreference,
      'roomTypes': roomTypes,
      'occupationType': occupationType,
      'ownerName': ownerName,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'description': description,
      'houseRules': houseRules,
      'nearbyLandmarks': nearbyLandmarks,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
      'totalRooms': totalRooms,
      'availableRooms': availableRooms,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'availableFrom': availableFrom?.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  PGProperty copyWith({
    String? id,
    String? name,
    String? area,
    String? address,
    double? latitude,
    double? longitude,
    double? price,
    double? securityDeposit,
    double? rating,
    int? reviewCount,
    List<String>? amenities,
    List<String>? images,
    String? genderPreference,
    List<String>? roomTypes,
    String? occupationType,
    String? ownerName,
    String? contactPhone,
    String? contactEmail,
    List<String>? houseRules,
    List<String>? nearbyLandmarks,
    bool? isVerified,
    bool? isFeatured,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? availableFrom,
    int? totalRooms,
    int? availableRooms,
  }) {
    return PGProperty(
      id: id ?? this.id,
      area: area ?? this.area,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      price: price ?? this.price,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
      genderPreference: genderPreference ?? this.genderPreference,
      roomTypes: roomTypes ?? this.roomTypes,
      occupationType: occupationType ?? this.occupationType,
      ownerName: ownerName ?? this.ownerName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      description: description ?? description,
      houseRules: houseRules ?? this.houseRules,
      nearbyLandmarks: nearbyLandmarks ?? this.nearbyLandmarks,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      availableFrom: availableFrom ?? this.availableFrom,
      totalRooms: totalRooms ?? this.totalRooms,
      availableRooms: availableRooms ?? this.availableRooms,
    );
  }
}

/// User Profile model
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
  final String occupationType;

  /// Current city/location
  final String currentLocation;

  /// Preferred location for PG search
  final String preferredLocation;

  /// Minimum budget range
  final double budgetMin;

  /// Maximum budget range
  final double budgetMax;

  /// Preferred amenities
  final List<String> preferredAmenities;

  /// Preferred gender accommodation
  final String genderPreference;

  /// Whether user prefers meals included
  final bool prefersMeals;

  /// Preferred room type
  final List<String> preferredRoomTypes;

  /// Emergency contact name
  final String? emergencyContactName;

  /// Emergency contact phone
  final String? emergencyContactPhone;

  /// User's address
  final String? address;

  /// Whether user is verified
  final bool isVerified;

  /// Creation date
  final DateTime createdAt;

  /// Last update date
  final DateTime updatedAt;

  /// Constructor
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

  /// Check if profile is complete
  bool get isProfileComplete {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        currentLocation.isNotEmpty &&
        preferredLocation.isNotEmpty;
  }

  /// Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profilePicture: json['profilePicture'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] as String?,
      occupationType: json['occupationType'] as String? ?? 'ANY',
      currentLocation: json['currentLocation'] as String? ?? '',
      preferredLocation: json['preferredLocation'] as String? ?? '',
      budgetMin: (json['budgetMin'] as num?)?.toDouble() ?? 0.0,
      budgetMax: (json['budgetMax'] as num?)?.toDouble() ?? 30000.0,
      preferredAmenities: (json['preferredAmenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      genderPreference: json['genderPreference'] as String? ?? 'ANY',
      prefersMeals: json['prefersMeals'] as bool? ?? false,
      preferredRoomTypes: (json['preferredRoomTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      address: json['address'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'profilePicture': profilePicture,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'occupationType': occupationType,
      'currentLocation': currentLocation,
      'preferredLocation': preferredLocation,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'preferredAmenities': preferredAmenities,
      'genderPreference': genderPreference,
      'prefersMeals': prefersMeals,
      'preferredRoomTypes': preferredRoomTypes,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'address': address,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  UserProfile copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? profilePicture,
    DateTime? dateOfBirth,
    String? gender,
    String? occupationType,
    String? currentLocation,
    String? preferredLocation,
    double? budgetMin,
    double? budgetMax,
    List<String>? preferredAmenities,
    String? genderPreference,
    bool? prefersMeals,
    List<String>? preferredRoomTypes,
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
class Booking {
  /// Unique booking identifier
  final String bookingId;

  /// PG property ID
  final String pgPropertyId;

  /// User ID who made the booking
  final String userId;

  /// Room type booked
  final String roomType;

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
  final String status;

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

  final String? pgName;

  final String? pgAddress;

  final String? pgImage;

  /// Constructor
  Booking({
    required this.bookingId,
    required this.pgAddress,
    required this.pgImage,
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
    this.pgName,
  });

  /// Create from JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      pgAddress: json['pgAddress'] as String,
      bookingId: json['bookingId'] as String,
      pgImage: json['pgImage'] as String?,
      pgPropertyId: json['pgPropertyId'] as String,
      userId: json['userId'] as String,
      roomType: json['roomType'] as String,
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      checkOutDate: json['checkOutDate'] != null
          ? DateTime.parse(json['checkOutDate'] as String)
          : null,
      monthlyRent: (json['monthlyRent'] as num).toDouble(),
      securityDeposit: (json['securityDeposit'] as num).toDouble(),
      additionalFees: (json['additionalFees'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      transactionId: json['transactionId'] as String?,
      specialRequests: json['specialRequests'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      cancellationReason: json['cancellationReason'] as String?,
      refundAmount: (json['refundAmount'] as num?)?.toDouble(),
      pgName: json['pgName'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'pgPropertyId': pgPropertyId,
      'pgAddress': pgAddress,
      'userId': userId,
      'roomType': roomType,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate?.toIso8601String(),
      'monthlyRent': monthlyRent,
      'securityDeposit': securityDeposit,
      'additionalFees': additionalFees,
      'totalAmount': totalAmount,
      'status': status,
      'transactionId': transactionId,
      'pgImage': pgImage,
      'specialRequests': specialRequests,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'cancellationReason': cancellationReason,
      'refundAmount': refundAmount,
      'pgName': pgName,
    };
  }

  /// Create a copy with modified fields
  Booking copyWith({
    String? bookingId,
    String? pgPropertyId,
    String? userId,
    String? roomType,
    String? pgAddress,
    String? pgImage,
    String? pgName,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    double? monthlyRent,
    double? securityDeposit,
    double? additionalFees,
    double? totalAmount,
    String? status,
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
      pgAddress: pgAddress ?? this.pgAddress,
      pgPropertyId: pgPropertyId ?? this.pgPropertyId,
      userId: userId ?? this.userId,
      pgImage: pgImage ?? this.pgImage,
      roomType: roomType ?? this.roomType,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      pgName: pgName ?? this.pgName,
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
class SearchFilter {
  /// Location filter
  final String? location;

  /// Minimum budget
  final double? minBudget;

  /// Maximum budget
  final double? maxBudget;

  /// Gender preference
  final String? genderPreference;

  /// Room type preferences
  final List<String>? roomTypes;

  /// Required amenities
  final List<String>? requiredAmenities;

  /// Meal preference
  final bool? mealsIncluded;

  /// Occupation type
  final String? occupationType;

  /// Minimum rating
  final double? minRating;

  /// Maximum distance from current location (in km)
  final double? maxDistance;

  /// Sort by option
  final String? sortBy;

  /// Sort order (asc/desc)
  final String? sortOrder;

  /// Constructor
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

  /// Create from JSON
  factory SearchFilter.fromJson(Map<String, dynamic> json) {
    return SearchFilter(
      location: json['location'] as String?,
      minBudget: (json['minBudget'] as num?)?.toDouble(),
      maxBudget: (json['maxBudget'] as num?)?.toDouble(),
      genderPreference: json['genderPreference'] as String?,
      roomTypes: (json['roomTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      requiredAmenities: (json['requiredAmenities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      mealsIncluded: json['mealsIncluded'] as bool?,
      occupationType: json['occupationType'] as String?,
      minRating: (json['minRating'] as num?)?.toDouble(),
      maxDistance: (json['maxDistance'] as num?)?.toDouble(),
      sortBy: json['sortBy'] as String?,
      sortOrder: json['sortOrder'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'genderPreference': genderPreference,
      'roomTypes': roomTypes,
      'requiredAmenities': requiredAmenities,
      'mealsIncluded': mealsIncluded,
      'occupationType': occupationType,
      'minRating': minRating,
      'maxDistance': maxDistance,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    }..removeWhere((key, value) => value == null);
  }

  /// Create a copy with modified fields
  SearchFilter copyWith({
    String? location,
    double? minBudget,
    double? maxBudget,
    String? genderPreference,
    List<String>? roomTypes,
    List<String>? requiredAmenities,
    bool? mealsIncluded,
    String? occupationType,
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

/// Promotional Banner model
class PromotionalBanner {
  /// Unique banner ID
  final String id;

  /// Banner image URL
  final String imageUrl;

  /// Banner title
  final String title;

  /// Banner description
  final String description;

  /// Action URL or deep link
  final String actionUrl;

  /// Constructor
  const PromotionalBanner({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.actionUrl,
  });

  /// Create from JSON
  factory PromotionalBanner.fromJson(Map<String, dynamic> json) {
    return PromotionalBanner(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      actionUrl: json['actionUrl'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'actionUrl': actionUrl,
    };
  }
}

/// App Settings model
class AppSettings {
  /// Theme mode (light, dark, system)
  final String themeMode;

  /// Whether notifications are enabled
  final bool notificationsEnabled;

  /// Whether location tracking is enabled
  final bool locationTrackingEnabled;

  /// Whether email notifications are enabled
  final bool emailNotificationsEnabled;

  /// Whether SMS notifications are enabled
  final bool smsNotificationsEnabled;

  /// App language (default: en)
  final String language;

  /// Constructor
  const AppSettings({
    this.themeMode = 'system',
    this.notificationsEnabled = true,
    this.locationTrackingEnabled = true,
    this.emailNotificationsEnabled = true,
    this.smsNotificationsEnabled = true,
    this.language = 'en',
  });

  /// Create from JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: json['themeMode'] as String? ?? 'system',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      locationTrackingEnabled: json['locationTrackingEnabled'] as bool? ?? true,
      emailNotificationsEnabled:
          json['emailNotificationsEnabled'] as bool? ?? true,
      smsNotificationsEnabled: json['smsNotificationsEnabled'] as bool? ?? true,
      language: json['language'] as String? ?? 'en',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'notificationsEnabled': notificationsEnabled,
      'locationTrackingEnabled': locationTrackingEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'smsNotificationsEnabled': smsNotificationsEnabled,
      'language': language,
    };
  }

  /// Create a copy with modified fields
  AppSettings copyWith({
    String? themeMode,
    bool? notificationsEnabled,
    bool? locationTrackingEnabled,
    bool? emailNotificationsEnabled,
    bool? smsNotificationsEnabled,
    String? language,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locationTrackingEnabled:
          locationTrackingEnabled ?? this.locationTrackingEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      smsNotificationsEnabled:
          smsNotificationsEnabled ?? this.smsNotificationsEnabled,
      language: language ?? this.language,
    );
  }
}

/// Profile Statistics model
class ProfileStats {
  /// Number of bookings
  final int bookingsCount;

  /// Number of wishlist items
  final int wishlistCount;

  /// Number of reviews given
  final int reviewsCount;

  /// Profile completion percentage
  final int profileCompletion;

  /// Constructor
  const ProfileStats({
    this.bookingsCount = 0,
    this.wishlistCount = 0,
    this.reviewsCount = 0,
    this.profileCompletion = 0,
  });

  /// Create from JSON
  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      bookingsCount: json['bookingsCount'] as int? ?? 0,
      wishlistCount: json['wishlistCount'] as int? ?? 0,
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      profileCompletion: json['profileCompletion'] as int? ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'bookingsCount': bookingsCount,
      'wishlistCount': wishlistCount,
      'reviewsCount': reviewsCount,
      'profileCompletion': profileCompletion,
    };
  }
}

// Add these model definitions to lib/shared/models/app_models.dart

/// Offer model
class Offer {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String discountText;
  final bool isExclusive;
  final DateTime? expiryDate;
  final List<String> terms;
  final String? couponCode;

  const Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.discountText,
    this.isExclusive = false,
    this.expiryDate,
    required this.terms,
    this.couponCode,
  });

  /// Create from JSON
  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      discountText: json['discountText'] as String,
      isExclusive: json['isExclusive'] as bool? ?? false,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      terms:
          (json['terms'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      couponCode: json['couponCode'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'discountText': discountText,
      'isExclusive': isExclusive,
      'expiryDate': expiryDate?.toIso8601String(),
      'terms': terms,
      'couponCode': couponCode,
    };
  }
}

/// Coupon model
class Coupon {
  final String id;
  final String code;
  final String title;
  final String description;
  final DateTime? expiryDate;
  final bool isValid;

  const Coupon({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    this.expiryDate,
    this.isValid = true,
  });

  /// Create from JSON
  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      isValid: json['isValid'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'expiryDate': expiryDate?.toIso8601String(),
      'isValid': isValid,
    };
  }
}

/// Referral model
class Referral {
  final String id;
  final String name;
  final DateTime joinedDate;
  final bool isComplete;
  final double bonusAmount;

  const Referral({
    required this.id,
    required this.name,
    required this.joinedDate,
    required this.isComplete,
    required this.bonusAmount,
  });

  /// Create from JSON
  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] as String,
      name: json['name'] as String,
      joinedDate: DateTime.parse(json['joinedDate'] as String),
      isComplete: json['isComplete'] as bool? ?? false,
      bonusAmount: (json['bonusAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'joinedDate': joinedDate.toIso8601String(),
      'isComplete': isComplete,
      'bonusAmount': bonusAmount,
    };
  }
}
