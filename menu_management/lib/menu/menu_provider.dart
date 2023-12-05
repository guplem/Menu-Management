import 'package:flutter/cupertino.dart';
import 'package:menu_management/menu.dart';

class MenuProvider extends ChangeNotifier {

  Menu? _menu;
  Menu? get menu => _menu;

}