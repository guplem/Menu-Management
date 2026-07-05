import "package:flutter/material.dart";

/// Shows a modal confirmation dialog before deleting an entity that is referenced elsewhere.
/// [message] explains the consequences and [affectedItems] lists what references the entity.
/// Returns true only when the user confirms the deletion.
Future<bool> showDeleteConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required List<String> affectedItems,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        icon: const Icon(Icons.warning_rounded),
        title: Text(title),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(dialogContext).size.height * 0.6),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                const SizedBox(height: 10),
                ...affectedItems.map((String item) => Text("- $item")),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text("Cancel")),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text("Delete")),
        ],
      );
    },
  );
  return confirmed ?? false;
}
