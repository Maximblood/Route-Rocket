import 'dart:convert';
import 'package:kursovoy/Models/Client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSharedHandler{
  final String _key;
  UserSharedHandler(this._key);


  Future<void> saveUser(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, id);
  }

  Future<int> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  Future<void> deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

}