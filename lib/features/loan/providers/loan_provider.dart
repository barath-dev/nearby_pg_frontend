// lib/features/loan/providers/loan_provider.dart
import 'package:flutter/foundation.dart';
import 'package:nearby_pg/shared/models/loan_models.dart';
import '../../../shared/models/app_models.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/cache_service.dart';

/// Loan Provider for managing loan application and calculations
class LoanProvider extends ChangeNotifier {
  // Services
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();

  // State variables
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Loan calculation inputs
  double _loanAmount = 50000.0;
  int _tenureMonths = 12;
  double _monthlyIncome = 30000.0;
  String _employmentType = 'SALARIED';
  String _purpose = 'PG_DEPOSIT';

  // Fixed rates
  final double _interestRate = 12.0; // 12% annual
  final double _processingFeeRate = 2.0; // 2% processing fee
  final double _gstRate = 18.0; // 18% GST

  // Calculation result
  LoanCalculationResult? _calculationResult;

  // Loan applications
  List<LoanApplication> _loanApplications = [];

  // Available options
  final List<int> _tenureOptions = [6, 12, 18, 24, 36, 48, 60];
  final List<String> _employmentTypes = [
    'SALARIED',
    'SELF_EMPLOYED',
    'BUSINESS'
  ];
  final List<String> _loanPurposes = [
    'PG_DEPOSIT',
    'RENT_ADVANCE',
    'PERSONAL_EMERGENCY',
    'EDUCATION',
    'MEDICAL',
    'OTHER'
  ];

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  double get loanAmount => _loanAmount;
  int get tenureMonths => _tenureMonths;
  double get monthlyIncome => _monthlyIncome;
  String get employmentType => _employmentType;
  String get purpose => _purpose;

  double get interestRate => _interestRate;
  double get processingFeeRate => _processingFeeRate;
  double get gstRate => _gstRate;

  LoanCalculationResult? get calculationResult => _calculationResult;
  List<LoanApplication> get loanApplications => _loanApplications;

  List<int> get tenureOptions => _tenureOptions;
  List<String> get employmentTypes => _employmentTypes;
  List<String> get loanPurposes => _loanPurposes;

  // Minimum and maximum loan amounts
  double get minLoanAmount => 5000.0;
  double get maxLoanAmount => 500000.0;

