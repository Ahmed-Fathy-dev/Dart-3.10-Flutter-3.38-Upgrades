import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Basic previews: top-level functions and WidgetBuilder

@Preview(name: 'Text — hello world')
Widget mySampleText() {
  // Preview: simple text widget
  return const Text('Hello, World!');
}

@Preview(
  name: 'Container — sized',
  size: Size(200, 100), // Constrain preview area
  textScaleFactor: 1.0,
  brightness: Brightness.light,
)
Widget sizedContainer() {
  // Preview: fixed size container to show constraints
  return Container(
    color: Colors.amber,
    child: const Center(child: Text('Sized Box')),
  );
}

@Preview(name: 'Builder — green box')
WidgetBuilder greenBoxBuilder() {
  // Preview: WidgetBuilder form
  return (context) => Container(
        width: 120,
        height: 80,
        color: Colors.green,
        alignment: Alignment.center,
        child: const Text('Builder'),
      );
}

class StaticDemos {
  const StaticDemos._();

  @Preview(name: 'Static — card with icon')
  static Widget staticCard() {
    // Preview: static method inside a class
    return const Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.orange),
            SizedBox(width: 8),
            Text('Starred'),
          ],
        ),
      ),
    );
  }
}
