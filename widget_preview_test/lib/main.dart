import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

@Preview(
  name: 'Button – scaled',
  size: Size(300, 50),
  textScaleFactor: 1.2,
  brightness: Brightness.dark,
)
Widget buttonPreview() => ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.blue),
      child: const Text('Press'),
    );