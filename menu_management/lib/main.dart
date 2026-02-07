import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:menu_management/hub.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/menu/menu_provider.dart";
import "package:menu_management/persistency.dart";
import "package:menu_management/recipes/recipes_provider.dart";
import "package:provider/provider.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => IngredientsProvider()),
        ChangeNotifierProvider(create: (context) => RecipesProvider()),
        ChangeNotifierProvider(create: (context) => MenuProvider()),
      ],
      child: MaterialApp(
        title: "Menu and Recipes Manager",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightGreen,
            brightness: PlatformDispatcher.instance.platformBrightness == Brightness.light ? Brightness.light : Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: Builder(
          builder: (context) {
            // Load data on startup
            if (!kDebugMode) {
              Persistency.loadData(
                ingredientsProvider: Provider.of<IngredientsProvider>(context, listen: false),
                recipesProvider: Provider.of<RecipesProvider>(context, listen: false),
              );
            }

            return const Hub();
          },
        ),
      ),
    );
  }
}