  /// Initialize loan provider
  Future<void> initialize() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      await _loadCachedData();
      await _loadLoanApplications();
      _calculateLoan();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Failed to initialize loan data: ${e.toString()}';
      debugPrint('Error initializing loan provider: $e');
      notifyListeners();
    }
  }

  /// Load cached loan data
  Future<void> _loadCachedData() async {
    try {
      final cachedLoanAmount =
          await _cacheService.getUserPreference<double>('loan_amount');
      final cachedTenure =
          await _cacheService.getUserPreference<int>('loan_tenure');
      final cachedIncome =
          await _cacheService.getUserPreference<double>('monthly_income');
      final cachedEmployment =
          await _cacheService.getUserPreference<String>('employment_type');
      final cachedPurpose =
          await _cacheService.getUserPreference<String>('loan_purpose');

      if (cachedLoanAmount != null) _loanAmount = cachedLoanAmount;
      if (cachedTenure != null) _tenureMonths = cachedTenure;
      if (cachedIncome != null) _monthlyIncome = cachedIncome;
      if (cachedEmployment != null) _employmentType = cachedEmployment;
      if (cachedPurpose != null) _purpose = cachedPurpose;
    } catch (e) {
      debugPrint('Error loading cached loan data: $e');
    }
  }

  /// Load user's loan applications
  Future<void> _loadLoanApplications() async {
    try {
      // In a real app, this would fetch from API
      // For now, create mock data
      _loanApplications = [];
    } catch (e) {
      debugPrint('Error loading loan applications: $e');
    }
  }

  /// Update loan amount
  void updateLoanAmount(double amount) {
    if (amount >= minLoanAmount && amount <= maxLoanAmount) {
      _loanAmount = amount;
      _calculateLoan();
      _saveLoanPreferences();
      notifyListeners();
    }
  }

  /// Update tenure in months
  void updateTenure(int months) {
    if (_tenureOptions.contains(months)) {
      _tenureMonths = months;
      _calculateLoan();
      _saveLoanPreferences();
      notifyListeners();
    }
  }

  /// Update monthly income
  void updateMonthlyIncome(double income) {
    if (income > 0) {
      _monthlyIncome = income;
      _saveLoanPreferences();
      notifyListeners();
    }
  }

  /// Update employment type
  void updateEmploymentType(String type) {
    if (_employmentTypes.contains(type)) {
      _employmentType = type;
      _saveLoanPreferences();
      notifyListeners();
    }
  }

  /// Update loan purpose
  void updatePurpose(String newPurpose) {
    if (_loanPurposes.contains(newPurpose)) {
      _purpose = newPurpose;
      _saveLoanPreferences();
      notifyListeners();
    }
  }

  /// Calculate loan EMI and other details
  void _calculateLoan() {
    _calculationResult = LoanCalculationResult.calculate(
      principalAmount: _loanAmount,
      annualInterestRate: _interestRate,
      tenureMonths: _tenureMonths,
      processingFeeRate: _processingFeeRate,
      gstRate: _gstRate,
    );
  }

  /// Apply for loan
  Future<bool> applyForLoan() async {
    if (_calculationResult == null) {
      _setError('Please calculate loan first');
      return false;
    }

    // Validate eligibility
    if (!_isEligible()) {
      _setError('You are not eligible for this loan amount');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Create loan application
      final application = LoanApplication(
        id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user_id', // Get from auth service
        loanAmount: _loanAmount,
        tenureMonths: _tenureMonths,
        interestRate: _interestRate,
        processingFeeRate: _processingFeeRate,
        gstRate: _gstRate,
        monthlyEMI: _calculationResult!.monthlyEMI,
        totalAmount: _calculationResult!.totalAmount,
        totalInterest: _calculationResult!.totalInterest,
        processingFee: _calculationResult!.processingFee,
        gstAmount: _calculationResult!.gstAmount,
        status: 'SUBMITTED',
        purpose: _purpose,
        monthlyIncome: _monthlyIncome,
        employmentType: _employmentType,
        applicationDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // In a real app, submit to API
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      _loanApplications.insert(0, application);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _setError('Failed to submit loan application: ${e.toString()}');
      notifyListeners();
      return false;
    }
  }

  /// Check loan eligibility
  bool _isEligible() {
    // Basic eligibility criteria
    final maxEligibleAmount =
        _monthlyIncome * 0.4 * _tenureMonths; // 40% of monthly income
    final minIncomeRequired =
        _loanAmount / _tenureMonths / 0.4; // Required monthly income

    return _loanAmount <= maxEligibleAmount &&
        _monthlyIncome >= minIncomeRequired;
  }

  /// Get eligibility amount
  double getMaxEligibleAmount() {
    return _monthlyIncome * 0.4 * _tenureMonths;
  }

  /// Get required monthly income for current loan amount
  double getRequiredMonthlyIncome() {
    return _loanAmount / _tenureMonths / 0.4;
  }

  /// Save loan preferences to cache
  Future<void> _saveLoanPreferences() async {
    try {
      await Future.wait([
        _cacheService.saveUserPreference('loan_amount', _loanAmount),
        _cacheService.saveUserPreference('loan_tenure', _tenureMonths),
        _cacheService.saveUserPreference('monthly_income', _monthlyIncome),
        _cacheService.saveUserPreference('employment_type', _employmentType),
        _cacheService.saveUserPreference('loan_purpose', _purpose),
      ]);
    } catch (e) {
      debugPrint('Error saving loan preferences: $e');
    }
  }

  /// Reset loan calculator
  void resetCalculator() {
    _loanAmount = 50000.0;
    _tenureMonths = 12;
    _monthlyIncome = 30000.0;
    _employmentType = 'SALARIED';
    _purpose = 'PG_DEPOSIT';
    _calculationResult = null;
    _clearError();

    _calculateLoan();
    _saveLoanPreferences();
    notifyListeners();
  }

  /// Refresh loan applications
  Future<void> refreshApplications() async {
    await _loadLoanApplications();
    notifyListeners();
  }

  /// Get loan purpose display name
  String getPurposeDisplayName(String purpose) {
    switch (purpose) {
      case 'PG_DEPOSIT':
        return 'PG Security Deposit';
      case 'RENT_ADVANCE':
        return 'Rent Advance';
      case 'PERSONAL_EMERGENCY':
        return 'Personal Emergency';
      case 'EDUCATION':
        return 'Education';
      case 'MEDICAL':
        return 'Medical Emergency';
      case 'OTHER':
        return 'Other';
      default:
        return 'Personal Loan';
    }
  }

  /// Get employment type display name
  String getEmploymentDisplayName(String type) {
    switch (type) {
      case 'SALARIED':
        return 'Salaried';
      case 'SELF_EMPLOYED':
        return 'Self Employed';
      case 'BUSINESS':
        return 'Business Owner';
      default:
        return 'Salaried';
    }
  }

  /// Get status display name
  String getStatusDisplayName(String status) {
    switch (status) {
      case 'SUBMITTED':
        return 'Under Review';
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      case 'DISBURSED':
        return 'Disbursed';
      case 'CLOSED':
        return 'Closed';
      default:
        return status;
    }
  }

  /// Helper methods for state management
  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = '';
  }
}
