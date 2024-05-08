import 'package:flutter/cupertino.dart';
import 'package:kursovoy/Database/DatabaseHelper.dart';

class DatabaseNotifier extends ChangeNotifier {
  late DatabaseHelper _databaseHelper;

  DatabaseNotifier() {
    _databaseHelper = DatabaseHelper();
  }

  Future<void> initializeDatabase() async {
    await _databaseHelper.init("database.db");
    notifyListeners();
  }

  DatabaseHelper get databaseHelper => _databaseHelper;

}