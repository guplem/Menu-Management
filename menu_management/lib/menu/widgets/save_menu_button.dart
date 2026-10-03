import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/persistency.dart";
import "package:menu_management/recipes/recipes_provider.dart";

/// The "Save Menu" button of the menu page and of the shopping page.
///
/// It asks [buildMenu] for the menu at the moment of the tap, so the caller can add state that
/// only it holds, for example the shopping progress on screen. A failed save shows a snackbar,
/// because `Persistency.saveMenu` lets the error of the save dialog or of the write through.
class SaveMenuButton extends StatelessWidget {
  const SaveMenuButton({super.key, required this.buildMenu});

  final MultiWeekMenu Function() buildMenu;

  Future<void> _save(BuildContext context) async {
    try {
      await Persistency.saveMenu(buildMenu(), recipes: RecipesProvider.instance.recipes);
    } catch (error, stack) {
      Debug.logError("Could not save the menu: $error", asException: false, stack: stack);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not save the menu. $error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      // Two buttons with the default hero tag on one page make Flutter throw at each page change.
      // A null hero tag turns off the hero animation of the button.
      heroTag: null,
      tooltip: "Save Menu",
      onPressed: () => _save(context),
      child: const Icon(Icons.save_rounded),
    );
  }
}
