import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Simple reusable button widget for previews
class ButtonShowcase extends StatelessWidget {
  const ButtonShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    // Basic elevated button used across previews
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: const Text('Press'),
    );
  }
}

/// Simple colored dot used to demo constructor previews
class ColorDot extends StatelessWidget {
  @Preview(name: 'ColorDot — default ctor')
  const ColorDot({super.key, this.color = Colors.red});

  /// Optional color to render
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Circle container to demonstrate size constraints
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
