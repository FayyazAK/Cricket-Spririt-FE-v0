import 'package:flutter/material.dart';

import '../../app/themes/themes.dart';
import '../../services/api/api_service.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _submitted = false;
  bool _isLoading = false;
  bool _isOtpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final email = value.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) return 'OTP is required';
    if (value.length != 6) return 'OTP must be 6 digits';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'OTP must be numbers only';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'At least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _requestOtp() async {
    setState(() => _submitted = true);
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _isLoading = true);

    try {
      final response = await apiService.forgotPassword(
        email: _emailController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        _isOtpSent = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'If an account exists, an OTP has been sent to your email.',
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

  Future<void> _resetPassword() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await apiService.resetPassword(
        token: _otpController.text,
        password: _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Password reset successfully!',
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
      final response = await apiService.forgotPassword(
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
        title: Text('Forgot Password', style: textTheme.headlineSmall),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _isOtpSent ? _buildResetPasswordForm() : _buildEmailForm(),
      ),
    );
  }

  Widget _buildEmailForm() {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      autovalidateMode:
          _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: CricketSpiritColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset,
                size: 40,
                color: CricketSpiritColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Reset Password', style: textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Enter your email address and we\'ll send you an OTP to reset your password.',
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
          const SizedBox(height: 24),
          // Send OTP Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _requestOtp,
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
                  : const Text('Send Reset OTP'),
            ),
          ),
          const SizedBox(height: 16),
          // Back to login
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Back to Login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetPasswordForm() {
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
              Icons.vpn_key,
              size: 40,
              color: CricketSpiritColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Title
        Text(
          'Reset Password',
          style: textTheme.displaySmall?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        // Subtitle
        Text(
          'Enter the OTP sent to ${_emailController.text} and your new password.',
          style: textTheme.bodyMedium?.copyWith(
            color: CricketSpiritColors.mutedForeground,
          ),
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
        const SizedBox(height: 16),
        // New Password
        TextFormField(
          controller: _passwordController,
          enabled: !_isLoading,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password',
            hintText: 'Create a strong password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
          validator: _validatePassword,
        ),
        const SizedBox(height: 16),
        // Confirm Password
        TextFormField(
          controller: _confirmPasswordController,
          enabled: !_isLoading,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Re-enter your password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
          validator: _validateConfirmPassword,
        ),
        const SizedBox(height: 24),
        // Reset Password Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _resetPassword,
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
                : const Text('Reset Password'),
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
        // Change email
        Center(
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _isOtpSent = false;
                      _submitted = false;
                      _otpController.clear();
                      _passwordController.clear();
                      _confirmPasswordController.clear();
                    });
                  },
            child: const Text('Change Email'),
          ),
        ),
      ],
    );
  }
}
