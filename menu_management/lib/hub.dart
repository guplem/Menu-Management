import "package:flutter/material.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/widgets/ingredients_page.dart";
import "package:menu_management/menu/widgets/menu_configuration_page.dart";
import "package:menu_management/persistency.dart";
import "package:menu_management/recipes/recipes_provider.dart";
import "package:provider/provider.dart";

import "package:menu_management/recipes/widgets/recipes_page.dart";

class Hub extends StatefulWidget {
  const Hub({super.key});

  @override
  State<Hub> createState() => _HubState();
}

class _HubState extends State<Hub> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            // groupAlignment: -1,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            trailing: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.drive_folder_upload_rounded),
                    onPressed: () => Persistency.loadData(
                      ingredientsProvider: Provider.of<IngredientsProvider>(context, listen: false),
                      recipesProvider: Provider.of<RecipesProvider>(context, listen: false),
                    ),
                    tooltip: "Load data from file",
                  ),
                  const SizedBox(height: 10),
                  // Save functionality not available on mobile platforms
                  if (Theme.of(context).platform != TargetPlatform.iOS && Theme.of(context).platform != TargetPlatform.android)
                    IconButton(icon: const Icon(Icons.save_rounded), onPressed: () => Persistency.saveData(), tooltip: "Save data to file"),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            labelType: NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.shopping_basket_outlined),
                selectedIcon: Icon(Icons.shopping_basket_rounded),
                label: Text("Ingredients"),
              ),
              NavigationRailDestination(icon: Icon(Icons.book_rounded), selectedIcon: Icon(Icons.menu_book_rounded), label: Text("Recipes")),
              NavigationRailDestination(
                icon: Icon(Icons.set_meal_outlined), // Alternative: restaurant
                selectedIcon: Icon(Icons.set_meal_rounded), // Alternative: restaurant
                label: Text("Menu"),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(
            child: Builder(
              builder: (BuildContext context) {
                switch (_selectedIndex) {
                  case 0:
                    return const IngredientsPage();
                  case 1:
                    return const RecipesPage();
                  case 2:
                    return const MenuConfigurationPage();
                  default:
                    return const Center(child: Text("Error"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
