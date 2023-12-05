import 'package:flutter/material.dart';
import 'package:menu_management/menu.dart';

class MenuProvider extends ChangeNotifier {

  Menu? _menu;
  Menu? get menu => _menu;

}