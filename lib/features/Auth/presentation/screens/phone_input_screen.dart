import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../provider/auth_provider.dart';

class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                const _HeaderSection(),
                const SizedBox(height: 40),
                _PhoneField(controller: _phoneController),
                const SizedBox(height: 24),
                _SendButton(
                  isLoading: _isLoading,
                  onPressed: _onSendCode,
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSendCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final phone = _phoneController.text.trim();

      // بنبعت الـ OTP عن طريق Firebase
      await ref.read(authRepositoryProvider).sendOtp(phone);

      if (!mounted) return;
      setState(() => _isLoading = false);

      // بعد ما الـ OTP اتبعت، روح شاشة الـ OTP
      Navigator.pushNamed(
        context,
        AppRouter.otpScreen,
        arguments: phone,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      SnackbarHelper.showError(
        context,
        'Failed to send code. Check your number and try again.',
      );
    }
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your number',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ll send a verification code to confirm it\'s you',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;

  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 11,
      style: const TextStyle(
        fontSize: 18,
        color: AppColors.textDark,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: '01XXXXXXXXX',
        hintStyle: TextStyle(
          color: AppColors.textLight.withOpacity(0.5),
          letterSpacing: 1.5,
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🇪🇬', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '+20',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'من فضلك ادخل رقم التليفون';
        }
        if (value.length < 11) {
          return 'الرقم لازم يكون 11 رقم';
        }
        if (!value.startsWith('01')) {
          return 'الرقم لازم يبدأ بـ 01';
        }
        return null;
      },
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SendButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
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
                'Send Code',
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