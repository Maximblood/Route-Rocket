import 'package:flutter/cupertino.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthorized = false;

  bool get isAuthorized => _isAuthorized;

  void setAuthorized(bool value) {
    _isAuthorized = value;
    notifyListeners();
  }
}