import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'widgets.dart';

/// Multiple previews applied to a single function
@Preview(
  name: 'Example — light',
  brightness: Brightness.light,
)
@Preview(
  name: 'Example — dark',
  brightness: Brightness.dark,
)
Widget buttonShowcasePreview() => const ButtonShowcase();

