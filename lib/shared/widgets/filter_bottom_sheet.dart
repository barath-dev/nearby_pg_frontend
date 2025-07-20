import 'package:flutter/material.dart';
import '../../shared/models/app_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Advanced filter bottom sheet for search functionality
class FilterBottomSheet extends StatefulWidget {
  final SearchFilter initialFilters;
  final Function(SearchFilter) onFiltersApplied;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.onFiltersApplied,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late SearchFilter _currentFilters;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildBudgetSection(),
                const SizedBox(height: 24),
                _buildGenderSection(),
                const SizedBox(height: 24),
                _buildRoomTypeSection(),
                const SizedBox(height: 24),
                _buildAmenitiesSection(),
                const SizedBox(height: 24),
                _buildMealsSection(),
                const SizedBox(height: 24),
                _buildRatingSection(),
                const SizedBox(height: 24),
                _buildDistanceSection(),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.gray200)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Filters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text('Clear All'),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget Range',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: RangeValues(
            _currentFilters.minBudget ?? AppConstants.minBudgetRange,
            _currentFilters.maxBudget ?? AppConstants.maxBudgetRange,
          ),
          min: AppConstants.minBudgetRange,
          max: AppConstants.maxBudgetRange,
          divisions: 50,
          labels: RangeLabels(
            '₹${(_currentFilters.minBudget ?? AppConstants.minBudgetRange).toInt()}',
            '₹${(_currentFilters.maxBudget ?? AppConstants.maxBudgetRange).toInt()}',
          ),
          activeColor: AppTheme.emeraldGreen,
          inactiveColor: AppTheme.gray300,
          onChanged: (values) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(
                minBudget: values.start,
                maxBudget: values.end,
              );
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₹${(_currentFilters.minBudget ?? AppConstants.minBudgetRange).toInt()}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.emeraldGreen,
              ),
            ),
            Text(
              '₹${(_currentFilters.maxBudget ?? AppConstants.maxBudgetRange).toInt()}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.emeraldGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender Preference',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              GenderPreference.values.map((gender) {
                final isSelected = _currentFilters.genderPreference == gender;
                return FilterChip(
                  label: Text(_getGenderDisplayName(gender)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _currentFilters = _currentFilters.copyWith(
                        genderPreference: selected ? gender : null,
                      );
                    });
                  },
                  selectedColor: AppTheme.lightMint,
                  checkmarkColor: AppTheme.emeraldGreen,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color:
                          isSelected ? AppTheme.emeraldGreen : AppTheme.gray300,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildRoomTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Room Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              RoomType.values.where((type) => type != RoomType.other).map((
                roomType,
              ) {
                final isSelected =
                    _currentFilters.roomTypes?.contains(roomType) ?? false;
                return FilterChip(
                  label: Text(_getRoomTypeDisplayName(roomType)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      final currentRoomTypes = List<RoomType>.from(
                        _currentFilters.roomTypes ?? [],
                      );
                      if (selected) {
                        currentRoomTypes.add(roomType);
                      } else {
                        currentRoomTypes.remove(roomType);
                      }
                      _currentFilters = _currentFilters.copyWith(
                        roomTypes:
                            currentRoomTypes.isEmpty ? null : currentRoomTypes,
                      );
                    });
                  },
                  selectedColor: AppTheme.lightMint,
                  checkmarkColor: AppTheme.emeraldGreen,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color:
                          isSelected ? AppTheme.emeraldGreen : AppTheme.gray300,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Required Amenities',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              AmenityType.values.where((type) => type != AmenityType.other).map(
                (amenity) {
                  final isSelected =
                      _currentFilters.requiredAmenities?.contains(amenity) ??
                      false;
                  return FilterChip(
                    label: Text(_getAmenityDisplayName(amenity)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        final currentAmenities = List<AmenityType>.from(
                          _currentFilters.requiredAmenities ?? [],
                        );
                        if (selected) {
                          currentAmenities.add(amenity);
                        } else {
                          currentAmenities.remove(amenity);
                        }
                        _currentFilters = _currentFilters.copyWith(
                          requiredAmenities:
                              currentAmenities.isEmpty
                                  ? null
                                  : currentAmenities,
                        );
                      });
                    },
                    selectedColor: AppTheme.lightMint,
                    checkmarkColor: AppTheme.emeraldGreen,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color:
                            isSelected
                                ? AppTheme.emeraldGreen
                                : AppTheme.gray300,
                      ),
                    ),
                  );
                },
              ).toList(),
        ),
      ],
    );
  }

  Widget _buildMealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meals',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilterChip(
                label: const Text('Meals Included'),
                selected: _currentFilters.mealsIncluded == true,
                onSelected: (selected) {
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(
                      mealsIncluded: selected ? true : null,
                    );
                  });
                },
                selectedColor: AppTheme.lightMint,
                checkmarkColor: AppTheme.emeraldGreen,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color:
                        _currentFilters.mealsIncluded == true
                            ? AppTheme.emeraldGreen
                            : AppTheme.gray300,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterChip(
                label: const Text('No Meals'),
                selected: _currentFilters.mealsIncluded == false,
                onSelected: (selected) {
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(
                      mealsIncluded: selected ? false : null,
                    );
                  });
                },
                selectedColor: AppTheme.lightMint,
                checkmarkColor: AppTheme.emeraldGreen,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color:
                        _currentFilters.mealsIncluded == false
                            ? AppTheme.emeraldGreen
                            : AppTheme.gray300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minimum Rating',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Slider(
          value: _currentFilters.minRating ?? 0.0,
          min: 0.0,
          max: 5.0,
          divisions: 10,
          label: (_currentFilters.minRating ?? 0.0).toStringAsFixed(1),
          activeColor: AppTheme.emeraldGreen,
          inactiveColor: AppTheme.gray300,
          onChanged: (value) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(
                minRating: value == 0.0 ? null : value,
              );
            });
          },
        ),
        Text(
          'Minimum ${(_currentFilters.minRating ?? 0.0).toStringAsFixed(1)} stars',
          style: const TextStyle(
            color: AppTheme.emeraldGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Maximum Distance',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Slider(
          value: _currentFilters.maxDistance ?? AppConstants.maxSearchRadius,
          min: 1.0,
          max: AppConstants.maxSearchRadius,
          divisions: 49,
          label:
              '${(_currentFilters.maxDistance ?? AppConstants.maxSearchRadius).toInt()} km',
          activeColor: AppTheme.emeraldGreen,
          inactiveColor: AppTheme.gray300,
          onChanged: (value) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(maxDistance: value);
            });
          },
        ),
        Text(
          'Within ${(_currentFilters.maxDistance ?? AppConstants.maxSearchRadius).toInt()} km',
          style: const TextStyle(
            color: AppTheme.emeraldGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.gray200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clearAllFilters,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.emeraldGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Reset'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _currentFilters = const SearchFilter();
    });
  }

  void _applyFilters() {
    widget.onFiltersApplied(_currentFilters);
    Navigator.pop(context);
  }

  String _getGenderDisplayName(GenderPreference gender) {
    switch (gender) {
      case GenderPreference.male:
        return 'Male';
      case GenderPreference.female:
        return 'Female';
      case GenderPreference.coEd:
        return 'Co-ed';
      case GenderPreference.any:
        return 'Any';
    }
  }

  String _getRoomTypeDisplayName(RoomType roomType) {
    switch (roomType) {
      case RoomType.single:
        return 'Single';
      case RoomType.double:
        return 'Double';
      case RoomType.triple:
        return 'Triple';
      case RoomType.dormitory:
        return 'Dormitory';
      case RoomType.other:
        return 'Other';
    }
  }

  String _getAmenityDisplayName(AmenityType amenity) {
    switch (amenity) {
      case AmenityType.wifi:
        return 'Wi-Fi';
      case AmenityType.ac:
        return 'AC';
      case AmenityType.meals:
        return 'Meals';
      case AmenityType.laundry:
        return 'Laundry';
      case AmenityType.parking:
        return 'Parking';
      case AmenityType.gym:
        return 'Gym';
      case AmenityType.security:
        return 'Security';
      case AmenityType.housekeeping:
        return 'Housekeeping';
      case AmenityType.hotWater:
        return 'Hot Water';
      case AmenityType.powerBackup:
        return 'Power Backup';
      case AmenityType.cctv:
        return 'CCTV';
      case AmenityType.studyRoom:
        return 'Study Room';
      case AmenityType.recreationRoom:
        return 'Recreation Room';
      case AmenityType.other:
        return 'Other';
    }
  }
}
