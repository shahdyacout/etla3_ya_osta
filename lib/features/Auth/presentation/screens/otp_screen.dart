import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../domain/entities/user_role.dart';
import '../provider/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  // Firebase OTP بيبعت 6 أرقام
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _secondsLeft = 60;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsLeft = 60;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _onResend() async {
    if (!_canResend) return;
    _timer?.cancel();

    try {
      await ref.read(authRepositoryProvider).sendOtp(widget.phoneNumber);
      if (!mounted) return;
      _startTimer();
      SnackbarHelper.showSuccess(context, 'Code resent successfully!');
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, 'Failed to resend code. Try again.');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();
  bool get _isComplete => _otpCode.length == 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 1),
              _HeaderSection(phoneNumber: widget.phoneNumber),
              const SizedBox(height: 40),
              _OtpBoxesRow(
                controllers: _controllers,
                focusNodes: _focusNodes,
                onChanged: _onDigitChanged,
              ),
              const SizedBox(height: 32),
              _VerifyButton(
                isLoading: _isLoading,
                isEnabled: _isComplete,
                onPressed: _onVerify,
              ),
              const SizedBox(height: 24),
              _ResendSection(
                secondsLeft: _secondsLeft,
                canResend: _canResend,
                onResend: _onResend,
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _onVerify() async {
    if (!_isComplete) return;

    setState(() => _isLoading = true);

    try {
      // بنبعت الـ OTP code الحقيقي لـ Firebase
      await ref.read(authProvider.notifier).login(_otpCode);

      if (!mounted) return;

      setState(() => _isLoading = false);

      final authState = ref.read(authProvider);

      if (authState.hasError) {
        SnackbarHelper.showError(
          context,
          authState.failure!.message,
        );
        return;
      }

      SnackbarHelper.showSuccess(context, 'Login successful! Welcome 🎉');

      final route = authState.role == UserRole.traveler
          ? AppRouter.travelerHome
          : AppRouter.driverHome;

      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      SnackbarHelper.showError(
        context,
        'Invalid code. Please try again.',
      );
    }
  }
}

class _HeaderSection extends StatelessWidget {
  final String phoneNumber;

  const _HeaderSection({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verify your number',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Code sent to '),
              TextSpan(
                text: '+20 $phoneNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OtpBoxesRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;

  const _OtpBoxesRow({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => _OtpSingleBox(
          controller: controllers[index],
          focusNode: focusNodes[index],
          onChanged: (value) => onChanged(index, value),
        ),
      ),
    );
  }
}

class _OtpSingleBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;

  const _OtpSingleBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _VerifyButton extends StatelessWidget {
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _VerifyButton({
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Verify',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class _ResendSection extends StatelessWidget {
  final int secondsLeft;
  final bool canResend;
  final VoidCallback onResend;

  const _ResendSection({
    required this.secondsLeft,
    required this.canResend,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: canResend
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Didn't receive the code? ",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
                GestureDetector(
                  onTap: onResend,
                  child: const Text(
                    'Resend',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            )
          : Text(
              'Resend code in ${secondsLeft}s',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
    );
  }
}