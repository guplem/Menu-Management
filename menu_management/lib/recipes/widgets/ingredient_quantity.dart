// import 'package:flutter/material.dart';
// import 'package:menu_management/recipes/models/ingredient_usage.dart';
// import 'package:menu_management/recipes/models/instruction.dart';
//
// class IngredientQuantity extends StatefulWidget {
//   const IngredientQuantity({super.key, required this.onUpdate, required this.originalInstruction});
//
//   final Instruction originalInstruction;
//   final Function(Instruction newInstruction) onUpdate;
//
//   @override
//   State<IngredientQuantity> createState() => _IngredientQuantityState();
// }
//
// class _IngredientQuantityState extends State<IngredientQuantity> {
//
//   late Instruction newInstruction;
//
//   @override
//   void initState() {
//     super.initState();
//     newInstruction = widget.originalInstruction;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(ingredientUsage.ingredient.name),
//       trailing: IconButton(
//         icon: const Icon(Icons.delete),
//         onPressed: () {
//           setState(() {
//             newInstruction = newInstruction.copyWith(ingredientsUsed: newInstruction.ingredientsUsed.where((IngredientUsage usage) => usage != ingredientUsage).toList());
//           });
//           widget.onUpdate(newInstruction);
//         },
//       ),
//     );
//   }
// }
