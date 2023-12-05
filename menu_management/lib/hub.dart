import 'package:flutter/material.dart';
import 'package:menu_management/ingredients/widgets/ingredients_page.dart';
import 'package:menu_management/menu/widgets/menu_page.dart';
import 'package:menu_management/persistency.dart';

import 'recipes/widgets/recipes_page.dart';

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
            groupAlignment: -1,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            trailing: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.drive_folder_upload_rounded),
                    onPressed: () => Persistency.loadData(),
                    tooltip: 'Load data from file',
                  ),
                  const SizedBox(height: 10),
                  IconButton(
                    icon: const Icon(Icons.save_rounded),
                    onPressed: () => Persistency.saveData(),
                    tooltip: 'Save data to file',
                  ),
                ],
              ),
            ),
            labelType: NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.shopping_basket_outlined),
                selectedIcon: Icon(Icons.shopping_basket_rounded),
                label: Text('Ingredients'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.book_rounded),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: Text('Recipes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.set_meal_outlined), // Alternative: restaurant
                selectedIcon: Icon(Icons.set_meal_rounded), // Alternative: restaurant
                label: Text('Menu'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(child: Builder(
            builder: (BuildContext context) {
              switch (_selectedIndex) {
                case 0:
                  return const IngredientsPage();
                case 1:
                  return const RecipesPage();
                case 2:
                  return const MenuPage();
                default:
                  return const Center(child: Text('Error'));
              }
            },
          )),
        ],
      ),
    );
  }
}
