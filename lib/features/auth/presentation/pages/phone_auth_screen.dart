import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _verificationId;
  int _resendTimer = 0;
  Timer? _timer;

  bool get _otpSent => _verificationId != null;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          setState(() {
            _verificationId = state.verificationId;
          });
          _startResendTimer();
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
          ),
          title: const Text('Phone Verification'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppDimensions.xl),
                if (!_otpSent) _buildPhoneField() else _buildOtpField(),
                const SizedBox(height: AppDimensions.xl),
                _buildButton(),
                if (_otpSent) ...[
                  const SizedBox(height: AppDimensions.md),
                  _buildResendButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _otpSent ? 'Enter OTP' : 'Phone Verification',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(),
        const SizedBox(height: AppDimensions.sm),
        Text(
          _otpSent
              ? 'Enter the ${AppConstants.otpLength}-digit code sent to ${_phoneController.text}'
              : 'We\'ll send you a verification code',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ).animate().fadeIn(),
      ],
    );
  }

  Widget _buildPhoneField() {
    return AppTextField(
      label: AppStrings.phoneNumber,
      hint: '+91 99999 99999',
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSecondary),
    );
  }

  Widget _buildOtpField() {
    return AppTextField(
      label: 'OTP Code',
      hint: '• • • • • •',
      controller: _otpController,
      keyboardType: TextInputType.number,
      maxLength: AppConstants.otpLength,
      prefixIcon: const Icon(Icons.sms_outlined, color: AppColors.textSecondary),
    );
  }

  Widget _buildButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => AppButton(
        text: _otpSent ? AppStrings.verifyOtp : 'Send OTP',
        isLoading: state is AuthLoading,
        onPressed: _otpSent ? _verifyOtp : _sendOtp,
      ),
    );
  }

  Widget _buildResendButton() {
    return Center(
      child: TextButton(
        onPressed: _resendTimer == 0 ? _sendOtp : null,
        child: Text(
          _resendTimer > 0
              ? 'Resend OTP in ${_resendTimer}s'
              : AppStrings.resendOtp,
        ),
      ),
    );
  }

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    context.read<AuthBloc>().add(AuthSendPhoneOtp(phone));
  }

  void _verifyOtp() {
    if (_verificationId == null || _otpController.text.length != AppConstants.otpLength) return;
    context.read<AuthBloc>().add(AuthVerifyPhoneOtp(
      verificationId: _verificationId!,
      otp: _otpController.text,
    ));
  }

  void _startResendTimer() {
    _resendTimer = AppConstants.otpResendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _resendTimer--);
      if (_resendTimer == 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
