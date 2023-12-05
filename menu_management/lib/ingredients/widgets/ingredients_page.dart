import 'package:flutter/material.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/ingredients/models/ingredient.dart';
import 'package:menu_management/ingredients/widgets/ingredient_addition.dart';
import 'package:menu_management/ingredients/ingredients_provider.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key});

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Ingredients'),
        ),
        body: Builder(
          builder: (context) {
            IngredientsProvider ingredientsProvider = getProvider<IngredientsProvider>(context, listen: true);
            return ListView.builder(
              itemCount: ingredientsProvider.ingredients.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const IngredientAddition();
                }

                index--;

                return ListTile(
                  title: Text(ingredientsProvider.ingredients[index].name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      Ingredient toRemove = ingredientsProvider.ingredients[index];
                      IngredientsProvider.remove(ingredientId: toRemove.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ingredient "${toRemove.name}" removed'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              IngredientsProvider.addOrUpdate(newIngredient: toRemove);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ));
  }
}
