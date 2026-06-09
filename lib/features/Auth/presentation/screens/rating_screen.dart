import 'package:etla3_ya_osta/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';

class RatingScreen extends StatefulWidget {
  final String tripId;
  final String driverName;

  const RatingScreen({
    super.key,
    required this.tripId,
    required this.driverName,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _selectedStars = 0;
  final List<String> _selectedTags = [];
  bool _isLoading = false;

  // الـ tags الثابتة
  static const List<String> _availableTags = [
    'Clean car',
    'On time',
    'Friendly',
    'Safe driving',
    'Good music',
    'Smooth ride',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),
              _DriverInfoSection(driverName: widget.driverName),
              const SizedBox(height: 32),
              _StarsSection(
                selectedStars: _selectedStars,
                onStarTapped: (stars) {
                  setState(() => _selectedStars = stars);
                },
              ),
              const SizedBox(height: 32),
              _TagsSection(
                availableTags: _availableTags,
                selectedTags: _selectedTags,
                onTagToggled: _onTagToggled,
              ),
              const Spacer(flex: 1),
              _SubmitButton(
                isLoading: _isLoading,
                isEnabled: _selectedStars > 0,
                onPressed: _onSubmit,
              ),
              const SizedBox(height: 16),
              _SkipButton(onTap: _onSkip),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  void _onTagToggled(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

 void _onSubmit() {
  if (_selectedStars == 0) return;

  setState(() => _isLoading = true);

  Future.delayed(const Duration(seconds: 1), () {
    if (!mounted) return;
    setState(() => _isLoading = false);


    SnackbarHelper.showSuccess(context, 'Rating submitted! Thank you ⭐');

    _navigateHome();
  });
}

  void _onSkip() => _navigateHome();

  void _navigateHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.destinations,
      (route) => false,
    );
  }
}
class _DriverInfoSection extends StatelessWidget {
  final String driverName;

  const _DriverInfoSection({required this.driverName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'How was your trip?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Rate your experience with $driverName',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────

class _StarsSection extends StatelessWidget {
  final int selectedStars;
  final void Function(int) onStarTapped;

  const _StarsSection({
    required this.selectedStars,
    required this.onStarTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isSelected = starNumber <= selectedStars;

        return GestureDetector(
          onTap: () => onStarTapped(starNumber),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
              // النجمة المختارة بتبقى amber والفاضية رمادية
              color: isSelected ? const Color(0xFFFFC107) : AppColors.border,
              size: isSelected ? 48 : 44,
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────

class _TagsSection extends StatelessWidget {
  final List<String> availableTags;
  final List<String> selectedTags;
  final void Function(String) onTagToggled;

  const _TagsSection({
    required this.availableTags,
    required this.selectedTags,
    required this.onTagToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: availableTags.map((tag) {
        final isSelected = selectedTags.contains(tag);

        return GestureDetector(
          onTap: () => onTagToggled(tag),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              // المختار بيتلون بالـ primary
              color: isSelected
                  ? AppColors.primary.withOpacity(0.12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textLight,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _SubmitButton({
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
                'Submit Rating',
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

// ─────────────────────────────────────────

class _SkipButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SkipButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Text(
        'Skip for now',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}