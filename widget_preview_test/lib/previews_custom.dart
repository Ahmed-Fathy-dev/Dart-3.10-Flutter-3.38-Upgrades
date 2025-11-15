import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

// Wrapper: top-level public function (constant tear-off for annotation)
Widget wrapInCard(Widget child) {
  // Wrap previewed widget into a Card for better visual context
  return Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Center(child: child),
    ),
  );
}

// Custom annotation: extend Preview to provide default theming
final class MyCustomPreview extends Preview {
  const MyCustomPreview({
    super.name,
    super.size,
    super.textScaleFactor,
    super.brightness,
  }) : super(theme: MyCustomPreview.themeBuilder);

  // Theme builder: provides Material/Cupertino theme data
  static PreviewThemeData themeBuilder() {
    return PreviewThemeData(
      materialLight: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      materialDark: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
    );
  }
}

// Usage: apply custom preview annotation
@MyCustomPreview(name: 'Custom themed text', size: Size(260, 80))
Widget themedTextPreview() {
  // Preview: text styled by theme
  return const Text('Themed Hello');
}
