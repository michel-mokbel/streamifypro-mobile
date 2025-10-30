import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../core/utils/i18n.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t(context, en: 'Privacy Policy', ar: 'سياسة الخصوصية')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(context, en: 'Privacy Policy', ar: 'سياسة الخصوصية'),
              style: AppTypography.heading1,
            ),
            const SizedBox(height: 12),
            Text(
              t(
                context,
                en: 'We value your privacy. This policy explains what data we collect, how we use it, '
                    'and your choices. We collect only what is necessary to provide and improve the service, '
                    'such as account details, preferences, and usage analytics. We do not sell your personal data.',
                ar: 'نحن نقدر خصوصيتك. توضح هذه السياسة البيانات التي نجمعها وكيف نستخدمها '
                    'والخيارات المتاحة لك. نجمع فقط ما هو ضروري لتقديم الخدمة وتحسينها، '
                    'مثل بيانات الحساب والتفضيلات وتحليلات الاستخدام. نحن لا نبيع بياناتك الشخصية.',
              ),
              style: AppTypography.bodyText,
            ),
            const SizedBox(height: 16),
            Text(
              t(context, en: 'Data Security', ar: 'أمن البيانات'),
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              t(
                context,
                en: 'We implement reasonable safeguards to protect your information. However, no method of transmission over the internet is 100% secure.',
                ar: 'نعتمد تدابير معقولة لحماية معلوماتك. ومع ذلك، لا توجد وسيلة نقل عبر الإنترنت آمنة بنسبة 100٪.',
              ),
              style: AppTypography.bodyText,
            ),
            const SizedBox(height: 16),
            Text(
              t(context, en: 'Content and Licensing', ar: 'المحتوى والتراخيص'),
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              t(
                context,
                en: 'All content available through Streamify Pro is licensed and used under appropriate permissions. '
                    'Your use of the content must comply with these licenses and our Terms and Conditions.',
                ar: 'جميع المحتويات المتاحة عبر ستريميفاي برو مرخّصة ويتم استخدامها وفق الأذونات المناسبة. '
                    'يجب أن يتوافق استخدامك للمحتوى مع هذه التراخيص ومع الشروط والأحكام.',
              ),
              style: AppTypography.bodyText,
            ),
            const SizedBox(height: 16),
            Text(
              t(context, en: 'Your Choices', ar: 'اختياراتك'),
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              t(
                context,
                en: 'You can update your account information and preferences in-app. To request data access or deletion, please contact support.',
                ar: 'يمكنك تحديث معلومات حسابك وتفضيلاتك داخل التطبيق. لطلب الوصول إلى البيانات أو حذفها، يرجى التواصل مع الدعم.',
              ),
              style: AppTypography.bodyText,
            ),
            const SizedBox(height: 16),
            Text(
              t(context, en: 'Updates', ar: 'التحديثات'),
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              t(
                context,
                en: 'We may update this Privacy Policy from time to time. Continued use of the app after changes take effect constitutes acceptance of the updated policy.',
                ar: 'قد نقوم بتحديث سياسة الخصوصية هذه من حين لآخر. يشكّل استمرارك في استخدام التطبيق بعد سريان التغييرات قبولاً منك بالسياسة المحدّثة.',
              ),
              style: AppTypography.bodyText,
            ),
          ],
        ),
      ),
    );
  }
}


