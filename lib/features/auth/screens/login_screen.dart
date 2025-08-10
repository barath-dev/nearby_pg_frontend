import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:nearby_pg/core/constants/app_constants.dart';
import 'package:nearby_pg/core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();

  // State variables
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _isFormValid = false;

  // Animation controllers
  late AnimationController _primaryAnimationController;
  late AnimationController _secondaryAnimationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _errorAnimationController;

  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _cardAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _socialButtonsAnimation;
  late Animation<double> _errorShakeAnimation;

  // Input decoration focus animation
  late Animation<double> _inputFocusAnimation;
  bool _isInputFocused = false;

  // Error handling
  String? _errorMessage;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupListeners();
    _preloadAssets();
  }

  void _setupAnimations() {
    // Primary animation for main entrance
    _primaryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Secondary animation for interactive elements
    _secondaryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Button animation controller
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Error animation controller
    _errorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Background gradient animation
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _primaryAnimationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Card entrance animation
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _primaryAnimationController,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Logo slide animation
    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _primaryAnimationController,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Form fade animation
    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _secondaryAnimationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Button scale animation
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Social buttons animation
    _socialButtonsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _secondaryAnimationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Input focus animation
    _inputFocusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _secondaryAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Error shake animation
    _errorShakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _errorAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animations
    _primaryAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _secondaryAnimationController.forward();
      }
    });
  }

  void _setupListeners() {
    _phoneController.addListener(_validateForm);
    _phoneFocusNode.addListener(_handleFocusChange);
  }

  void _preloadAssets() {
    // Preload any assets here if needed
  }

  void _handleFocusChange() {
    setState(() {
      _isInputFocused = _phoneFocusNode.hasFocus;
    });

    if (_isInputFocused) {
      _secondaryAnimationController.forward();
    }
  }

  void _validateForm() {
    final isValid = _phoneController.text.length == 10 &&
        RegExp(r'^[6-9]\d{9}$').hasMatch(_phoneController.text);

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
        _clearError();
      });
    }
  }

  void _clearError() {
    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    _primaryAnimationController.dispose();
    _secondaryAnimationController.dispose();
    _buttonAnimationController.dispose();
    _errorAnimationController.dispose();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Enter a valid 10-digit number';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Enter a valid Indian mobile number';
    }
    return null;
  }

  void _handleLogin() async {
    // Clear any existing errors
    _clearError();

    if (!_formKey.currentState!.validate()) {
      _showError('Please check your phone number');
      return;
    }

    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
    });

    // Button animation
    _buttonAnimationController.forward();

    try {
      // Simulate API call with realistic delay
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Reset button animation
        _buttonAnimationController.reverse();

        // Success haptic feedback
        HapticFeedback.lightImpact();

        // Navigate to OTP screen
        try {
          await context.pushNamed(
            AppConstants.otpRoute,
            extra: {
              'phoneNumber': _phoneController.text,
              'isSignup': false,
              'rememberMe': _rememberMe,
            },
          );
        } catch (e) {
          // Fallback navigation
          context.go('/');
          _showSuccessMessage('Welcome back! Login successful.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _buttonAnimationController.reverse();
        _showError('Unable to send OTP. Please try again.');
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });

    // Error haptic feedback
    HapticFeedback.mediumImpact();

    // Trigger shake animation
    _errorAnimationController.reset();
    _errorAnimationController.forward();
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.emeraldGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleSocialLogin(String provider) async {
    HapticFeedback.selectionClick();

    // Simulate social login
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider login will be available soon'),
        backgroundColor: AppTheme.deepCharcoal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 100;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.emeraldGreen
                      .withOpacity(0.1 * _backgroundAnimation.value),
                  Colors.white,
                  AppTheme.emeraldGreen
                      .withOpacity(0.05 * _backgroundAnimation.value),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 40,
                  bottom: keyboardHeight + 40,
                ),
                child: Column(
                  children: [
                    // Logo Section
                    _buildLogoSection(isKeyboardVisible),

                    // Spacer
                    const Spacer(flex: 1),

                    // Main Card
                    _buildMainCard(),

                    // Social Login Section
                    _buildSocialLoginSection(),

                    // Spacer
                    const Spacer(flex: 2),

                    // Footer
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoSection(bool isKeyboardVisible) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isKeyboardVisible ? 60 : 120,
      child: SlideTransition(
        position: _logoSlideAnimation,
        child: FadeTransition(
          opacity: _cardAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.emeraldGreen.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.home_work_rounded,
                  size: isKeyboardVisible ? 28 : 36,
                  color: AppTheme.emeraldGreen,
                ),
              ),

              if (!isKeyboardVisible) ...[
                const SizedBox(height: 16),
                // App Name
                Text(
                  'NEARBY PG',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.emeraldGreen,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return ScaleTransition(
      scale: _cardAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppTheme.emeraldGreen.withOpacity(0.05),
              blurRadius: 60,
              offset: const Offset(0, 30),
              spreadRadius: 10,
            ),
          ],
        ),
        child: FadeTransition(
          opacity: _formFadeAnimation,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Text
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.deepCharcoal,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone number to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.gray600,
                      ),
                ),
                const SizedBox(height: 32),

                // Phone Input
                _buildPhoneInput(),

                // Error Message
                if (_hasError) _buildErrorMessage(),

                const SizedBox(height: 24),

                // Remember Me
                _buildRememberMeToggle(),

                const SizedBox(height: 32),

                // Login Button
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return AnimatedBuilder(
      animation: _inputFocusAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isInputFocused
                ? [
                    BoxShadow(
                      color: AppTheme.emeraldGreen.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _validatePhoneNumber,
            onChanged: (_) => _validateForm(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your mobile number',
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 16, right: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '+91',
                  style: TextStyle(
                    color: AppTheme.emeraldGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              suffixIcon: _isFormValid
                  ? Container(
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  : null,
              counterText: '',
              filled: true,
              fillColor: AppTheme.gray50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppTheme.emeraldGreen,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppTheme.error,
                  width: 2,
                ),
              ),
              labelStyle: TextStyle(
                color:
                    _isInputFocused ? AppTheme.emeraldGreen : AppTheme.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage() {
    return AnimatedBuilder(
      animation: _errorShakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            10 *
                _errorShakeAnimation.value *
                (1 - _errorShakeAnimation.value) *
                (_errorShakeAnimation.value > 0.5 ? -1 : 1),
            0,
          ),
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.error.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppTheme.error,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRememberMeToggle() {
    return Row(
      children: [
        Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (value) {
              setState(() {
                _rememberMe = value ?? false;
              });
              HapticFeedback.selectionClick();
            },
            activeColor: AppTheme.emeraldGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _rememberMe = !_rememberMe;
              });
              HapticFeedback.selectionClick();
            },
            child: Text(
              'Remember this device',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.deepCharcoal,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            // Handle forgot password
            _handleSocialLogin('Forgot Password');
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot Number?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.emeraldGreen,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: _isFormValid && !_isLoading
                    ? [
                        AppTheme.emeraldGreen,
                        AppTheme.emeraldGreen.withOpacity(0.8),
                      ]
                    : [
                        AppTheme.gray300,
                        AppTheme.gray300,
                      ],
              ),
              boxShadow: _isFormValid && !_isLoading
                  ? [
                      BoxShadow(
                        color: AppTheme.emeraldGreen.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [],
            ),
            child: ElevatedButton(
              onPressed: _isFormValid && !_isLoading ? _handleLogin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Send OTP',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialLoginSection() {
    return FadeTransition(
      opacity: _socialButtonsAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_socialButtonsAnimation),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Divider
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppTheme.gray300,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'or continue with',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.gray600,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppTheme.gray300,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Social Login Buttons
            Row(
              children: [
                Expanded(
                  child: _buildSocialButton(
                    'Google',
                    Icons.g_mobiledata_rounded,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSocialButton(
                    'Apple',
                    Icons.apple,
                    Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String provider, IconData icon, Color color) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleSocialLogin(provider),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                provider,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.deepCharcoal,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _socialButtonsAnimation,
      child: Column(
        children: [
          Text(
            'Don\'t have an account?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.gray600,
                ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    try {
                      context.pushNamed(AppConstants.signupRoute);
                    } catch (e) {
                      _showError('Navigation error. Please try again.');
                    }
                  },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Create Account',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.emeraldGreen,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Navigation Helper with additional methods
class EnhancedNavigationHelper {
  static void navigateToLogin(BuildContext context) {
    context.goNamed(AppConstants.loginRoute);
  }

  static void navigateToSignup(BuildContext context) {
    context.pushNamed(AppConstants.signupRoute);
  }

  static void navigateToForgotPassword(BuildContext context) {
    // Navigate to forgot password screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Forgot password feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void navigateToHelp(BuildContext context) {
    // Navigate to help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help & Support coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Enhanced navigation extension
extension EnhancedNavigation on BuildContext {
  void goToLogin() {
    goNamed(AppConstants.loginRoute);
  }

  void goToSignup() {
    pushNamed(AppConstants.signupRoute);
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.emeraldGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
