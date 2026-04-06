import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
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
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showStartupDialogs());
  }

  Future<void> _showStartupDialogs() async {
    final IngredientsProvider ingredientsProvider = Provider.of<IngredientsProvider>(context, listen: false);
    final RecipesProvider recipesProvider = Provider.of<RecipesProvider>(context, listen: false);

    // Dialog 1: Load recipe book?
    String? lastTsrPath = Persistency.lastTsrPath;
    String? recipeChoice = await _showLoadDialog(
      title: "Load a recipe book?",
      lastSessionLabel: lastTsrPath != null ? "Load last saved" : null,
      defaultLabel: "Load default",
    );

    if (!mounted) return;

    bool recipesLoaded = false;
    if (recipeChoice == "last_session") {
      recipesLoaded = await Persistency.loadDataFromPath(
        path: lastTsrPath!,
        ingredientsProvider: ingredientsProvider,
        recipesProvider: recipesProvider,
      );
      if (!recipesLoaded && mounted) {
        await _showErrorDialog("Could not load the last saved recipe book. The file may have been moved or corrupted.");
      }
    } else if (recipeChoice == "default") {
      recipesLoaded = await _tryLoadDefaultRecipes(ingredientsProvider, recipesProvider);
    }

    if (!mounted) return;
    setState(() => _initialized = true);

    // Only ask about menu if recipes were loaded
    if (!recipesLoaded) return;

    // Dialog 2: Load weekly menu?
    String? lastTsmPath = Persistency.lastTsmPath;
    String? menuChoice = await _showLoadDialog(
      title: "Load a weekly menu?",
      lastSessionLabel: lastTsmPath != null ? "Load last saved" : null,
      defaultLabel: "Load default",
    );

    if (!mounted) return;

    MultiWeekMenu? menu;
    if (menuChoice == "last_session") {
      menu = await Persistency.loadMenuFromPath(lastTsmPath!, recipes: recipesProvider.recipes);
      if (menu == null && mounted) {
        await _showErrorDialog("Could not load the last saved menu. The file may have been moved or corrupted.");
      }
    } else if (menuChoice == "default") {
      menu = await _tryLoadDefaultMenu();
    }

    if (menu != null && mounted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MenuPage(multiWeekMenu: menu!)));
    }
  }

  Future<bool> _tryLoadDefaultRecipes(IngredientsProvider ingredientsProvider, RecipesProvider recipesProvider) async {
    try {
      await Persistency.loadDefaultRecipes(ingredientsProvider: ingredientsProvider, recipesProvider: recipesProvider);
      return true;
    } catch (e) {
      if (mounted) {
        await _showErrorDialog("Could not load the default recipe book: $e");
      }
      return false;
    }
  }

  Future<MultiWeekMenu?> _tryLoadDefaultMenu() async {
    try {
      return await Persistency.loadDefaultMenu(recipes: RecipesProvider.instance.recipes);
    } catch (e) {
      if (mounted) {
        await _showErrorDialog("Could not load the default menu: $e");
      }
      return null;
    }
  }

  /// Shows a dialog with up to 3 options: last session, default, no.
  /// Returns "last_session", "default", or "no".
  Future<String?> _showLoadDialog({required String title, required String? lastSessionLabel, required String defaultLabel}) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop("no"), child: const Text("No")),
            FilledButton(onPressed: () => Navigator.of(dialogContext).pop("default"), child: Text(defaultLabel)),
            if (lastSessionLabel != null)
              FilledButton(onPressed: () => Navigator.of(dialogContext).pop("last_session"), child: Text(lastSessionLabel)),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text("OK"))],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return const Hub();
  }
}
