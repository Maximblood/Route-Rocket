
import 'package:kursovoy/Models/Route.dart';
import 'package:sqflite/sqflite.dart';

const String tableName = 'ROUTE';
const String columnRouteId = 'ROUTEID';
const String columnPointOfDepartureID = 'POINT_OF_DEPARTUREID';
const String columnPointOfDestinationID = 'POINT_OF_DESTINATIONID';
const String columnRouteTime = 'ROUTE_TIME';



class RouteHandler{
  late Database db;
  RouteHandler(this.db);
  Future createTable() async{
    await db.execute('''
        create table IF NOT EXISTS $tableName ($columnRouteId INTEGER PRIMARY KEY autoincrement,
                                $columnPointOfDepartureID INTEGER not null,
                                $columnPointOfDestinationID INTEGER not null,
                                $columnRouteTime TEXT not null,
                                FOREIGN KEY ($columnPointOfDepartureID) REFERENCES CITY(CITYNAMEID),
                                FOREIGN KEY ($columnPointOfDestinationID) REFERENCES CITY(CITYNAMEID))
      ''');

  }
  Future<int> insert(Route route) async{
    return await db.insert(tableName, route.toMap());
  }
  Future<Route?> getRoute(int id) async{
    List<Map> maps = await db.query(tableName,
        columns: [columnRouteId, columnPointOfDepartureID, columnPointOfDestinationID, columnRouteTime],
        where: '$columnRouteId = ?',
        whereArgs: [id]);
    if(maps.isNotEmpty){
      return Route.fromMap(maps.first);
    }
    return null;
  }
  Future<int> delete(int id) async{
    return await db.delete(tableName, where: '$columnRouteId = ?', whereArgs: [id]);
  }
  Future<int> update(Route route) async{
    return await db.update(tableName, route.toMap(), where: '$columnRouteId = ?', whereArgs: [route.id]);
  }
  Future<List<Route>> getAllRoutes() async{
    List<Map<String, dynamic>> maps = await db.query(tableName);
    List<Route> routes = [];
    for(var map in maps){
      routes.add(Route.fromMap(map));
    }
    return routes;
  }

  Future close() async => db.close();
}