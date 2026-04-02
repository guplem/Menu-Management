import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:menu_management/default_data.dart";
import "package:menu_management/hub.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/menu/menu_provider.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/widgets/menu_page.dart";
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
    var color = ColorScheme.fromSeed(
      seedColor: Colors.lightGreen,
      brightness: PlatformDispatcher.instance.platformBrightness == Brightness.light ? Brightness.light : Brightness.dark,
    );

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
          colorScheme: color,
          snackBarTheme: SnackBarThemeData(
            backgroundColor: color.surfaceContainer,
            contentTextStyle: TextStyle(color: color.onSurface),
          ),
          useMaterial3: true,
        ),
        home: const _AppHome(),
      ),
    );
  }
}

class _AppHome extends StatefulWidget {
  const _AppHome();

  @override
  State<_AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<_AppHome> {
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final IngredientsProvider ingredientsProvider = Provider.of<IngredientsProvider>(context, listen: false);
    final RecipesProvider recipesProvider = Provider.of<RecipesProvider>(context, listen: false);

    // Try loading from last session first
    bool recipesLoaded = false;
    String? lastTsrPath = Persistency.lastTsrPath;
    if (lastTsrPath != null) {
      recipesLoaded = await Persistency.loadDataFromPath(
        path: lastTsrPath,
        ingredientsProvider: ingredientsProvider,
        recipesProvider: recipesProvider,
      );
    }

    // Fall back to bundled defaults
    if (!recipesLoaded) {
      await DefaultData.loadDefaultRecipes(
        ingredientsProvider: ingredientsProvider,
        recipesProvider: recipesProvider,
      );
    }

    if (!mounted) return;
    setState(() => _dataLoaded = true);

    // Try loading menu from last session first, then fall back to default
    MultiWeekMenu? menu;
    String? lastTsmPath = Persistency.lastTsmPath;
    if (lastTsmPath != null) {
      menu = await Persistency.loadMenuFromPath(lastTsmPath);
    }
    menu ??= await DefaultData.loadDefaultMenu();

    if (mounted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MenuPage(multiWeekMenu: menu!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_dataLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return const Hub();
  }
}
