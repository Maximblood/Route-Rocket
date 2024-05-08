import 'package:kursovoy/Database/BusStopHandler.dart';
import 'package:kursovoy/Database/CityHandler.dart';
import 'package:kursovoy/Database/ClientHandler.dart';
import 'package:kursovoy/Database/RoleHandler.dart';
import 'package:kursovoy/Database/BusHandler.dart';
import 'package:kursovoy/Database/RouteHandler.dart';
import 'package:kursovoy/Database/TicketHandler.dart';
import 'package:kursovoy/Database/TripHandler.dart';

import 'package:sqflite/sqflite.dart';


class DatabaseHelper{
  late Database db;
  Future init(String path) async{
    db = await openDatabase(path, version: 1,
        onCreate: (db, version) async{
          await CityHandler(db).createTable();
          await RoleHandler(db).createTable();
          await ClientHandler(db).createTable();
          await BusHandler(db).createTable();
          await RouteHandler(db).createTable();
          await BusStopHandler(db).createTable();
          await TripHandler(db).createTable();
          await TicketHandler(db).createTable();
          await TicketHandler(db).createTriggers();
    });
  }


  Future close() async => db.close();
}