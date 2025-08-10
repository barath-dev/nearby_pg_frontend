// Add these loan models to lib/shared/models/app_models.dart

/// Loan Application model
class LoanApplication {
  /// Unique loan application ID
  final String id;

  /// User ID who applied for loan
  final String userId;

  /// Loan amount requested
  final double loanAmount;

  /// Loan tenure in months
  final int tenureMonths;

  /// Annual interest rate (percentage)
  final double interestRate;

  /// Processing fee (percentage of loan amount)
  final double processingFeeRate;

  /// GST on processing fee (percentage)
  final double gstRate;

  /// Monthly EMI amount
  final double monthlyEMI;

  /// Total amount to be paid
  final double totalAmount;

  /// Total interest amount
  final double totalInterest;

  /// Processing fee amount
  final double processingFee;

  /// GST amount
  final double gstAmount;

  /// Application status
  final String status;

  /// Purpose of loan
  final String purpose;

  /// User's monthly income
  final double monthlyIncome;

  /// Employment type
  final String employmentType;

  /// Application date
  final DateTime applicationDate;

  /// Last update date
  final DateTime updatedAt;

  /// Constructor
  const LoanApplication({
    required this.id,
    required this.userId,
    required this.loanAmount,
    required this.tenureMonths,
    required this.interestRate,
    required this.processingFeeRate,
    required this.gstRate,
    required this.monthlyEMI,
    required this.totalAmount,
    required this.totalInterest,
    required this.processingFee,
    required this.gstAmount,
    required this.status,
    required this.purpose,
    required this.monthlyIncome,
    required this.employmentType,
    required this.applicationDate,
    required this.updatedAt,
  });

  /// Create from JSON
  factory LoanApplication.fromJson(Map<String, dynamic> json) {
    return LoanApplication(
      id: json['id'] as String,
      userId: json['userId'] as String,
      loanAmount: (json['loanAmount'] as num).toDouble(),
      tenureMonths: json['tenureMonths'] as int,
      interestRate: (json['interestRate'] as num).toDouble(),
      processingFeeRate: (json['processingFeeRate'] as num).toDouble(),
      gstRate: (json['gstRate'] as num).toDouble(),
      monthlyEMI: (json['monthlyEMI'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      totalInterest: (json['totalInterest'] as num).toDouble(),
      processingFee: (json['processingFee'] as num).toDouble(),
      gstAmount: (json['gstAmount'] as num).toDouble(),
      status: json['status'] as String,
      purpose: json['purpose'] as String,
      monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
      employmentType: json['employmentType'] as String,
      applicationDate: DateTime.parse(json['applicationDate'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'loanAmount': loanAmount,
      'tenureMonths': tenureMonths,
      'interestRate': interestRate,
      'processingFeeRate': processingFeeRate,
      'gstRate': gstRate,
      'monthlyEMI': monthlyEMI,
      'totalAmount': totalAmount,
      'totalInterest': totalInterest,
      'processingFee': processingFee,
      'gstAmount': gstAmount,
      'status': status,
      'purpose': purpose,
      'monthlyIncome': monthlyIncome,
      'employmentType': employmentType,
      'applicationDate': applicationDate.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  LoanApplication copyWith({
    String? id,
    String? userId,
    double? loanAmount,
    int? tenureMonths,
    double? interestRate,
    double? processingFeeRate,
    double? gstRate,
    double? monthlyEMI,
    double? totalAmount,
    double? totalInterest,
    double? processingFee,
    double? gstAmount,
    String? status,
    String? purpose,
    double? monthlyIncome,
    String? employmentType,
    DateTime? applicationDate,
    DateTime? updatedAt,
  }) {
    return LoanApplication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      loanAmount: loanAmount ?? this.loanAmount,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      interestRate: interestRate ?? this.interestRate,
      processingFeeRate: processingFeeRate ?? this.processingFeeRate,
      gstRate: gstRate ?? this.gstRate,
      monthlyEMI: monthlyEMI ?? this.monthlyEMI,
      totalAmount: totalAmount ?? this.totalAmount,
      totalInterest: totalInterest ?? this.totalInterest,
      processingFee: processingFee ?? this.processingFee,
      gstAmount: gstAmount ?? this.gstAmount,
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      employmentType: employmentType ?? this.employmentType,
      applicationDate: applicationDate ?? this.applicationDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Loan Calculator Result model
class LoanCalculationResult {
  /// Principal loan amount
  final double principalAmount;

  /// Annual interest rate
  final double interestRate;

  /// Loan tenure in months
  final int tenureMonths;

  /// Monthly EMI amount
  final double monthlyEMI;

  /// Total amount to be paid
  final double totalAmount;

  /// Total interest amount
  final double totalInterest;

  /// Processing fee
  final double processingFee;

  /// GST on processing fee
  final double gstAmount;

  /// Net amount received (after deductions)
  final double netAmount;

  /// Constructor
  const LoanCalculationResult({
    required this.principalAmount,
    required this.interestRate,
    required this.tenureMonths,
    required this.monthlyEMI,
    required this.totalAmount,
    required this.totalInterest,
    required this.processingFee,
    required this.gstAmount,
    required this.netAmount,
  });

  /// EMI calculation formula
  /// EMI = [P x R x (1+R)^N] / [(1+R)^N-1]
  /// where P = Principal, R = Monthly interest rate, N = Number of months
  factory LoanCalculationResult.calculate({
    required double principalAmount,
    required double annualInterestRate,
    required int tenureMonths,
    double processingFeeRate = 2.0, // 2% processing fee
    double gstRate = 18.0, // 18% GST
  }) {
    final monthlyRate = annualInterestRate / (12 * 100);
    final emi = principalAmount *
        monthlyRate *
        (1 + monthlyRate) *
        tenureMonths /
        (((1 + monthlyRate) * tenureMonths) - 1);

    final totalAmount = emi * tenureMonths;
    final totalInterest = totalAmount - principalAmount;
    final processingFee = principalAmount * processingFeeRate / 100;
    final gstAmount = processingFee * gstRate / 100;
    final netAmount = principalAmount - processingFee - gstAmount;

    return LoanCalculationResult(
      principalAmount: principalAmount,
      interestRate: annualInterestRate,
      tenureMonths: tenureMonths,
      monthlyEMI: emi,
      totalAmount: totalAmount,
      totalInterest: totalInterest,
      processingFee: processingFee,
      gstAmount: gstAmount,
      netAmount: netAmount,
    );
  }
}
