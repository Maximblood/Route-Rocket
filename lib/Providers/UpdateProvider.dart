
import 'package:flutter/cupertino.dart';

class UpdateProvider extends ChangeNotifier {
  bool updateState = false;

  void updateBoolean(bool newValue) {
    updateState = newValue;
  }

}