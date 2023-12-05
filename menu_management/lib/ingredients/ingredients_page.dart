import 'package:flutter/material.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/ingredients/ingredients_provider.dart';

class IngredientsPage extends StatelessWidget {
  const IngredientsPage({super.key});

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
            itemCount: ingredientsProvider.ingredients.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(ingredientsProvider.ingredients[index].name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    ingredientsProvider.removeIngredient(ingredientsProvider.ingredients[index]);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Ingredient removed'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            ingredientsProvider.addIngredient(ingredientsProvider.ingredients[index]);
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
      )
    );
  }
}