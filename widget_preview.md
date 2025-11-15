 # الشرح العملي — Flutter Widget Previewer

 ## فهرس المحتوى
 - 1. [المقدمة](#intro)
 - 2. [المتطلبات والحالة](#requirements)
 - 3. [فتح المعاين](#open-previewer)
   - 3.1 [من داخل IDEs](#open-ides)
   - 3.2 [من سطر الأوامر](#open-cli)
   - 3.3 [تشغيل أمثلة المشروع](#run-examples)
 - 4. [معاينة Widget باستخدام @Preview](#preview-widget)
 - 5. [عناصر التحكم في واجهة المعاينة](#controls)
 - 6. [تصفية المعاينات حسب الملف المحدد](#filter-by-file)
 - 7. [تخصيص المعاينة عبر معاملات @Preview](#customize-preview)
 - 8. [إنشاء Annotations مخصصة (Preview/transform)](#custom-annotations)
 - 9. [إنشاء معاينات متعددة (MultiPreview/transform)](#multi-preview)
 - 10. [قيود وحدود](#limitations)
 - 11. [ال breaking-changes](#breaking-changes)
 - 12. [نصائح عملية](#tips)
 - 13. [مراجع](#refs)

 <a name="intro"></a>
 ## المقدمة
 فكرة Flutter Widget Previewer إنها أداة بتخلّيك تشوف الـWidgets بتاعتك Real-time بعيد عن الـapp الكامل، وبتفتح في Chrome وبتتحدّث تلقائي مع تغييرات المشروع، وكمان بتسهّل عليك تجربة Light/Dark وقياسات الحجم وموضوع الـLocalizations بسرعة.

 <a name="requirements"></a>
 ## المتطلبات والحالة
 - **إصدار Flutter:** يلزم 3.35 أو أحدث لتشغيل المعاين. دعم التشغيل من داخل IDE يتطلب 3.38 أو أحدث.
 - **الحالة:** ميزة تجريبية على قناة stable. الواجهات البرمجية غير مستقرة وقد تتغير مستقبلاً.

 <a name="open-previewer"></a>
 ## فتح المعاين
 <a name="open-ides"></a>
 ### من داخل IDEs
 - بدءاً من Flutter 3.38، يقوم Android Studio/IntelliJ وVS Code بتشغيل Widget Previewer تلقائياً عند الإطلاق.
 - افتح تبويب "Flutter Widget Preview" من الشريط الجانبي في IDE.

 <a name="open-cli"></a>
 ### من سطر الأوامر
 - من مجلد جذر مشروع Flutter شغّل:
 ```bash
 flutter widget-preview start
 ```
 - يفتح ذلك بيئة معاينة محلية في Chrome تتحدّث مع تغييرات مشروعك.
 


 <a name="preview-widget"></a>
 ## معاينة Widget باستخدام @Preview
 لازم تستخدم `@Preview` من الحزمة `package:flutter/widget_previews.dart` عشان تميّز الهدف اللي هيتعاين. ممكن تطبّقها على:
 - دوال top-level تُعيد `Widget` أو `WidgetBuilder`.
 - توابع static داخل كلاس تُعيد `Widget` أو `WidgetBuilder`.
 ## عناصر التحكم في واجهة المعاينة
 - **Zoom in/Zoom out/Reset zoom:** تكبير/تصغير وإعادة الضبط لمستوى العرض.
 - **Light/Dark toggle:** التبديل بين نسق فاتح ومظلم.
 - **Hot restart للمعاينة الحالية:** إعادة تشغيل سريعة للمعاينة المحددة فقط.
 - **Hot restart شامل:** زر أسفل يمين البيئة لإعادة تشغيل كل المعاينات عند تغيّر حالة عامة.

 <a name="filter-by-file"></a>
 ## تصفية المعاينات حسب الملف المحدد
 عند العرض داخل IDE، يقوم المعاين افتراضياً بتصفية المعاينات بناءً على الملف النشط. لتعطيل ذلك، استخدم خيار "Filter previews by selected file" أسفل يسار البيئة.

 <a name="customize-preview"></a>
 ## تخصيص المعاينة عبر معاملات @Preview
 لازم تعرف إن `@Preview` بتدعم معاملات كتير لتخصيص العرض:
 - **name:** اسم وصفي للمعاينة.
 - **group:** تجميع معاينات مرتبطة.
 - **size:** فرض قيود حجم باستخدام `Size`.
 - **textScaleFactor:** مقياس الخط.
 - **wrapper:** دالة تلتف حول الودجت المعروض لإدخال شجرة Widgets (مثلاً عبر `InheritedWidget`).
 - **theme:** دالة توفر بيانات `Material` و`Cupertino`.
 - **brightness:** قيمة السطوع الابتدائية.
 - **localizations:** دالة لتطبيق إعدادات الترجمة.

 #### مثال تخصيص سريع
 ```dart
 import 'package:flutter/widget_previews.dart';
 import 'package:flutter/material.dart';

 @Preview(
   name: 'Button – scaled',
   group: 'Demo',
   size: Size(320, 100),
   textScaleFactor: 1.2,
   brightness: Brightness.dark,
 )
 Widget buttonPreview() => ElevatedButton(
   onPressed: null,
   child: const Text('Press'),
 );
 ```

 <a name="custom-annotations"></a>
 ## إنشاء Annotations مخصصة (Preview/transform)
 لازم لو عايز تقلل التكرار، تورث من `Preview` وتعمل أنوتيشن مخصص يضبط إعدادات مشتركة.

 #### مثال: تزويد بيانات Theme تلقائياً
 ```dart
 import 'package:flutter/widget_previews.dart';
 import 'package:flutter/material.dart';

 final class MyCustomPreview extends Preview {
   const MyCustomPreview({
     super.name,
     super.group,
     super.size,
     super.textScaleFactor,
     super.wrapper,
     super.brightness,
     super.localizations,
   }) : super(theme: MyCustomPreview.themeBuilder);

   static PreviewThemeData themeBuilder() {
     return PreviewThemeData(
       materialLight: ThemeData.light(),
       materialDark: ThemeData.dark(),
     );
   }
 }
 ```

 #### مثال: التحويل وقت التشغيل عبر `transform()`
 يمكنك override للدالة `transform()` لإجراء تعديلات ديناميكية غير ممكنة في سياق `const`.
 ```dart
 import 'package:flutter/widget_previews.dart';
 import 'package:flutter/material.dart';

 final class TransformativePreview extends Preview {
   const TransformativePreview({
     super.name,
     super.group,
     super.size,
     super.textScaleFactor,
     super.wrapper,
     super.brightness,
     super.localizations,
   });

   // تُحقن وقت التشغيل عند استدعاء transform()
   PreviewThemeData _themeBuilder() {
     return PreviewThemeData(
       materialLight: ThemeData.light(),
       materialDark: ThemeData.dark(),
     );
   }

   @override
   Preview transform() {
     final originalPreview = super.transform();
     // إنشاء PreviewBuilder لتعديل محتوى المعاينة
     final builder = originalPreview.toBuilder();
     builder
       ..name = 'Transformed - ${originalPreview.name}'
       ..theme = _themeBuilder;
     // إرجاع Preview المحدّث
     return builder.toPreview();
   }
 }
 ```

 <a name="multi-preview"></a>
 ## إنشاء معاينات متعددة (MultiPreview/transform)
 لازم تعرف إنك تقدر يا إمّا تطبّق أكتر من `@Preview` على نفس الدالة/الكونستراكتور، أو تستخدم `MultiPreview` وتعمل أنوتيشن تطلع لك معاينات متعددة.

 #### الطريقة 1: أكثر من @Preview على نفس الهدف
 ```dart
 import 'package:flutter/widget_previews.dart';
 import 'package:flutter/material.dart';

 @Preview(
   group: 'Brightness',
   name: 'Example - light',
   brightness: Brightness.light,
 )
 @Preview(
   group: 'Brightness',
   name: 'Example - dark',
   brightness: Brightness.dark,
 )
 Widget buttonShowcasePreview() => const ButtonShowcase();
 ```

 #### الطريقة 2: أنوتيشن مخصص عبر MultiPreview
 ```dart
 import 'package:flutter/widget_previews.dart';
 import 'package:flutter/material.dart';

 /// Creates light and dark mode previews.
 final class MultiBrightnessPreview extends MultiPreview {
   const MultiBrightnessPreview();

   @override
   List<Preview> get previews => const [
     Preview(
       group: 'Brightness',
       name: 'Example - light',
       brightness: Brightness.light,
     ),
     Preview(
       group: 'Brightness',
       name: 'Example - dark',
       brightness: Brightness.dark,
     ),
   ];
 }

 @MultiBrightnessPreview()
 Widget buttonPreview() => const ButtonShowcase();
 ```

 #### التحويل وقت التشغيل في MultiPreview
 ```dart
 import 'package:flutter/widget_previews.dart';
 import 'package:flutter/material.dart';

 /// Creates light and dark mode previews.
 final class MultiBrightnessPreview extends MultiPreview {
   const MultiBrightnessPreview({required this.name});

   final String name;

   @override
   List<Preview> get previews => const [
     Preview(brightness: Brightness.light),
     Preview(brightness: Brightness.dark),
   ];

   @override
   List<Preview> transform() {
     final previews = super.transform();
     return previews.map((preview) {
       final builder = preview.toBuilder()
         ..group = 'Brightness'
         // بناء أسماء ديناميكيًا وقت التشغيل
         ..name = '$name - ${preview.brightness!.name}';
       return builder.toPreview();
     }).toList();
   }
 }

 @MultiBrightnessPreview(name: 'Example')
 Widget buttonPreview2() => const ButtonShowcase();
 ```

 <a name="limitations"></a>
 ## قيود وحدود
 - اولا **Public callback names:** يجب أن تكون كل callbacks الممرّرة في الأنوتيشن عامة و`const` لعمل توليد الشيفرة في المعاين بشكل صحيح.
 - ثانيا **APIs غير مدعومة:** لا دعم لـ`dart:io` و`dart:ffi` أو الـplugins الأصلية لأن المعاين مبني على Flutter Web.

   -ال Widgets ذات تبعيات ترانزيتيف على `dart:io` تُحمَّل لكن أي استدعاء فعلي سيُرمِي استثناء.
   
   -ال Widgets ذات تبعيات ترانزيتيف على `dart:ffi` تفشل بالتحميل كلياً. راجع المشكلة: https://github.com/flutter/flutter/issues/166431
   - قد تعمل بعض web plugins على Chrome، لكن لا ضمان لعملها عند تضمين المعاين داخل IDE.
   - للاسترشادات حول الاستيرادات الشرطية راجع: https://dart.dev/tools/pub/create-packages
 - **مسارات الأصول (Assets):** عند استخدام `fromAsset` من `dart:ui` استخدم مسارات بنمط package لضمان عملها على الويب:
   - استخدم: `packages/my_package_name/assets/my_image.png`
   - تجنّب: `assets/my_image.png`
 -ال **Widgets بلا قيود:** إن لم توفّر قيوداً، سيقيّد المعاين الودجت تلقائياً إلى نحو نصف العرض/الارتفاع. يُفضّل ضبط `size` صراحةً.
 - **مشاريع متعددة داخل IDE:** حالياً يدعم مشروعاً واحداً أو Pub workspace واحداً. قيد المتابعة: https://github.com/flutter/flutter/issues/173550

 <a name="breaking-changes"></a>
 ## لازم نعمل حساب breaking changes
 كون الميزة **تجريبية**، قد تتغير الواجهات البرمجية وتُدخل تغييرات كاسرة في تحديثات لاحقة. للتخفيف:
 - ثبّت نسخة Flutter عند الحاجة ضمن فريقك.
 - تابع ملاحظات الإصدارات الرسمية.

 <a name="tips"></a>
 ## نصائح عملية
 - اجعل الـcallbacks المستخدمة في الأنوتيشن عامة و`const` حيثما أمكن.
 - ضع قيود حجم عبر `size` للـWidgets غير المقيدة لتجنّب القيود الافتراضية.
 - استخدم `group` لتنظيم المعاينات و`textScaleFactor` لاختبار قابلية الوصول.
 - عند الحاجة لتغليف الودجت بشجرة UI، استخدم `wrapper` لضخ حالة/سياق مناسب.
 - لتقليل التكرار، أنشئ أنوتيشن مخصصة عبر `Preview` و`MultiPreview`.

 <a name="refs"></a>
 ## مراجع
 - وثائق الأداة: https://docs.flutter.dev/tools/widget-previewer
 - API — Preview: https://api.flutter.dev/flutter/widget_previews/Preview-class.html
 - API — Preview.transform(): https://api.flutter.dev/flutter/widget_previews/Preview/transform.html
 - API — MultiPreview: https://api.flutter.dev/flutter/widget_previews/MultiPreview-class.html
 - API — MultiPreview.transform(): https://api.flutter.dev/flutter/widget_previews/MultiPreview/transform.html
 - الاستيرادات الشرطية في Dart: https://dart.dev/tools/pub/create-packages
 - ملاحظات الإصدارات: https://docs.flutter.dev/release/release-notes

