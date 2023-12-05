// import "dart:async";
// import "package:flutter/foundation.dart";
// import "package:internet_connection_checker_plus/internet_connection_checker_plus.dart";
// import "package:menu_management/flutter_essentials/library.dart";
//
// // https://docs.flutter.dev/development/data-and-backend/state-mgmt/simple
// class InternetConnectivityProvider extends ChangeNotifier {
//   InternetConnectivityProvider() {
//     instance = this; // Singleton pattern
//
//     listener = InternetConnectionCheckerPlus().onStatusChange.listen(
//       (InternetConnectionStatus status) {
//         switch (status) {
//           case InternetConnectionStatus.connected:
//             // ignore: avoid_print
//             setAndNotifyIfUpdated(true);
//             break;
//           case InternetConnectionStatus.disconnected:
//             setAndNotifyIfUpdated(false);
//             break;
//         }
//       },
//     );
//   }
//
//   /// Recommended to use this when notifications about updates are not required instead of using getProvider<InternetConnectivityProvider>(context, listen: false). Reason: avoid over use of context
//   static late final InternetConnectivityProvider instance; // Singleton pattern
//
//   /// Internal, private state of the provider.
//   bool _isConnected = false;
//
//   /// A way to share the state of the provider without allowing direct modifications.
//   bool get isConnected => _isConnected;
//
//   // actively listen for status updates
//   // https://pub.dev/packages/internet_connection_checker/example#:~:text=//%20actively%20listen%20for%20status%20updates
//   // Using alternative package due to a lack of support for web: https://github.com/RounakTadvi/internet_connection_checker/issues/15#issuecomment-1225363963
//   late StreamSubscription<InternetConnectionStatus> listener;
//
//   void setAndNotifyIfUpdated(bool isConnected) {
//     if (_isConnected != isConnected) {
//       Debug.logUpdate("Connexion state has been updated. Notifying listeners.");
//       _isConnected = isConnected;
//       notifyListeners(); // This call tells the widgets that are listening to this model to rebuild.
//     } else {
//       // Debug.logDev("No update of the connexion state.");
//     }
//   }
//
// // FROM EXAMPLE: https://docs.flutter.dev/development/data-and-backend/state-mgmt/simple#changenotifier
// //
// // /// The current total price of all items (assuming all items cost $42).
// // int get totalPrice => _items.length * 42;
// //
// // /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
// // /// cart from the outside.
// // void add(Item item) {
// //   _items.add(item);
// //   // This call tells the widgets that are listening to this model to rebuild.
// //   notifyListeners();
// // }
// //
// // /// Removes all items from the cart.
// // void removeAll() {
// //   _items.clear();
// //   // This call tells the widgets that are listening to this model to rebuild.
// //   notifyListeners();
// // }
// }
