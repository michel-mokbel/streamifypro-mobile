import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';

import '../../config/theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/language_switcher.dart';
import '../../providers/language_provider.dart';
import '../../widgets/auth/feature_showcase.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isArabic =
        context.watch<LanguageProvider>().locale.languageCode == 'ar';
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          // Content card + feature section
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 100),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderColor),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Image.asset(
                                'assets/images/logo1.png',
                                height: 110,
                                fit: BoxFit.contain,
                              ),
                            ),
                            // Brand name with gradient
                            ShaderMask(
                              shaderCallback: (bounds) => AppColors
                                  .primaryGradient
                                  .createShader(bounds),
                              child: Text(
                                isArabic ? 'ستريميفاي برو' : 'Streamify Pro',
                                style: AppTypography.heading1.copyWith(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Tagline
                            Text(
                              isArabic
                                  ? 'وجهتك النهائية للترفيه'
                                  : 'Your Ultimate Entertainment Hub',
                              style: AppTypography.bodyText.copyWith(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            // Username field
                            Text(
                              isArabic ? 'اسم المستخدم' : 'USERNAME',
                              style: AppTypography.caption.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: isArabic
                                    ? 'أدخل اسم المستخدم'
                                    : 'Enter your username',
                                hintStyle: TextStyle(
                                  color: AppColors.textMuted.withOpacity(0.6),
                                ),
                                filled: true,
                                fillColor: AppColors.cardBg.withOpacity(0.8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.accentPrimary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              validator: Validators.required,
                            ),
                            const SizedBox(height: 20),
                            // Email field
                            Text(
                              isArabic ? 'البريد الإلكتروني' : 'EMAIL',
                              style: AppTypography.caption.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: isArabic
                                    ? 'أدخل بريدك الإلكتروني'
                                    : 'Enter your email',
                                hintStyle: TextStyle(
                                  color: AppColors.textMuted.withOpacity(0.6),
                                ),
                                filled: true,
                                fillColor: AppColors.cardBg.withOpacity(0.8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.accentPrimary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 20),
                            // Password field
                            Text(
                              isArabic ? 'كلمة المرور' : 'PASSWORD',
                              style: AppTypography.caption.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: isArabic
                                    ? 'أدخل كلمة المرور'
                                    : 'Enter your password',
                                hintStyle: TextStyle(
                                  color: AppColors.textMuted.withOpacity(0.6),
                                ),
                                filled: true,
                                fillColor: AppColors.cardBg.withOpacity(0.8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.accentPrimary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              validator: Validators.required,
                            ),
                            const SizedBox(height: 32),
                            // Sign Up button with gradient
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: auth.isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          await context
                                              .read<AuthProvider>()
                                              .signup(
                                                _usernameController.text.trim(),
                                                _emailController.text.trim(),
                                                _passwordController.text,
                                              );
                                          if (mounted &&
                                              context
                                                  .read<AuthProvider>()
                                                  .isAuthenticated) {
                                            Navigator.pushReplacementNamed(
                                              context,
                                              '/home',
                                            );
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  isArabic ? 'إنشاء حساب' : 'Sign Up',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Sign In link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isArabic
                                      ? 'لديك حساب؟ '
                                      : 'Have an account? ',
                                  style: AppTypography.bodyText.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    isArabic ? 'تسجيل الدخول' : 'Sign In',
                                    style: AppTypography.bodyText.copyWith(
                                      color: AppColors.accentPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (auth.errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.accentDanger.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.accentDanger.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  auth.errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.accentDanger,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: FeatureShowcase(
                      isArabic: isArabic,
                      onCtaPressed: () =>
                          Navigator.pushNamed(context, '/auth/signup'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: isArabic
                                ? 'بإنشاء حساب، فإنك توافق على '
                                : 'By creating an account, you agree to our ',
                          ),
                          TextSpan(
                            text: isArabic
                                ? 'الشروط والأحكام'
                                : 'Terms and Conditions',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.accentPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () =>
                                  Navigator.pushNamed(context, '/legal/terms'),
                          ),
                          TextSpan(text: isArabic ? ' و ' : ' and '),
                          TextSpan(
                            text: isArabic
                                ? 'سياسة الخصوصية'
                                : 'Privacy Policy',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.accentPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.pushNamed(
                                context,
                                '/legal/privacy',
                              ),
                          ),
                          TextSpan(text: isArabic ? '. ' : '. '),
                          TextSpan(
                            text: isArabic
                                ? 'جميع المحتويات خاضعة للتراخيص.'
                                : 'All content is licensed.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Language switcher (top-right) - keep on top for tap handling
          const Positioned(
            right: 12,
            top: 50,
            child: LanguageSwitcher(iconOnly: true),
          ),
        ],
      ),
    );
  }
}
