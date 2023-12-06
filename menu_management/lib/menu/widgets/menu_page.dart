import 'package:flutter/material.dart';
import 'package:menu_management/flutter_essentials/library.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MaterialStateProperty<Icon?> switchIcon = MaterialStateProperty.resolveWith<Icon?>((states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.fastfood_rounded);
      }
      return const Icon(Icons.close);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            tooltip: "Open Menu",
            icon: const Icon(Icons.file_open),
            onPressed: () {
              // TODO: Load menu from file
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Generate Menu",
        child: const Icon(Icons.auto_awesome_sharp),
        onPressed: () {
          // TODO: Generate menu
        },
      ),
      body: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleLarge!,
                    child: Builder(builder: (context) {
                      switch (index) {
                        case 0:
                          return const Text('Saturday');
                        case 1:
                          return const Text('Sunday');
                        case 2:
                          return const Text('Monday');
                        case 3:
                          return const Text('Tuesday');
                        case 4:
                          return const Text('Wednesday');
                        case 5:
                          return const Text('Thursday');
                        case 6:
                          return const Text('Friday');
                        default:
                          return const Text('Error');
                      }
                    }),
                  ),
                ),
                ...List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DefaultTextStyle(
                            style: Theme.of(context).textTheme.titleMedium!,
                            child: Builder(
                              builder: (context) {
                                switch (index) {
                                  case 0:
                                    return const Text('Breakfast');
                                  case 1:
                                    return const Text('Lunch');
                                  case 2:
                                    return const Text('Dinner');
                                  default:
                                    return const Text('Error');
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 5),
                          Switch(
                            thumbIcon: switchIcon,
                            value: true,
                            onChanged: (value) {
                              // Do something
                            },
                          ),
                          const SizedBox(height: 5),
                          const SizedBox(
                            width: 140,
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Cooking time',
                                suffixText: "min",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
