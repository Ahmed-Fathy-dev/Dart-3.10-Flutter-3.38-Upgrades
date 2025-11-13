# الشرح التفصيلي — Announcing Dart 3.10


---

## فهرس المحتوى

- 1. [المقدمة](#المقدمة)
- 2. [تحديثات اللغة](#تحديثات-اللغة)
  - 2.1 [شرح Dot shorthands](#شرح-dot-shorthands)
- 3. [تحديثات الأدوات](#تحديثات-الأدوات)
  - 3.1 [شرح Analyzer plugins](#شرح-analyzer-plugins)
  - 3.2 [شرح Build hooks (Stable)](#شرح-build-hooks-stable)
  - 3.3 [شرح Remove deprecations lint](#شرح-remove-deprecations-lint)
  - 3.4 [شرح New @Deprecated annotations](#شرح-new-deprecated-annotations)
- 4. [تحديثات Pub](#تحديثات-pub)
  - 4.1 [شرح Likes tab: search/sort/unlike](#شرح-likes-tab-searchsortunlike)
  - 4.2 [شرح Enable/disable manual publishing](#شرح-enabledisable-manual-publishing)
- 5. [الخلاصة](#الخلاصة)
- 6. [المراجع](#المراجع)

---
## تحديثات اللغة

### شرح Dot shorthands

#### أمثلة: قبل/بعد

```dart
// Before
enum LogLevel { info, warning, error, debug }

void logMessage(String message, {LogLevel level = LogLevel.info}) {
  // ...
}

logMessage('Failed to connect to database', level: LogLevel.error);
```

```dart
// After
enum LogLevel { info, warning, error, debug }

void logMessage(String message, {LogLevel level = .info}) {
  // ...
}

logMessage('Failed to connect to database', level: .error);
```

#### الشرح
الشرح: الميزة دي بتخلّي compiler يعتمد على **type inference** بدل ما تكرّر اسم الـ `enum` أو الـ `class`، وده بيقلّل التكرار ويزود **readability**.
الشرح: بدل ما تكتب `LogLevel.error` تقدر تكتب `.error` لما الـ type معروف من الـ context (زي parameter نوعه `LogLevel`).
الشرح: نفس الفكرة بتنطبق على **named constructors** و **static methods/fields** لما الـ type واضح من السياق.

#### ملاحظات مهمة
ملاحظة: استخدم dot shorthands لما الـ context واضح؛ لو الـ type مش واضح، هتحتاج تكتب الاسم صراحة.
ملاحظة: الهدف تقليل **boilerplate** وزيادة **readability** بدون ما يتغيّر سلوك الكود.

#### أمثلة إضافية

```dart
// Static method
int port = .parse('8080'); // Instead of int.parse('8080')

// Static field
Duration timeout = .zero; // Instead of Duration.zero

// Named constructor
class Point {
  final int x, y;
  const Point(this.x, this.y);
  const Point.origin() : x = 0, y = 0;
}
Point origin = .origin(); // Instead of Point.origin()

// Default constructor (.new)
StringBuffer buffer = .new(); // Instead of StringBuffer.new()

// Constant constructor shorthand (context provides the type)
class Config {
  final int value;
  const Config.from(this.value);
}
const Config cfg = const .from(42); // Instead of const Config.from(42)
```

#### أفضل الممارسات
- تفضيل الاستخدام مع enums (خصوصًا في التعيينات وداخل switch) لكون الـ context واضح.
- توفير سياق typed واضح (نوع متوقَّع) علشان المترجم يحلّ الاختصار بشكل صحيح.
- تجنّب استخدام الاختصار في بداية تعبير كسطر مستقل؛ لا يجوز كتابة `.foo();` مباشرة.
- مراعاة الوضوح؛ لو الاختصار هيقلّل الوضوح، اكتب الاسم الكامل بدلًا منه.
- تجنّب الحالات الغامضة اللي ممكن يحصل فيها التباس على القارئ.

#### المراجع
- Dot shorthands: https://dart.dev/language/dot-shorthands

---

## تحديثات الأدوات

### شرح Analyzer plugins

#### مثال التفعيل
داخل `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - some_plugin
    - another_plugin
```

#### الشرح
الشرح: تقدر تعمل **custom lint rules** و **quick fixes** مخصّصة للمشروع علشان تفرض قواعد أسلوبية وتمنع أخطاء شائعة. النظام متكامل مع IDEs وكمان مع أوامر `dart analyze` و `flutter analyze`، وبالتالي نفس القواعد بتتطبق في كل البيئات.
الشرح: التفعيل بيكون عن طريق ملف `analysis_options.yaml` زي المثال اللي فوق، وده بيسهّل مشاركة الإعدادات على مستوى الفريق/المستودع.

#### المراجع
- Analyzer plugins: https://dart.dev/tools/analyzer-plugins
- Analysis options file: https://dart.dev/tools/analysis#the-analysis-options-file
- Writing an analyzer plugin: https://dart.dev/tools/analyzer-plugins

---

### شرح Build hooks (Stable)

#### الشرح
تسهّل **Build hooks** دمج وتجهيز **native code/assets** داخل package مباشرة بدون الحاجة لملفات بناء خاصة بكل منصة.

الشرح: الميزة دي بتسهّل إعادة استخدام **existing native code** أو **dynamic libraries** من غير ما تكتب ملفات بناء منفصلة (زي **CMake/Gradle/SPM**) لكل منصة.
الشرح: ده بيبسّط خطوط **CI/CD** وبيقلّل التعقيد وقت النشر وبناء الحزم متعددة المنصات.

#### المراجع
- Writing a build hook: https://dart.dev/tools/hooks
- Flutter Build show (build hooks): https://www.youtube.com/watch?v=AxNF5dj8HWQ

---

### شرح Remove deprecations lint

#### تعريف مختصر
تعريف: lint جديدة `remove_deprecations_in_breaking_versions` عشان تتأكد إن كل العناصر **deprecated** اتشالت قبل إصدار **major** جديد.

#### الشرح
الشرح: lint دي بتتأكّد إن أي عناصر معلّمة **@Deprecated** اتشالت قبل ما ترفع نسخة **major**، علشان تضمن **clean API surface** وما يحصلش التباس عند المستهلكين.

#### المراجع
- Lint rule: https://dart.dev/tools/linter-rules/remove_deprecations_in_breaking_versions/

![remove_deprecations_in_breaking_versions lint example](https://miro.medium.com/v2/resize:fit:700/1*keU2TVVnlbe0e0UFtj3mwA.png)



---

### شرح New @Deprecated annotations

#### القائمة
القائمة التالية توضّح annotations جديدة لتدقيق الاستخدامات بدقة:
- تعريف: `@Deprecated.extend()` — منع امتداد الـ class.
- تعريف: `@Deprecated.implement()` — منع تنفيذ class أو mixin.
- تعريف: `@Deprecated.subclass()` — منع الـ subclassing (extend/implement).
- تعريف: `@Deprecated.mixin()` — منع الـ mixin على class.
- تعريف: `@Deprecated.instantiate()` — منع إنشاء instance من class.
- تعريف: `@Deprecated.optional()` — إعلام إن باراميتر اختياري هيبقى required مستقبلاً.

#### الشرح
الشرح: بدل **@Deprecated** العامة، بقى فيه annotations أدق بتحدّد السلوك الممنوع (extend/implement/subclass/mixin/instantiate) بحيث التحذيرات تبقى واضحة ومباشرة للمستخدمين.
الشرح: `@Deprecated.optional()` بتوضح إن باراميتر اختياري هيبقى **required** في إصدار لاحق، وده بيسهّل الهجرة التدريجية بدون كسر التوافق فورًا.

#### المراجع
- API docs:
  - extend: https://api.dart.dev/dev/latest/dart-core/Deprecated/Deprecated.extend.html
  - implement: https://api.dart.dev/dev/latest/dart-core/Deprecated/Deprecated.implement.html
  - subclass: https://api.dart.dev/dev/latest/dart-core/Deprecated/Deprecated.subclass.html
  - mixin: https://api.dart.dev/dev/latest/dart-core/Deprecated/Deprecated.mixin.html
  - instantiate: https://api.dart.dev/dev/latest/dart-core/Deprecated/Deprecated.instantiate.html
  - optional: https://api.dart.dev/dev/latest/dart-core/Deprecated/Deprecated.optional.html

---

## تحديثات Pub

### شرح Likes tab: search/sort/unlike

#### الملخص
تقدر تعمل **search/sort/filter** على packages اللي عاملها **Like**. ومن البحث العام تقدر تستخدم `is:liked-by-me`.

#### الشرح
الشرح: من **Likes tab** تقدر تعمل **search/sort/filter** لـ packages اللي عاملها Like، وكمان تقدر تستخدم عامل التصفية `is:liked-by-me` في بحث pub.dev العادي علشان تقصر النتائج على packages اللي انت حاببها.

#### صور

![Search liked packages](https://miro.medium.com/v2/resize:fit:700/1*cO5K265sp2QbF-vNgcpFzQ.png)

---

### شرح Enable/disable manual publishing

#### الملخص
تقدر **تعطّل** النشر اليدوي `pub publish` من تبويب **Admin** لحماية package واعتماد **CI/CD**.

#### الشرح
الشرح: تقدر تعطّل `pub publish` اليدوي من تبويب **Admin** لو عندك **automated CI/CD** أو عايز تقلّل مخاطر الأخطاء أو الإصدارات غير المصرّح بيها.

#### صورة

![Enable or disable manual publishing](https://miro.medium.com/v2/resize:fit:700/1*qBE5Jhe138ktNrcBIy5L1w.png)

---

## الخلاصة

الخلاصة: الإصدار بيركّز على الإنتاجية، الأدوات، وصحة منظومة packages. للمزيد من التفاصيل الدقيقة راجع **Dart SDK changelog**.

#### الشرح
الشرح: الإصدار بيركّز على الإنتاجية وجودة الأدوات ومنظومة packages ككل. للتفاصيل منخفضة المستوى الخاصة بالـ SDK، راجع **Dart SDK changelog**.

---

## المراجع

- Dot shorthands: https://dart.dev/language/dot-shorthands
- Analyzer plugins: https://dart.dev/tools/analyzer-plugins
- Analysis options file: https://dart.dev/tools/analysis#the-analysis-options-file
- Writing a build hook: https://dart.dev/tools/hooks
- Lint rule: https://dart.dev/tools/linter-rules/remove_deprecations_in_breaking_versions/
- Deprecated annotations APIs:
  - extend: https://api.dart.dev/dev/latest/dart-core/Deprecated/Deprecated.extend.html
  - implement: https://api.dart.dev/dev/latest/dart-core/Deprecated/Deprecated.implement.html
  - subclass: https://api.dart.dev/dev/latest/dart-core/Deprecated/Deprecated.subclass.html
  - mixin: https://api.dart.dev/dev/latest/dart-core/Deprecated/Deprecated.mixin.html
  - instantiate: https://api.dart.dev/dev/latest/dart-core/Deprecated/Deprecated.instantiate.html
  - optional: https://api.dart.dev/dev/latest/dart-core/Deprecated/Deprecated.optional.html
- Dart SDK changelog: https://github.com/dart-lang/sdk/blob/main/CHANGELOG.md
