
import 'package:kursovoy/Models/Route.dart';
import 'package:kursovoy/Models/Trip.dart';
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


  Future<List<Map<String, dynamic>>> getRouteWithFilter(String input) async{
    String sqlQuery = '''
    SELECT 
    ROUTEID,
    CITY_DEPARTURE.CITYNAME as POINTOFDEPARTURE,
    CITY_DESTINATION.CITYNAME as POINTOFDESTINATION,
    ROUTE_TIME
    FROM ROUTE
    INNER JOIN CITY as CITY_DEPARTURE ON ROUTE.POINT_OF_DEPARTUREID = CITY_DEPARTURE.CITYNAMEID
    INNER JOIN CITY as CITY_DESTINATION ON ROUTE.POINT_OF_DESTINATIONID = CITY_DESTINATION.CITYNAMEID
    WHERE $tableName.$columnRouteId LIKE ? OR CITY_DEPARTURE.CITYNAME LIKE ? OR CITY_DESTINATION.CITYNAME LIKE ?
    ''';
    String searchTerm = '%$input%';
    List<Map<String, dynamic>> results = await db.rawQuery(sqlQuery, [searchTerm, searchTerm, searchTerm]);
    return results;
  }


  Future<int> getRouteId(Route route) async {
    List<Map> maps = await db.query(tableName,
        columns: [columnRouteId],
        where: '$columnPointOfDepartureID = ? and $columnPointOfDestinationID = ? and $columnRouteTime = ?',
        whereArgs: [route.pointOfDepartureID, route.pointOfDestinationID, route.routeTime]);

    if (maps.isNotEmpty) {
      return maps.first[columnRouteId] as int;
    }
    return 0;
  }

  Future<int> getRouteCount(Route route) async {
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT($tableName.$columnRouteId) FROM $tableName WHERE $tableName.$columnPointOfDepartureID = ? and $tableName.$columnPointOfDestinationID = ? and $tableName.$columnRouteTime = ?',
      [route.pointOfDepartureID, route.pointOfDestinationID, route.routeTime],
    );
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }


  Future<int> getRouteCountTrips(int routeId) async {
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(TRIP.TRIPID) FROM $tableName INNER JOIN TRIP ON ROUTE.ROUTEID = TRIP.ROUTEID WHERE $tableName.$columnRouteId = ?',
      [routeId],
    );
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }



  Future<int> delete(int id) async{
    return await db.delete(tableName, where: '$columnRouteId = ?', whereArgs: [id]);
  }
  Future<int> update(Route route, int routeId) async{
    return await db.update(tableName, route.toMap(), where: '$columnRouteId = ?', whereArgs: [routeId]);
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