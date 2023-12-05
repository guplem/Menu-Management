import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    final MaterialStateProperty<Icon?> switchIcon = MaterialStateProperty.resolveWith<Icon?>((states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    });

    return Switch(
      thumbIcon: switchIcon,
      value: true,
      onChanged: (value) {
        // Do something
      },
    );
  }
}
