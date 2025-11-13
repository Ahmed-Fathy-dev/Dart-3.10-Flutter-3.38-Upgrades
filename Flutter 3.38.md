# الشرح التفصيلي — What’s new in Flutter 3.38 (هيكل مبدئي)

## فهرس المحتوى
- 1. [شرح Dot shorthands](#dot-shorthands)
- 2. [تحديثات ال Web — `web_dev_config.yaml` و proxy و hot reload](#web-dev-proxy-hot-reload)
- 3. [تحديثات ال Framework — `OverlayPortal` و Predictive back و دعم Windows و تحسينات Lifecycle و إصلاحات Web و Android IME](#framework-updates)
- 4. [تحديثات Material و Cupertino — `WidgetState` migration و `IconButton.statesController` و `Badge.count(maxCount)` و `InkWell.onLongPressUp` وتحسينات iOS](#material-cupertino-updates)
- 5. [فصل Material و Cupertino — خطة الفصل والمراجع](#material-cupertino-decoupling)
- 6. [التمرير Scrolling — إصلاحات slivers و `SliverGrid.list` و focus navigation](#scrolling-slivers)
- 7. [الوصولية Accessibility — `ensureSemantics` و `debugDumpSemanticsTree` و `SliverSemantics` وتحسينات widgets](#accessibility)
- 8. [تحديثات ال iOS — دعم iOS 26/Xcode 26/macOS 26 و UIScene lifecycle migration](#ios-updates)
- 9. [تحديثات ال Android — 16KB page size و Memory fixes و Dependency matrix و SDK API vars](#android-updates)
- 10. [تحديثات ال Engine — Performance overlay و Vulkan/OpenGL ES و Renderer unification و Thread merging](#engine-updates)
- 11. [تحديثات ال DevTools و IDEs — Widget Previews updates و Known issue و DevTools fixes](#devtools-ides-updates)
- 12. [كسر التوافق — Deprecations and breaking changes](#breaking-changes)
- 13. [الخاتمة](#outro)

---

<a name="dot-shorthands"></a>
## شرح Dot shorthands

الشرح: الميزة دي من Dart 3.10، وبتخليك تستخدم اختصارات بنقطة لِلوصول لقيم الـ enums، أو استدعاء constructors، أو الوصول لـ static members من غير ما تكرّر اسم النوع طالما الـ type معروف من الـ context. ده بيقلّل الـ boilerplate في كود Flutter ويزود readability.

#### أمثلة

```dart
// Enum in assignment/switch
enum LogLevel { debug, info, warning, error }

String colorFor(LogLevel level) {
  // Use dot shorthand inside switch
  return switch (level) {
    .debug => 'gray',
    .info => 'blue',
    .warning => 'orange',
    .error => 'red',
  };
}

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

// Const constructor shorthand (context provides the type)
class Config {
  final int value;
  const Config.from(this.value);
}
const Config cfg = .from(42); // Instead of const Config.from(42)
```

#### أفضل الممارسات
- استخدمها مع سياق typed واضح؛ لو النوع مش واضح للقارئ، اكتب الاسم الكامل.
- تُفضَّل مع enums في التعيينات وداخل switch حيث يكون الـ context واضح جدًا.
- لا تبدأ سطر تعبير بـ الاختصار مباشرة؛ لا يجوز `.foo();` كسطر مستقل (قيّد لغوي رسمي).
- قدّم الوضوح على الاختصار لو حصل التباس.

#### المراجع
- مرجع: Dot shorthands (dart.dev): https://dart.dev/language/dot-shorthands

---

<a name="web-dev-proxy-hot-reload"></a>
## تحديثات ال Web — إعدادات التطوير و proxy و hot reload

الشرح: ابتداءً من Flutter 3.38 بقى فيه دعم رسمي لملف إعدادات تطوير الويب `web_dev_config.yaml` في جذر المشروع. الهدف توحيد إعدادات الـ development server (host/port/HTTPS/headers/proxy) بدل تمريرها كـ CLI flags، بحيث تشتغل تلقائيًا أثناء `flutter run`.

#### أمثلة (web_dev_config.yaml)

```yaml
# Server host/port/HTTPS
server:
  host: "0.0.0.0"        # Binding address (string)
  port: 8080              # Dev server port (int)
  https:
    cert-path: "/path/to/cert.pem"     # TLS cert (string)
    cert-key-path: "/path/to/key.pem"  # TLS key  (string)
```

```yaml
# Inject custom HTTP headers
server:
  headers:
    - name: "X-Custom-Header"
      value: "MyValue"
    - name: "Cache-Control"
      value: "no-cache, no-store, must-revalidate"
```

```yaml
# Basic string prefix proxy rules (matched in order)
server:
  proxy:
    - target: "http://localhost:5000/"
      prefix: "/users/"
    - target: "http://localhost:3000/"
      prefix: "/data/"
      replace: "/report/"   # Rewrites /data/... to /report/...
    - target: "http://localhost:4000/"
      prefix: "/products/"
      replace: ""            # Removes the /products/ prefix
```

#### خطوات التشغيل
- شغّل التطبيق: `flutter run -d chrome` أو `flutter run -d web-server` حسب تفضيلك.
- هيتم قراءة `web_dev_config.yaml` تلقائيًا من جذر المشروع وتطبيق الإعدادات.

#### ملاحظات مهمة
- الطلبات بتتطابق بالترتيب المكتوب في `web_dev_config.yaml` (الأولوية من أعلى لأسفل).
- دلوقتى Hot reload للويب مفعّل افتراضيًا من إصدارات سابقة (3.35+)، و3.38 يكمل عليه؛ استخدمه لتحسين دورة التطوير.
- لو حصل التباس في قواعد الـ proxy، راجع ترتيب القواعد وحقول `prefix/replace`.

#### المراجع
- مرجع: Web dev config file: https://docs.flutter.dev/platform-integration/web/web-dev-config-file
- مرجع: Building a web application with Flutter (hot reload note): https://docs.flutter.dev/platform-integration/web/building

---

<a name="framework-updates"></a>
## تحديثات ال Framework — القدرات الجديدة والتحسينات

الشرح: سكشن الـ Framework في 3.38 بيضيف أدوات وأنماط تيسّر بناء واجهات تفاعلية ومتوافقة مع المنصات، أبرزها `OverlayPortal` وسلوك `Predictive back` على Android، بجانب تحسينات على Windows وIME.

#### شرح OverlayPortal
الشرح: يسهّل `OverlayPortal` عرض عناصر فوق الشجرة (tooltips/menus) بمكان واحد قريب من الـ widget المستهدف، بدون إدارة يدوية لـ `OverlayEntry`.

```dart
// Simple menu using OverlayPortal
class MoreMenuButton extends StatefulWidget {
  const MoreMenuButton({super.key});
  @override
  State<MoreMenuButton> createState() => _MoreMenuButtonState();
}

class _MoreMenuButtonState extends State<MoreMenuButton> {
  final _controller = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) {
        // Build the overlay content
        return Center(
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: const [
                  ListTile(title: Text('Item 1')),
                  ListTile(title: Text('Item 2')),
                ],
              ),
            ),
          ),
        );
      },
      child: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _controller.toggle(), // Show/Hide overlay
      ),
    );
  }
}
```

ملاحظات:
- تجنّب استدعاء `show()/hide()/toggle()` أثناء إعادة بناء الشجرة.
- راجع `OverlayPortalController` لإدارة الإظهار/الإخفاء.

مراجع:
- مرجع: OverlayPortal (API): https://api.flutter.dev/flutter/widgets/OverlayPortal-class.html
- مرجع: OverlayPortalController (API): https://api.flutter.dev/flutter/widgets/OverlayPortalController-class.html

#### الرجوع التنبؤي Predictive back (Android)
الشرح: يضيف Flutter دعمًا لحركة الرجوع التنبؤية على Android. لازم تفعّل الإعدادات على الجهاز وتضبط سمة الانتقال في تطبيقك.

```dart
// Enable predictive back transitions on Android
MaterialApp(
  theme: ThemeData(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    ),
  ),
  // ...
);
```

خطوات أساسية:
- فعل `android:enableOnBackInvokedCallback="true"` داخل `android/app/src/main/AndroidManifest.xml`.
- فعّل خيار Developer options على جهاز Android ثم فعّل Predictive back animations.
- استخدم Flutter حديث (المستندات الحالية تعكس 3.38).

مراجع:
- مرجع: Predictive back (guide): https://docs.flutter.dev/platform-integration/android/predictive-back
- مرجع: Predictive back (breaking change): https://docs.flutter.dev/release/breaking-changes/android-predictive-back

#### تحسينات Windows و IME
الشرح: تحسينات على Windows لعرض معلومات الشاشات (قائمة الشاشات، الحجم، معدل التحديث) وتحسين دقة معرف العرض في events، وتحديثات على الـ runloop. كذلك تحسينات في Android IME لسلوك إدخال النص.

مراجع:
- مرجع: Flutter 3.38.0 release notes: https://docs.flutter.dev/release/release-notes/release-notes-3.38.0

---

<a name="material-cupertino-updates"></a>
## تحديثات Material و Cupertino

الشرح: في 3.38 تم تحسين عناصر Material بعدّة إضافات، منها دعمٍ أوضح للتحكّم في الحالات عبر `statesController`، وتسهيل عرض الأعداد الكبيرة في `Badge.count`، وإضافة حدث `onLongPressUp` في `InkWell`. كما تضمّن الإصدار تحسينات على عناصر Cupertino (راجِع الملاحظات الرسمية للتفاصيل الدقيقة).

#### التحكم بالحالات IconButton.statesController
الشرح: تقدر تمرّر `statesController` للتحكّم في الحالات التفاعلية (pressed/hovered/focused)، واستخدامها مع `WidgetStateProperty` لحلّ القيم حسب الحالة.

```dart
// Control interactive states via a statesController
final controller = MaterialStatesController();

IconButton(
  statesController: controller,
  icon: const Icon(Icons.favorite),
  onPressed: () {},
  // You can resolve styles based on states using WidgetStateProperty (via style)
);
```

مراجع:
- مرجع: IconButton (API): https://api.flutter.dev/flutter/material/IconButton-class.html
- مرجع: WidgetStatesController (API): https://api.flutter.dev/flutter/widgets/WidgetStatesController-class.html

#### توضيح Badge.count(maxCount)
الشرح: مُنشئ `Badge.count` بقى عنده باراميتر `maxCount` لتقليل النص المعروض (مثلاً "99+").

```dart
// Cap the displayed count with maxCount
Badge.count(
  count: 120,
  maxCount: 99,
  child: const Icon(Icons.mail),
);
```

مراجع:
- مرجع: Badge.count (API): https://api.flutter.dev/flutter/material/Badge/Badge.count.html

#### حدث InkWell.onLongPressUp
الشرح: إضافة حدث `onLongPressUp` لتشغيل منطق بعد رفع الإصبع من الضغط المطوّل (مختلف عن `onLongPress`).

```dart
// Handle both long press and release
InkWell(
  onLongPress: () {
    // Start long-press action
  },
  onLongPressUp: () {
    // Finalize when finger is released
  },
  child: const Padding(
    padding: EdgeInsets.all(16),
    child: Text('Hold me'),
  ),
);
```

مراجع:
- مرجع: InkWell (API): https://api.flutter.dev/flutter/material/InkWell-class.html

---

<a name="material-cupertino-decoupling"></a>
## فصل Material و Cupertino — Decoupling

الشرح: الهدف فصل مكتبات **Material** و**Cupertino** عن نواة Flutter (framework) ونقلها كحِزم أول‑طرف مستقلة ضمن `flutter/packages`. ده يسمح بتحديثات أسرع ودورات إصدار مستقلة، وتخفيف ترابط النواة بما يسهّل تبنّي واجهات أخرى مستقبلًا.

#### ماذا يعني ذلك الآن (Flutter 3.38)
- لا يوجد تغيير break changes على استيرادك الحالي (`package:flutter/material.dart` و`package:flutter/cupertino.dart`).
- تركيز الفريق على تحسين عملية إصدار `flutter/packages` تمهيدًا لضم Material وCupertino بعد الفصل.
- أي تغييرات جوهرية مستقبلًا سيتم توفير أدلة migration لها قبل تطبيقها.

#### إرشادات للمطورين
- استخدم واجهات الـ API العامة فقط؛ تجنّب الاستيراد من مسارات داخلية (`package:flutter/src/...`).
- حافظ على الأنماط عبر themes و`WidgetStateProperty` بدل الاعتماد على سلوك داخلي.
- لمؤلفي الحِزم: افصل الاعتماد على framework عن عناصر Material/Cupertino عند الإمكان، وتجنّب ربط التنفيذ بسلوك داخلي غير موثّق.

#### لماذا يتم الفصل؟
- تسريع تطوير Material/Cupertino وإصدار تحديثاتها بمعزل عن دورة إصدار framework.
- تقليل حجم وترابط النواة، وفتح المجال لواجهات تصميم أخرى بالتوازي.

#### المراجع
- مرجع: What’s new in Flutter 3.38 (blog): https://blog.flutter.dev/whats-new-in-flutter-3-38-3f7b258f7228
- مرجع: What’s new in Flutter 3.35 (blog) + رابط خطة الفصل: https://blog.flutter.dev/whats-new-in-flutter-3-35-c58ef72e3766
- مرجع: Umbrella issue (GitHub): https://github.com/flutter/flutter/issues/101479
- مرجع: Decoupling Design in Flutter (design doc): https://docs.google.com/document/d/189AbzVGpxhQczTcdfJd13o_EL36t-M5jOEt1hgBIh7w/edit

---

<a name="scrolling-slivers"></a>
## التمرير Scrolling — Slivers

الشرح: من التسهيلات الملحوظة وجود مُنشئ ملائم `SliverGrid.list` لبناء شبكة عناصر من قائمة جاهزة، إلى جانب إصلاحات متفرّقة في سلوك slivers وتحسينات للتنقل بالتركيز.

#### مثال SliverGrid.list

```dart
// Build a grid from a fixed list of children
CustomScrollView(
  slivers: [
    SliverGrid.list(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      children: const [
        ColoredBox(color: Colors.blue, child: SizedBox(height: 100)),
        ColoredBox(color: Colors.green, child: SizedBox(height: 100)),
        ColoredBox(color: Colors.red, child: SizedBox(height: 100)),
        ColoredBox(color: Colors.orange, child: SizedBox(height: 100)),
      ],
    ),
  ],
);
```

مراجع:
- مرجع: SliverGrid (API): https://api.flutter.dev/flutter/widgets/SliverGrid-class.html
- مرجع: Flutter 3.38.0 release notes: https://docs.flutter.dev/release/release-notes/release-notes-3.38.0

---

<a name="accessibility"></a>
## ال Accessibility

الشرح: أضاف الإصدار تحسينات تتعلّق بتشخيص الـ Semantics على مستوى الشجرة، ودعم أفضل لـ slivers.

#### تشخيص debugDumpSemanticsTree
الشرح: لطباعة تمثيل نصّي لشجرة الـ Semantics لغرض التشخيص.

```dart
// Print the semantics tree in traversal order
debugDumpSemanticsTree(DebugSemanticsDumpOrder.traversalOrder);
```

#### تفعيل ensureSemantics
الشرح: لتمكين إنشاء شجرة Semantics برمجيًا والحصول على مقبض لإدارتها أثناء التشخيص.

```dart
// Enable semantics tree and obtain a handle (dispose when done)
final handle = SemanticsBinding.instance.ensureSemantics();
// ... perform diagnostics that rely on semantics ...
handle.dispose();
```

#### دعم SliverSemantics
الشرح: استخدام `SliverSemantics` لدعم semantics على مستوى slivers داخل `CustomScrollView`.

```dart
// Add semantics to a sliver
CustomScrollView(
  slivers: [
    SliverSemantics(
      container: true,
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          const ListTile(title: Text('Item A')),
          const ListTile(title: Text('Item B')),
        ]),
      ),

---

<a name="ios-updates"></a>
## تحديثات ال iOS
الشرح: آبل تتجه لفرض اعتماد **UIScene lifecycle** بدل دورة حياة `AppDelegate` التقليدية. مع Flutter، لازم تهاجر لمسار **UISceneDelegate** لأن من بعد iOS حديث (وفق إعلان آبل) التطبيقات المبنية بآخر SDK مش هتشتغل من غير UIScene.

#### خطوات سريعة (migration تلقائية عبر Flutter CLI)
- فعّل ميزة ال migration :
```bash
flutter config --enable-uiscene-migration
```
- ابنِ أو شغّل التطبيق:
```bash
flutter run
# أو
flutter build ios
```
- في حال نجاح ال migration سيظهر إشعار يؤكد إتمام الانتقال إلى UIScene lifecycle. عند الفشل (مثل وجود تخصيصات في AppDelegate)، اتبع خطوات ال migration اليدوية في الدليل.

#### ملاحظات مهمة
- بعد ال migration **منطق واجهة المستخدم** يبقى داخل `UISceneDelegate`، و`AppDelegate` يتعامل مع أحداث العملية العامة فقط.
- راجع التعديلات المطلوبة في `Info.plist` وملفات الـ delegate لو احتجت migration يدوية.

#### المراجع
- مرجع: UISceneDelegate adoption (breaking change): https://docs.flutter.dev/release/breaking-changes/uiscenedelegate

---

<a name="android-updates"></a>
## تحديثات ال Android

الشرح: يتضمن الإصدار تحسينات عامة على الاستقرار وإدارة الذاكرة ودعم إعدادات بيئة البناء. للاطلاع على التفاصيل الدقيقة (بما فيها تحديثات مصفوفة الاعتماد dependency matrix ومتغيرات SDK)، راجع ملاحظات الإصدار الرسمية.

#### مراجع
- مرجع: Flutter 3.38.0 release notes: https://docs.flutter.dev/release/release-notes/release-notes-3.38.0
- مرجع: Android platform setup: https://docs.flutter.dev/get-started/install

---

<a name="engine-updates"></a>
## تحديثات ال Engine

الشرح: يتناول هذا المحور تحديثات متفرقة في الـ engine (رسوميات/مسارات التنفيذ/تحسينات تشخيصية). راجع ملاحظات الإصدار للاطلاع على تفاصيل Vulkan/OpenGL ES وأي توحيد/تغييرات في الـ renderer.

#### مثال (Performance overlay)
الشرح: لتتبّع الأداء أثناء التطوير يمكنك إظهار طبقة الأداء.

```dart
// Show performance overlay during development
MaterialApp(
  showPerformanceOverlay: true,
  home: const MyHomePage(),
);
```

#### مراجع
- مرجع: Flutter 3.38.0 release notes: https://docs.flutter.dev/release/release-notes/release-notes-3.38.0
- مرجع: MaterialApp.showPerformanceOverlay (API): https://api.flutter.dev/flutter/material/MaterialApp/showPerformanceOverlay.html

---

<a name="devtools-ides-updates"></a>
## تحديثات ال DevTools و IDEs

الشرح: تشمل تحسينات على **Widget Previews** وعلى **DevTools** (إصلاحات واستقرار). للتفاصيل الدقيقة ارجع لصفحة الإصدار.

#### ملاحظة Known issue
الشرح: لو واجهت سلوكًا متأثرًا بإصدار الأدوات، راجع قسم known issues في ملاحظات الإصدار لهذا الإصدار للتتبّع والحلول المقترحة.

#### مراجع
- مرجع: Flutter 3.38.0 release notes: https://docs.flutter.dev/release/release-notes/release-notes-3.38.0
- مرجع: DevTools: https://docs.flutter.dev/tools/devtools/overview

---

<a name="breaking-changes"></a>
## ال Deprecations and breaking changes

الشرح: راجع صفحة **Breaking changes** لإصدارات Flutter للاطلاع على أي تغييرات تتطلب migration. من أبرز ما ستحتاج إليه فعليًا:
- اعتماد **Predictive back** على Android: تجنّب `WillPopScope` واستخدم `PopScope`.
- اعتماد **UIScene lifecycle** على iOS: ال migration إلى `UISceneDelegate`.

#### مثال migration (WillPopScope -> PopScope)

```dart
// Before: WillPopScope
WillPopScope(
  onWillPop: () async => true,
  child: const MyPage(),
);

// After: PopScope
PopScope(
  canPop: true,
  onPopInvoked: (didPop) {
    if (!didPop) {
      Navigator.of(context).pop();
    }
  },
  child: const MyPage(),
);
```

#### مراجع
- مرجع: Predictive back (guide): https://docs.flutter.dev/platform-integration/android/predictive-back
- مرجع: Predictive back (breaking change): https://docs.flutter.dev/release/breaking-changes/android-predictive-back
- مرجع: UISceneDelegate adoption: https://docs.flutter.dev/release/breaking-changes/uiscenedelegate

---
#### مراجع إضافية
- مرجع: Flutter 3.38.0 : https://blog.flutter.dev/whats-new-in-flutter-3-38-3f7b258f7228
- مرجع: Release notes (index): https://docs.flutter.dev/release/release-notes
