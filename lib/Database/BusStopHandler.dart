
import 'package:kursovoy/Models/BusStop.dart';
import 'package:sqflite/sqflite.dart';

const String tableName = 'BUSSTOP';
const String columnBusStopId = 'BUSSTOPID';
const String columnBusStopName = 'BUSSTOPNAME';
const String columnLocation = 'LOCATION';
const String columnRouteId = 'ROUTEID';
const String columnBusStopOrder = 'BUSSTOPORDER';



class BusStopHandler{
  late Database db;

  BusStopHandler(this.db);
  Future createTable() async{

    await db.execute('''
        create table IF NOT EXISTS $tableName ($columnBusStopId INTEGER PRIMARY KEY autoincrement,
                                $columnBusStopName TEXT not null,
                                $columnLocation TEXT not null,
                                $columnRouteId INTEGER not null,
                                $columnBusStopOrder INTEGER not null,
                                FOREIGN KEY ($columnRouteId) REFERENCES ROUTE(ROUTEID)) 
      ''');

  }
  Future<int> insert(BusStop busStop) async{
    return await db.insert(tableName, busStop.toMap());
  }
  Future<int> getBusStopId(String name, int routeId) async{
    List<Map> maps = await db.query(tableName,
        columns: [columnBusStopId, columnBusStopName, columnLocation, columnRouteId, columnBusStopOrder],
        where: '$columnBusStopName = ? AND $columnRouteId = ?',
        whereArgs: [name, routeId]);
    if(maps.isNotEmpty){
      return maps.first[columnBusStopId] as int;
    }
    else{
      return 0;
    }
  }
  Future<int> delete(int id) async{
    return await db.delete(tableName, where: '$columnBusStopId = ?', whereArgs: [id]);
  }
  Future<int> update(BusStop busStop) async{
    return await db.update(tableName, busStop.toMap(), where: '$columnBusStopId = ?', whereArgs: [busStop.busStopId]);
  }
  Future<List<BusStop>> getAllBusStops() async{
    List<Map<String, dynamic>> maps = await db.query(tableName);
    List<BusStop> busStops = [];
    for(var map in maps){
      busStops.add(BusStop.fromMap(map));
    }
    return busStops;
  }

  Future close() async => db.close();
}