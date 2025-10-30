import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/services.dart';
import '../../config/routes.dart';
import '../../screens/favorites/favorites_screen.dart';
import '../../screens/watchlater/watchlater_screen.dart';
import '../../core/utils/i18n.dart';

class SideDrawer extends StatelessWidget {
  final VoidCallback? onLogout;
  const SideDrawer({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    final String? current = ModalRoute.of(context)?.settings.name;
    return Drawer(
      backgroundColor: AppColors.sidebarBg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              const SizedBox(height: 8),
              // App logo at top of sidebar
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Image.asset(
                    'assets/images/logo1.png',
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              _MenuItem(
                icon: Icons.home,
                label: t(context, en: 'Home', ar: 'الرئيسية'),
                active: current == AppRoutes.home,
                onTap: () => Navigator.pushNamed(context, AppRoutes.home),
              ),
              _MenuItem(
                icon: Icons.child_care,
                label: t(context, en: 'Kids', ar: 'الأطفال'),
                active: current == AppRoutes.kids,
                onTap: () => Navigator.pushNamed(context, AppRoutes.kids),
              ),
              _MenuItem(
                icon: Icons.monitor_heart,
                label: t(context, en: 'Fitness', ar: 'اللياقة'),
                active: current == AppRoutes.fitness,
                onTap: () => Navigator.pushNamed(context, AppRoutes.fitness),
              ),
              _MenuItem(
                icon: Icons.local_movies,
                label: t(context, en: 'Streaming', ar: 'البث'),
                active: current == AppRoutes.streaming,
                onTap: () => Navigator.pushNamed(context, AppRoutes.streaming),
              ),
              _MenuItem(
                icon: Icons.videogame_asset,
                label: t(context, en: 'Games', ar: 'الألعاب'),
                active: current == AppRoutes.games,
                onTap: () => Navigator.pushNamed(context, AppRoutes.games),
              ),
              _MenuItem(
                icon: Icons.favorite,
                label: t(context, en: 'Favorites', ar: 'المفضلة'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesScreen())),
              ),
              _MenuItem(
                icon: Icons.watch_later,
                label: t(context, en: 'Watch Later', ar: 'مشاهدة لاحقاً'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WatchLaterScreen())),
              ),
              _MenuItem(
                icon: Icons.person,
                label: t(context, en: 'Account', ar: 'الحساب'),
                onTap: () async {
                  final auth = context.read<AuthProvider>();
                  final user = auth.currentUser;
                  final memberSince = await auth.getMemberSince();
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => _AccountDialog(
                      username: user?.username ?? 'guest',
                      memberSince: memberSince ?? '',
                      email: 'info@streamifypro.com',
                    ),
                  );
                },
              ),
              // Language selector row
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.language, color: Colors.white70),
                    const SizedBox(width: 12),
                    Expanded(child: Text(t(context, en: 'Language', ar: 'اللغة'), style: AppTypography.bodyText)),
                    DropdownButton<String>(
                      value: language.locale.languageCode,
                      underline: const SizedBox.shrink(),
                      dropdownColor: AppColors.cardBg,
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'ar', child: Text('العربية')),
                      ],
                      onChanged: (code) { if (code != null) language.setLanguage(code); },
                    ),
                  ],
                ),
              ),
                    ],
                  ),
                ),
              ),
              // Logout pill button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(context, '/auth/login', (route) => false);
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(t(context, en: 'Logout', ar: 'تسجيل الخروج')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardBg,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.borderColor)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text('© ${DateTime.now().year} Streamify Pro. All rights reserved.', style: AppTypography.caption),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, this.active = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: active ? AppColors.primaryGradient : null,
        color: active ? null : Colors.transparent,
        boxShadow: null,
        border: null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: AppTypography.bodyText.copyWith(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountDialog extends StatelessWidget {
  final String username;
  final String memberSince;
  final String email;
  const _AccountDialog({required this.username, required this.memberSince, required this.email});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderColor)),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t(context, en: 'Account', ar: 'الحساب'), style: AppTypography.heading2),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_circle, size: 28, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(username, style: AppTypography.heading2.copyWith(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t(context, en: 'Member since: $memberSince', ar: 'عضو منذ: $memberSince'),
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.mainBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: t(context, en: 'Email us at: ', ar: 'راسلنا على: '),
                                  style: AppTypography.bodyText,
                                ),
                                TextSpan(
                                  text: email,
                                  style: AppTypography.bodyText.copyWith(color: AppColors.accentPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white70),
                          tooltip: t(context, en: 'Copy email', ar: 'نسخ البريد'),
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: email));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(t(context, en: 'Email copied', ar: 'تم نسخ البريد'))),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Legal links
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.terms);
                        },
                        child: Text(t(context, en: 'Terms and Conditions', ar: 'الشروط والأحكام')),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.privacy);
                        },
                        child: Text(t(context, en: 'Privacy Policy', ar: 'سياسة الخصوصية')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Footer
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderColor)),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t(context, en: 'Close', ar: 'إغلاق')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


