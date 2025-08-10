// lib/features/loan/screens/loan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../../core/theme/app_theme.dart';
import '../providers/loan_provider.dart';
import '../../../shared/models/app_models.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LoanProvider>();
      provider.initialize();
      _updateControllers(provider);
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  void _updateControllers(LoanProvider provider) {
    _loanAmountController.text = provider.loanAmount.toInt().toString();
    _incomeController.text = provider.monthlyIncome.toInt().toString();
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    _incomeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Consumer<LoanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.calculationResult == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildLoanCalculatorCard(provider),
                        const SizedBox(height: 20),
                        if (provider.calculationResult != null) ...[
                          _buildCalculationResultCard(provider),
                          const SizedBox(height: 20),
                          _buildEligibilityCard(provider),
                          const SizedBox(height: 20),
                          _buildActionButtons(provider),
                        ],
                        const SizedBox(height: 20),
                        _buildFeaturesCard(),
                        const SizedBox(
                            height: 100), // Extra space for floating button
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Quick Loan',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.deepCharcoal,
                fontWeight: FontWeight.w700,
              ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppTheme.emeraldGreen.withOpacity(0.02),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.emeraldGreen,
                              AppTheme.emeraldGreen.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'INSTANT APPROVAL',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get loan up to ₹5 Lakhs at 12% interest',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.gray600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoanCalculatorCard(LoanProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calculate,
                    color: AppTheme.emeraldGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loan Calculator',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepCharcoal,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Loan Amount Input
            _buildInputField(
              label: 'Loan Amount',
              controller: _loanAmountController,
              prefix: '₹',
              hint:
                  'Enter amount (${provider.minLoanAmount.toInt()} - ${provider.maxLoanAmount.toInt()})',
              onChanged: (value) {
                final amount = double.tryParse(value);
                if (amount != null) {
                  provider.updateLoanAmount(amount);
                }
              },
            ),

            const SizedBox(height: 20),

            // Tenure Selection
            _buildTenureSelector(provider),

            const SizedBox(height: 20),

            // Monthly Income Input
            _buildInputField(
              label: 'Monthly Income',
              controller: _incomeController,
              prefix: '₹',
              hint: 'Enter your monthly income',
              onChanged: (value) {
                final income = double.tryParse(value);
                if (income != null) {
                  provider.updateMonthlyIncome(income);
                }
              },
            ),

            const SizedBox(height: 20),

            // Employment Type
            _buildDropdownField(
              label: 'Employment Type',
              value: provider.employmentType,
              items: provider.employmentTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(provider.getEmploymentDisplayName(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.updateEmploymentType(value);
                }
              },
            ),

            const SizedBox(height: 20),

            // Loan Purpose
            _buildDropdownField(
              label: 'Loan Purpose',
              value: provider.purpose,
              items: provider.loanPurposes.map((purpose) {
                return DropdownMenuItem(
                  value: purpose,
                  child: Text(provider.getPurposeDisplayName(purpose)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.updatePurpose(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? prefix,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            prefixStyle: const TextStyle(
              color: AppTheme.emeraldGreen,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: AppTheme.gray50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.emeraldGreen,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.gray50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.emeraldGreen,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTenureSelector(LoanProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loan Tenure',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: provider.tenureOptions.map((months) {
            final isSelected = provider.tenureMonths == months;
            return GestureDetector(
              onTap: () => provider.updateTenure(months),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.emeraldGreen : AppTheme.gray100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected ? AppTheme.emeraldGreen : Colors.transparent,
                  ),
                ),
                child: Text(
                  '${months} months',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.deepCharcoal,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCalculationResultCard(LoanProvider provider) {
    final result = provider.calculationResult!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.emeraldGreen,
            AppTheme.emeraldGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.emeraldGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Loan Calculation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Monthly EMI - Highlighted
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly EMI',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '₹${result.monthlyEMI.toInt()}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Other details
            _buildResultRow(
                'Principal Amount', '₹${result.principalAmount.toInt()}'),
            _buildResultRow(
                'Interest Rate', '${result.interestRate}% per annum'),
            _buildResultRow(
                'Total Interest', '₹${result.totalInterest.toInt()}'),
            _buildResultRow('Processing Fee (${provider.processingFeeRate}%)',
                '₹${result.processingFee.toInt()}'),
            _buildResultRow(
                'GST (${provider.gstRate}%)', '₹${result.gstAmount.toInt()}'),

            const Divider(color: Colors.white38, height: 24),

            _buildResultRow(
              'Total Amount',
              '₹${result.totalAmount.toInt()}',
              isTotal: true,
            ),
            _buildResultRow(
              'Amount You Receive',
              '₹${result.netAmount.toInt()}',
              isHighlighted: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value,
      {bool isTotal = false, bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isTotal || isHighlighted ? 16 : 14,
              fontWeight: isTotal || isHighlighted
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTotal || isHighlighted ? 16 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityCard(LoanProvider provider) {
    final maxEligible = provider.getMaxEligibleAmount();
    final requiredIncome = provider.getRequiredMonthlyIncome();
    final isEligible = provider.loanAmount <= maxEligible;

    return Container(
      decoration: BoxDecoration(
        color: isEligible ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEligible ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEligible ? Icons.check_circle : Icons.warning,
                  color: isEligible ? Colors.green[600] : Colors.orange[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isEligible ? 'Eligible' : 'Check Eligibility',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            isEligible ? Colors.green[800] : Colors.orange[800],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isEligible
                  ? 'Great! You are eligible for this loan amount.'
                  : 'Your maximum eligible amount is ₹${maxEligible.toInt()}',
              style: TextStyle(
                color: isEligible ? Colors.green[700] : Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!isEligible) ...[
              const SizedBox(height: 8),
              Text(
                'Required monthly income: ₹${requiredIncome.toInt()}',
                style: TextStyle(
                  color: Colors.orange[600],
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(LoanProvider provider) {
    return Column(
      children: [
        // Apply for Loan Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed:
                provider.isLoading ? null : () => _applyForLoan(provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emeraldGreen,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: AppTheme.emeraldGreen.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: provider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Apply for Loan',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 12),

        // Download Agreement Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => _downloadAgreement(provider),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.emeraldGreen, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.download,
                    color: AppTheme.emeraldGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Download Agreement',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.emeraldGreen,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Reset Button
        TextButton(
          onPressed: () => provider.resetCalculator(),
          child: Text(
            'Reset Calculator',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.gray600,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why Choose Our Loan?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
            ),
            const SizedBox(height: 20),
            _buildFeatureItem(
              icon: Icons.flash_on,
              title: 'Instant Approval',
              description: 'Get approval within minutes',
            ),
            _buildFeatureItem(
              icon: Icons.percent,
              title: 'Low Interest Rate',
              description: 'Starting from 12% per annum',
            ),
            _buildFeatureItem(
              icon: Icons.security,
              title: 'Secure & Safe',
              description: 'Your data is completely secure',
            ),
            _buildFeatureItem(
              icon: Icons.support_agent,
              title: '24/7 Support',
              description: 'Round the clock customer support',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.emeraldGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.emeraldGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepCharcoal,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.gray600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _applyForLoan(LoanProvider provider) async {
    final success = await provider.applyForLoan();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Loan application submitted successfully!'),
                ),
              ],
            ),
            backgroundColor: AppTheme.emeraldGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(provider.errorMessage),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _downloadAgreement(LoanProvider provider) {
    // In a real app, this would download/generate a PDF agreement
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.download_done, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text('Loan agreement downloaded successfully!'),
            ),
          ],
        ),
        backgroundColor: AppTheme.emeraldGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
