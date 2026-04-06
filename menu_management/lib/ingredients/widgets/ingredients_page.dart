import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/widgets/ingredient_addition.dart";
import "package:menu_management/ingredients/widgets/ingredient_name_editor.dart";
import "package:menu_management/ingredients/widgets/product_editor.dart";

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key});

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  String _search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ingredients")),
      body: Builder(
        builder: (context) {
          IngredientsProvider ingredientsProvider = getProvider<IngredientsProvider>(context, listen: true);
          final normalizedSearch = _search.normalizeForSearch(removeSpaces: true);
          final filtered = normalizedSearch.isEmpty
              ? ingredientsProvider.ingredients
              : ingredientsProvider.ingredients.where((i) => i.name.normalizeForSearch(removeSpaces: true).contains(normalizedSearch)).toList();
          return ListView.builder(
            itemCount: filtered.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return IngredientAddition(onUpdate: (value) => setState(() => _search = value));
              }

              index--;

              return ListTile(
                title: Text(filtered[index].name),
                onTap: () {
                  IngredientNameEditor.show(
                    context: context,
                    ingredient: filtered[index],
                    onUpdate: (updatedIngredient) {
                      setState(() {}); // Trigger rebuild to reflect changes
                    },
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shopping_bag,
                        color: filtered[index].products.isNotEmpty ? Theme.of(context).colorScheme.primary : null,
                      ),
                      onPressed: () {
                        ProductEditor.show(
                          context: context,
                          ingredient: filtered[index],
                          onUpdate: (updatedIngredient) {
                            setState(() {});
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        Ingredient toRemove = filtered[index];
                        IngredientsProvider.remove(ingredientId: toRemove.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ingredient "${toRemove.name}" removed'),
                            action: SnackBarAction(
                              label: "Undo",
                              onPressed: () {
                                IngredientsProvider.addOrUpdate(newIngredient: toRemove);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
