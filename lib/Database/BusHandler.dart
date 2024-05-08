
import 'package:kursovoy/Models/Bus.dart';
import 'package:sqflite/sqflite.dart';

const String tableName = 'BUS';
const String columnBusID = 'BUSID';
const String columnBusBrand = 'BUSBRAND';
const String columnBusNumber = 'BUSNUMBER';
const String columnCountPlaces = 'COUNT_PLACES';



class BusHandler{
  late Database db;

  BusHandler(this.db);

  Future createTable() async{
    await db.execute('''
        create table IF NOT EXISTS $tableName ($columnBusID INTEGER PRIMARY KEY autoincrement,
                                $columnBusBrand TEXT not null,
                                $columnBusNumber TEXT not null unique,
                                $columnCountPlaces INTEGER not null
                                )
      ''');

  }
  Future<int> insert(Bus bus) async{
    return await db.insert(tableName, bus.toMap());
  }
  Future<Bus?> getBus(int id) async{
    List<Map> maps = await db.query(tableName,
        columns: [columnBusID, columnBusBrand, columnBusNumber, columnCountPlaces],
        where: '$columnBusID = ?',
        whereArgs: [id]);
    if(maps.isNotEmpty){
      return Bus.fromMap(maps.first);
    }
    return null;
  }
  Future<int> delete(int id) async{
    return await db.delete(tableName, where: '$columnBusID = ?', whereArgs: [id]);
  }
  Future<int> update(Bus bus) async{
    return await db.update(tableName, bus.toMap(), where: '$columnBusID = ?', whereArgs: [bus.id]);
  }
  Future<List<Bus>> getAllBuses() async{
    List<Map<String, dynamic>> maps = await db.query(tableName);
    List<Bus> buses = [];
    for(var map in maps){
      buses.add(Bus.fromMap(map));
    }
    return buses;
  }

  Future close() async => db.close();
}