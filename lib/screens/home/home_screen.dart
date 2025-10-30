import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../widgets/navigation/side_drawer.dart';
import '../../core/utils/i18n.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t(context, en: 'Home', ar: 'الرئيسية'))),
      drawer: const SideDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero section
          _HeroCard(),
          const SizedBox(height: 24),

          // Category summary cards
          _CategorySummaryCard(
            icon: Icons.group_outlined,
            iconBg: const Color(0xFFE8F5E9),
            title: t(context, en: 'Kids', ar: 'الأطفال'),
            subtitle: t(context, en: '2,360 educational videos for children', ar: '2,360 فيديو تعليمي للأطفال'),
            badgeText: t(context, en: 'Educational', ar: 'تعليمي'),
            badgeColor: AppColors.accentSuccess,
            actionText: t(context, en: 'Watch', ar: 'مشاهدة'),
            onTap: () => Navigator.pushNamed(context, '/kids'),
          ),
          const SizedBox(height: 16),
          _CategorySummaryCard(
            icon: Icons.monitor_heart_outlined,
            iconBg: const Color(0xFFFFF3E0),
            title: t(context, en: 'Fitness', ar: 'اللياقة'),
            subtitle: t(context, en: '42 workout videos', ar: '٤٢ فيديو تمارين'),
            badgeText: t(context, en: 'Educational', ar: 'تعليمي'),
            badgeColor: AppColors.accentSuccess,
            actionText: t(context, en: 'Start Training', ar: 'ابدأ التمرين'),
            onTap: () => Navigator.pushNamed(context, '/fitness'),
          ),
          const SizedBox(height: 16),
          _CategorySummaryCard(
            icon: Icons.local_movies_outlined,
            iconBg: const Color(0xFFE3F2FD),
            title: t(context, en: 'Streaming', ar: 'البث'),
            subtitle: t(context, en: '2,162 videos and movies', ar: '٢,١٦٢ فيديو وفيلم'),
            badgeText: t(context, en: 'Entertainment', ar: 'ترفيه'),
            badgeColor: AppColors.accentSecondary,
            actionText: t(context, en: 'Explore', ar: 'استكشف'),
            onTap: () => Navigator.pushNamed(context, '/streaming'),
          ),
          const SizedBox(height: 16),
          _CategorySummaryCard(
            icon: Icons.videogame_asset_outlined,
            iconBg: const Color(0xFFFFEBEE),
            title: t(context, en: 'Games', ar: 'الألعاب'),
            subtitle: t(context, en: '123 HTML5 games ready to play', ar: '١٢٣ لعبة HTML5 جاهزة للعب'),
            badgeText: t(context, en: 'Entertainment', ar: 'ترفيه'),
            badgeColor: AppColors.accentSecondary,
            actionText: t(context, en: 'Play Now', ar: 'العب الآن'),
            onTap: () => Navigator.pushNamed(context, '/games'),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t(context, en: 'Welcome to', ar: 'مرحبًا بك في'), style: AppTypography.heading2.copyWith(color: Colors.white.withOpacity(0.9))),
          const SizedBox(height: 4),
          Text(t(context, en: 'Streamify Pro', ar: 'ستريميفاي برو'), style: AppTypography.heading1.copyWith(color: Colors.white, fontSize: 36)),
          const SizedBox(height: 12),
          Text(
            t(
              context,
              en: 'Your premium entertainment destination. Stream movies, play games, stay fit, and enjoy kids content all in one place.',
              ar: 'وجهتك الترفيهية المميزة. شاهد الأفلام، العب الألعاب، احصل على اللياقة، واستمتع بمحتوى الأطفال في مكان واحد.',
            ),
            style: AppTypography.bodyText.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/streaming'),
                icon: const Icon(Icons.play_arrow),
                label: Text(t(context, en: 'Start Watching', ar: 'ابدأ المشاهدة')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/fitness'),
                icon: const Icon(Icons.show_chart),
                label: Text(t(context, en: 'Get Fit', ar: 'احصل على اللياقة')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategorySummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final String actionText;
  final VoidCallback onTap;

  const _CategorySummaryCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: AppColors.textMuted, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title, style: AppTypography.heading2),
                      ),
                      _Badge(text: badgeText, color: badgeColor),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: AppTypography.bodyText),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(actionText, style: AppTypography.bodyText.copyWith(color: AppColors.accentPrimary)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_right_alt, color: AppColors.accentPrimary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(text, style: AppTypography.caption.copyWith(color: Colors.white)),
    );
  }
}


