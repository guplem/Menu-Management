import 'package:flutter/material.dart';
import 'package:menu_management/hub.dart';
import 'package:menu_management/ingredients/ingredients_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => IngredientsProvider()),
        ],
        child: const Hub(),
      ),
    );
  }
}
