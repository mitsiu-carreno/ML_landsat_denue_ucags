import 'package:charts/chartpage.dart';
import 'package:flutter/material.dart';
// Importamos el archivo donde definimos ChartPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      brightness: MediaQuery.platformBrightnessOf(context),
      seedColor: Colors.indigo,
    );
    return MaterialApp(
      title: 'Flutter Chart Example',
      theme: ThemeData(
        colorScheme: colorScheme,
      ),
      home:
          const ChartPage(), // Aquí especificamos que ChartPage será la página inicial
    );
  }
}
