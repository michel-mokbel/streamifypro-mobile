import 'package:flutter/material.dart';

import '../../config/theme.dart';

class FeatureShowcase extends StatefulWidget {
  const FeatureShowcase({
    super.key,
    required this.isArabic,
    required this.onCtaPressed,
  });

  final bool isArabic;
  final VoidCallback onCtaPressed;

  @override
  State<FeatureShowcase> createState() => _FeatureShowcaseState();
}

class _FeatureShowcaseState extends State<FeatureShowcase> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 1.0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0 || index > 3) return;
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.isArabic;

    final List<_SlideData> slides = [
      _SlideData(
        icon: Icons.child_care,
        title: isArabic ? 'منطقة آمنة للأطفال' : 'Kids Safe Zone',
        description: isArabic
            ? 'محتوى تعليمي مُنتقى للأطفال. رقابة أبوية وترفيه مناسب للأعمار.'
            : 'Curated educational content for children. Parental controls and age-appropriate entertainment.',
      ),
      _SlideData(
        icon: Icons.monitor_heart,
        title: isArabic ? 'حصص لياقة مباشرة' : 'Live Fitness Classes',
        description: isArabic
            ? 'انضم إلى تمارين يقودها خبراء من اليوغا إلى HIIT. تدريب شخصي وتوجيه مباشر.'
            : 'Join expert-led workouts from yoga to HIIT. Real-time coaching and personalized training programs.',
      ),
      _SlideData(
        icon: Icons.play_circle_fill,
        title: isArabic
            ? 'أكثر من 10,000 فيلم ومسلسل'
            : '10,000+ Movies & Shows',
        description: isArabic
            ? 'بث غير محدود للأفلام والمسلسلات والإنتاجات الحصرية. جودة 4K بدون إعلانات.'
            : 'Unlimited streaming of blockbusters, series, and exclusive originals. 4K Ultra HD quality with no ads.',
      ),
      _SlideData(
        icon: Icons.sports_esports,
        title: isArabic ? 'ألعاب عبر المتصفح' : 'Browser Gaming',
        description: isArabic
            ? 'العب ألعاب HTML5 الفاخرة فورًا. بدون تنزيلات وبدون انتظار. من الألغاز إلى المغامرات.'
            : 'Play premium HTML5 games instantly. No downloads, no waiting. From puzzles to action adventures.',
      ),
    ];

    return Container(
      constraints: const BoxConstraints(maxWidth: 720),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.6)),
        color: AppColors.cardBg.withOpacity(0.8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 28,
            spreadRadius: 2,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 280,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemCount: slides.length,
              itemBuilder: (context, index) {
                final s = slides[index];
                return _FeatureSlide(data: s);
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavArrow(
                icon: Icons.chevron_left,
                onTap: () => _goTo(_currentIndex - 1),
              ),
              const SizedBox(width: 8),
              _Dots(
                count: slides.length,
                activeIndex: _currentIndex,
                onTap: _goTo,
              ),
              const SizedBox(width: 8),
              _NavArrow(
                icon: Icons.chevron_right,
                onTap: () => _goTo(_currentIndex + 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'ابدأ رحلتك الممتازة' : 'START YOUR PREMIUM JOURNEY',
            style: AppTypography.caption.copyWith(
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary.withOpacity(0.85),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _GradientButton(
            onPressed: widget.onCtaPressed,
            text: isArabic ? 'انضم الآن' : 'JOIN NOW',
          ),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.sidebarBg.withOpacity(0.35),
          border: Border.all(color: AppColors.accentPrimary.withOpacity(0.4)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 26),
      ),
    );
  }
}

class _FeatureSlide extends StatelessWidget {
  const _FeatureSlide({required this.data});
  final _SlideData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconTile(icon: data.icon),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            data.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.heading1.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            data.description,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyText.copyWith(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _Dots extends StatelessWidget {
  const _Dots({
    required this.count,
    required this.activeIndex,
    required this.onTap,
  });

  final int count;
  final int activeIndex;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: List.generate(count, (i) {
        final bool active = i == activeIndex;
        if (active) {
          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              width: 72,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: AppColors.primaryGradient,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          );
        }
        return GestureDetector(
          onTap: () => onTap(i),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.textMuted.withOpacity(0.9),
            ),
          ),
        );
      }),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: RadialGradient(
              center: const Alignment(0, -0.2),
              radius: 0.8,
              colors: [
                AppColors.accentPrimary.withOpacity(0.15),
                Colors.transparent,
              ],
            ),
            border: Border.all(
              color: AppColors.accentPrimary.withOpacity(0.45),
              width: 2,
            ),
          ),
        ),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.accentPrimary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPrimary.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 34),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.onPressed, required this.text});
  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
