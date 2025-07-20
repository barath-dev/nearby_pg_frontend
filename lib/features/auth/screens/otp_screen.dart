import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_service.dart';

/// Enhanced OTP verification screen with improved UI and UX
class OTPVerificationScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const OTPVerificationScreen({super.key, required this.arguments});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  bool _canResend = false;
  int _resendTimer = 30;
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String get phoneNumber => widget.arguments['phoneNumber'] ?? '';
  bool get isSignup => widget.arguments['isSignup'] ?? false;
  String get name => widget.arguments['name'] ?? '';
  String get email => widget.arguments['email'] ?? '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startResendTimer();
    _initializeFocusNodes();

    // Auto-focus on first OTP field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_otpFocusNodes.isNotEmpty) {
        FocusScope.of(context).requestFocus(_otpFocusNodes.first);
      }
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  void _initializeFocusNodes() {
    // Add listeners to automatically advance focus
    for (int i = 0; i < _otpFocusNodes.length - 1; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.length == 1) {
          _otpFocusNodes[i + 1].requestFocus();
        }
      });
    }

    // Add listener to last field
    _otpControllers.last.addListener(() {
      if (_otpControllers.last.text.length == 1) {
        FocusScope.of(context).unfocus();
        // Check if all fields are filled
        _checkAndVerifyOTP();
      }
    });
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();

    for (final controller in _otpControllers) {
      controller.dispose();
    }

    for (final node in _otpFocusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  void _checkAndVerifyOTP() {
    if (_otpControllers.every((controller) => controller.text.length == 1)) {
      _verifyOTP();
    }
  }

  void _handleOTPInput(String value, int index) {
    // Handle digit input
    if (value.isNotEmpty) {
      if (value.length > 1) {
        // If pasting multiple digits
        _otpControllers[index].text = value[0];

        // Distribute remaining digits
        for (
          int i = 1;
          i < value.length && index + i < _otpControllers.length;
          i++
        ) {
          _otpControllers[index + i].text = value[i];
        }

        // Focus on the next empty field or last field
        for (int i = index + 1; i < _otpControllers.length; i++) {
          if (_otpControllers[i].text.isEmpty) {
            FocusScope.of(context).requestFocus(_otpFocusNodes[i]);
            return;
          }
        }

        // If all filled, focus on last field
        FocusScope.of(context).requestFocus(_otpFocusNodes[5]);
      } else if (index < 5) {
        // Single digit entry - focus next field
        FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
      } else {
        // Last field filled
        FocusScope.of(context).unfocus();
        _checkAndVerifyOTP();
      }
    } else if (index > 0) {
      // Backspace pressed on empty field - go back
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      _showErrorSnackBar('Please enter complete OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // Navigate to appropriate screen based on signup/login
        NavigationService.navigateToHome();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSignup
                  ? 'Account created successfully!'
                  : 'Logged in successfully!',
            ),
            backgroundColor: AppTheme.emeraldGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Verification failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendTimer = 30;
    });

    _startResendTimer();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('OTP sent successfully!'),
            backgroundColor: AppTheme.emeraldGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to resend OTP: ${e.toString()}');

        setState(() {
          _canResend = true;
          _resendTimer = 0;
        });
        _timer.cancel();
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _goBack() {
    // Clear OTP fields before going back
    for (final controller in _otpControllers) {
      controller.clear();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.emeraldGreen),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          // Unfocus when tapping outside
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Header
                  _buildHeader(),
                  const SizedBox(height: 40),

                  // OTP Input
                  _buildOTPInput(),
                  const SizedBox(height: 32),

                  // Verify Button
                  _buildVerifyButton(),
                  const SizedBox(height: 24),

                  // Resend OTP
                  _buildResendSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build header with icon and text
  Widget _buildHeader() {
    return Column(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.emeraldGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.sms_rounded,
            size: 48,
            color: AppTheme.emeraldGreen,
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          'Verify Phone Number',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.deepCharcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        // Subtitle with phone number
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.gray600),
            children: [
              const TextSpan(text: 'We\'ve sent a 6-digit code to\n'),
              TextSpan(
                text: '+91 $phoneNumber',
                style: TextStyle(
                  color: AppTheme.emeraldGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build OTP input fields
  Widget _buildOTPInput() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Enter OTP Code',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 24),

          // OTP input fields
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return _buildOTPDigitField(index);
            }),
          ),
        ],
      ),
    );
  }

  /// Build individual OTP digit field
  Widget _buildOTPDigitField(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.deepCharcoal,
        ),
        onChanged: (value) => _handleOTPInput(value, index),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppTheme.gray50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.gray300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.gray300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.emeraldGreen, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  /// Build verify button
  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.emeraldGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.gray300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: AppTheme.emeraldGreen.withOpacity(0.3),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  'Verify & Continue',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  /// Build resend section
  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          'Didn\'t receive the code?',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
        ),
        const SizedBox(height: 8),

        GestureDetector(
          onTap: _canResend ? _resendOTP : null,
          child: Text(
            _canResend ? 'Resend OTP' : 'Resend in ${_resendTimer}s',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: _canResend ? AppTheme.emeraldGreen : AppTheme.gray400,
            ),
          ),
        ),

        if (isSignup) ...[
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: Divider(color: AppTheme.gray300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Account Info',
                  style: TextStyle(
                    color: AppTheme.gray500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppTheme.gray300)),
            ],
          ),
          const SizedBox(height: 16),

          // User info summary (for signup)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.emeraldGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.emeraldGreen.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                _buildInfoRow('Name', name),
                const SizedBox(height: 8),
                _buildInfoRow('Phone', '+91 $phoneNumber'),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Email', email),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build info row for user details (signup flow)
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              color: AppTheme.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.deepCharcoal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
