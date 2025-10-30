import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../core/utils/i18n.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t(context, en: 'Terms and Conditions', ar: 'الشروط والأحكام')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(context, en: 'Terms and Conditions', ar: 'الشروط والأحكام'),
              style: AppTypography.heading1,
            ),
            const SizedBox(height: 12),
            Text(
              t(
                context,
                en: 'By using Streamify Pro, you agree to abide by these Terms and Conditions. '
                    'Use of the app is subject to applicable laws and our fair use policies. '
                    'You agree not to misuse the service, attempt unauthorized access, or infringe on any rights. '
                    'Accounts may be suspended for violations. This app is provided on an "as is" basis without warranties to the maximum extent permitted by law.',
                ar: 'باستخدامك لتطبيق ستريميفاي برو، فإنك توافق على هذه الشروط والأحكام. '
                    'يخضع استخدام التطبيق للقوانين المعمول بها وسياسات الاستخدام العادل لدينا. '
                    'تتعهد بعدم إساءة استخدام الخدمة أو محاولة الوصول غير المصرح به أو انتهاك أي حقوق. '
                    'قد يتم تعليق الحسابات عند المخالفة. يتم توفير هذا التطبيق كما هو دون أي ضمانات إلى الحد الأقصى الذي يسمح به القانون.',
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
                en: 'All content available through Streamify Pro, including but not limited to videos, images, text, graphics, and metadata, '
                    'is licensed and used under appropriate permissions. You may not copy, distribute, modify, or publicly display any content '
                    'except as expressly permitted by applicable licenses or by us in writing.',
                ar: 'جميع المحتويات المتاحة عبر ستريميفاي برو، بما في ذلك على سبيل المثال لا الحصر الفيديوهات والصور والنصوص والرسومات والبيانات الوصفية، '
                    'مرخّصة ويتم استخدامها وفق الأذونات المناسبة. لا يجوز لك نسخ أو توزيع أو تعديل أو عرض أي محتوى علنًا '
                    'إلا إذا كان ذلك مسموحًا صراحةً بموجب التراخيص المعمول بها أو بإذن كتابي منا.',
              ),
              style: AppTypography.bodyText,
            ),
            const SizedBox(height: 16),
            Text(
              t(context, en: 'Changes to Terms', ar: 'تعديلات على الشروط'),
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              t(
                context,
                en: 'We may update these Terms from time to time. Continued use of the app after changes take effect constitutes acceptance of the updated Terms.',
                ar: 'قد نقوم بتحديث هذه الشروط من حين لآخر. يشكّل استمرارك في استخدام التطبيق بعد سريان التغييرات قبولاً منك بالشروط المحدّثة.',
              ),
              style: AppTypography.bodyText,
            ),
            const SizedBox(height: 16),
            Text(
              t(context, en: 'Contact', ar: 'الاتصال'),
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              t(
                context,
                en: 'If you have questions about these Terms, please contact support.',
                ar: 'إذا كانت لديك أسئلة حول هذه الشروط، يرجى التواصل مع الدعم.',
              ),
              style: AppTypography.bodyText,
            ),
          ],
        ),
      ),
    );
  }
}


