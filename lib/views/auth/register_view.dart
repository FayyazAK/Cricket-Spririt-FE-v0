import 'package:flutter/material.dart';

import '../../app/themes/themes.dart';
import '../../services/api/api_service.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _submitted = false;
  bool _isOtpSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final email = value.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'At least 6 characters';
    return null;
  }

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) return 'OTP is required';
    if (value.length != 6) return 'OTP must be 6 digits';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'OTP must be numbers only';
    return null;
  }

  Future<void> _attemptRegister() async {
    setState(() => _submitted = true);
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _isLoading = true);

    try {
      final response = await apiService.register(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
        _isOtpSent = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'OTP sent to ${_emailController.text}. Please check your email.',
            ),
            backgroundColor: CricketSpiritColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: CricketSpiritColors.error,
          ),
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await apiService.verifyEmail(
        email: _emailController.text.trim(),
        otp: _otpController.text,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Email verified successfully! You can now login.',
            ),
            backgroundColor: CricketSpiritColors.primary,
          ),
        );

        // Navigate back to login
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: CricketSpiritColors.error,
          ),
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);

    try {
      final response = await apiService.resendVerificationOtp(
        email: _emailController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'New OTP sent to your email',
            ),
            backgroundColor: CricketSpiritColors.primary,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: CricketSpiritColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account', style: textTheme.headlineSmall),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _isOtpSent ? _buildOtpVerificationForm() : _buildRegistrationForm(),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      autovalidateMode:
          _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Join Cricket Spirit', style: textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Create your account with email verification.',
            style: textTheme.bodyMedium
                ?.copyWith(color: CricketSpiritColors.mutedForeground),
          ),
          const SizedBox(height: 32),
          // Email Field
          TextFormField(
            controller: _emailController,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          // Name Field
          TextFormField(
            controller: _nameController,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'John Doe',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: _validateName,
          ),
          const SizedBox(height: 16),
          // Password Field
          TextFormField(
            controller: _passwordController,
            enabled: !_isLoading,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: 'Create a strong password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 24),
          // Register Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _attemptRegister,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          CricketSpiritColors.primaryForeground,
                        ),
                      ),
                    )
                  : const Text('Send Verification Code'),
            ),
          ),
          const SizedBox(height: 12),
          // Google Sign In
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Google sign-in not implemented yet.'),
                        ),
                      );
                    },
              icon: const Icon(Icons.login),
              label: const Text('Continue with Google'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Already have account
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Already have an account? Login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerificationForm() {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Icon
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: CricketSpiritColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.email_outlined,
              size: 40,
              color: CricketSpiritColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Title
        Text(
          'Email Verification',
          style: textTheme.displaySmall?.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Subtitle
        Text(
          'We\'ve sent a 6-digit verification code to',
          style: textTheme.bodyMedium?.copyWith(
            color: CricketSpiritColors.mutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _emailController.text,
          style: textTheme.titleMedium?.copyWith(
            color: CricketSpiritColors.primary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // OTP Input
        TextFormField(
          controller: _otpController,
          enabled: !_isLoading,
          decoration: const InputDecoration(
            labelText: 'Enter OTP',
            hintText: '123456',
            prefixIcon: Icon(Icons.pin_outlined),
            helperText: 'OTP expires in 15 minutes',
          ),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: textTheme.displaySmall?.copyWith(
            fontSize: 32,
            letterSpacing: 8,
          ),
          maxLength: 6,
          validator: _validateOtp,
        ),
        const SizedBox(height: 24),
        // Verify Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        CricketSpiritColors.primaryForeground,
                      ),
                    ),
                  )
                : const Text('Verify & Continue'),
          ),
        ),
        const SizedBox(height: 16),
        // Resend OTP
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _resendOtp,
            child: Text(
              'Didn\'t receive the code? Resend',
              style: textTheme.bodyMedium?.copyWith(
                color: CricketSpiritColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Back to registration
        Center(
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _isOtpSent = false;
                      _submitted = false;
                      _otpController.clear();
                    });
                  },
            child: const Text('Change Email'),
          ),
        ),
      ],
    );
  }
}

