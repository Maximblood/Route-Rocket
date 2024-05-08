
import 'package:kursovoy/Models/Trip.dart';
import 'package:sqflite/sqflite.dart';

const String tableName = 'TRIP';
const String columnTripId = 'TRIPID';
const String columnDepartureDate = 'DEPARTURE_DATE';
const String columnDestinationDate = 'DESTINATION_DATE';
const String columnDepartureTime = 'DEPARTURE_TIME';
const String columnDestinationTime = 'DESTINATION_TIME';
const String columnCountFreePlaces = 'COUNT_FREE_PLACES';
const String columnCost = 'COST';
const String columnRouteId = 'ROUTEID';
const String columnBusId = 'BUSID';
const String columnDriverId = 'DRIVERID';
const String columnStatus = 'STATUS';



class TripHandler{
  late Database db;
  TripHandler(this.db);
  Future createTable() async{
    await db.execute('''
        create table IF NOT EXISTS $tableName ($columnTripId INTEGER PRIMARY KEY autoincrement,
                                $columnDepartureDate TEXT not null,
                                $columnDestinationDate TEXT not null,
                                $columnDepartureTime TEXT not null,
                                $columnDestinationTime TEXT NOT NULL,
                                $columnCountFreePlaces INTEGER NOT NULL,
                                $columnCost REAL NUT NULL,
                                $columnRouteId INTEGER NOT NULL,
                                $columnBusId INTEGER NOT NULL,
                                $columnDriverId INTEGER NOT NULL,
                                $columnStatus TEXT NOT NULL CHECK($columnStatus IN ('AVAILABLE', 'STARTED', 'ENDED')),
                                FOREIGN KEY ($columnBusId) REFERENCES BUS(BUSID),
                                FOREIGN KEY ($columnRouteId) REFERENCES ROUTE(ROUTEID),
                                FOREIGN KEY ($columnDriverId) REFERENCES CLIENT(USERID))
      ''');

  }
  Future<int> insert(Trip trip) async{
    return await db.insert(tableName, trip.toMap());
  }
  Future<Trip?> getTrip(int id) async{
    List<Map> maps = await db.query(tableName,
        columns: [columnTripId, columnDepartureDate, columnDestinationDate, columnDepartureTime, columnDestinationTime, columnCountFreePlaces,columnCost,columnRouteId,columnBusId,columnDriverId,columnStatus],
        where: '$columnTripId = ?',
        whereArgs: [id]);
    if(maps.isNotEmpty){
      return Trip.fromMap(maps.first);
    }
    return null;
  }
  Future<int> delete(int id) async{
    return await db.delete(tableName, where: '$columnTripId = ?', whereArgs: [id]);
  }
  Future<int> update(Trip trip) async{
    return await db.update(tableName, trip.toMap(), where: '$columnTripId = ?', whereArgs: [trip.id]);
  }

  Future<void> updateTripStatus(int tripId, String newStatus) async {
    try {
      await db.update(
        tableName,
        {columnStatus: newStatus},
        where: '$columnTripId = ?',
        whereArgs: [tripId],
      );
      print('Trip status updated successfully');
    } catch (e) {
      print('Error updating trip status: $e');
    }
  }



  Future<List<Map<String, dynamic>>> getAllTrips(int pointOfDeparture, int pointOfDestination, String routeTime) async{
    String sqlQuery = '''
    SELECT $tableName.$columnTripId, ROUTE.$columnRouteId ,$tableName.$columnDepartureDate, $tableName.$columnDestinationDate, $tableName.$columnDepartureTime, $tableName.$columnDestinationTime, $tableName.$columnCost, $tableName.$columnCountFreePlaces, ROUTE_TIME, CITY_DEPARTURE.CITYNAME as DepartureCityName,
      CITY_DESTINATION.CITYNAME as DestinationCityName
    FROM $tableName
    INNER JOIN ROUTE ON ROUTE.$columnRouteId = $tableName.$columnRouteId
    INNER JOIN CITY as CITY_DEPARTURE ON ROUTE.POINT_OF_DEPARTUREID = CITY_DEPARTURE.CITYNAMEID
    INNER JOIN CITY as CITY_DESTINATION ON ROUTE.POINT_OF_DESTINATIONID = CITY_DESTINATION.CITYNAMEID
    WHERE CITY_DEPARTURE.CITYNAMEID = ? and CITY_DESTINATION.CITYNAMEID = ? and $tableName.$columnDepartureDate = ? and $tableName.$columnStatus = ? 
  ''';

    List<Map<String, dynamic>> results = await db.rawQuery(sqlQuery, [pointOfDeparture, pointOfDestination, routeTime, 'AVAILABLE']);
    return results;
  }




  Future<List<Map<String, dynamic>>> getTripStops(int tripId) async{
    String sqlQuery = '''
    SELECT BUSSTOP.BUSSTOPNAME, BUSSTOP.BUSSTOPORDER
    FROM $tableName
    INNER JOIN ROUTE ON ROUTE.$columnRouteId = $tableName.$columnRouteId
    INNER JOIN BUSSTOP ON ROUTE.$columnRouteId = BUSSTOP.$columnRouteId
    WHERE $tableName.$columnTripId = ?
  ''';

    List<Map<String, dynamic>> results = await db.rawQuery(sqlQuery, [tripId]);
    return results;
  }

  Future<List<Map<String, dynamic>>> getInfoAboutTripForDriver(int driverId) async{
    String sqlQuery = '''
    SELECT 
      ROUTE.ROUTEID,
      TRIP.TRIPID,
      TRIP.DEPARTURE_DATE,
      TRIP.DESTINATION_DATE,
      TRIP.DEPARTURE_TIME,
      TRIP.DESTINATION_TIME,
      TRIP.COST,
      CLIENT.USERNAME AS DriverName,
      CLIENT.USERLASTNAME AS DriverLastName,
      ROUTE_TIME,
      CITY_DEPARTURE.CITYNAME as DepartureCityName,
      CITY_DESTINATION.CITYNAME as DestinationCityName,
      BUS.BUSBRAND,
      BUS.BUSNUMBER,
      COUNT(TICKET.TICKETID) AS TicketCount,
      SUM(TICKET.COST) AS TicketCost
    FROM TRIP 
    INNER JOIN CLIENT ON TRIP.DRIVERID = CLIENT.USERID
    INNER JOIN ROUTE ON TRIP.ROUTEID = ROUTE.ROUTEID
    INNER JOIN CITY as CITY_DEPARTURE ON ROUTE.POINT_OF_DEPARTUREID = CITY_DEPARTURE.CITYNAMEID
    INNER JOIN CITY as CITY_DESTINATION ON ROUTE.POINT_OF_DESTINATIONID = CITY_DESTINATION.CITYNAMEID
    INNER JOIN BUS ON TRIP.BUSID = BUS.BUSID
    INNER JOIN TICKET ON TRIP.TRIPID = TICKET.TRIPID 
    WHERE $tableName.$columnDriverId = ? and TRIP.STATUS = ?
    GROUP BY 
    ROUTE.ROUTEID,
    TRIP.TRIPID,
    TRIP.DEPARTURE_DATE,
    TRIP.DESTINATION_DATE,
    TRIP.DEPARTURE_TIME,
    TRIP.DESTINATION_TIME,
    CLIENT.USERNAME,
    CLIENT.USERLASTNAME,
    ROUTE_TIME,
    CITY_DEPARTURE.CITYNAME,
    CITY_DESTINATION.CITYNAME,
    BUS.BUSBRAND,
    BUS.BUSNUMBER
    ORDER BY TRIP.DEPARTURE_DATE, TRIP.DEPARTURE_TIME
    ''';

    List<Map<String, dynamic>> results = await db.rawQuery(sqlQuery, [driverId, 'AVAILABLE']);

    return results;
  }



  Future<List<Map<String, dynamic>>> getAllPassengersForDriver(int tripId) async{
    String sqlQuery = '''
    SELECT 
      CLIENT.USERNAME AS DriverName,
      CLIENT.USERLASTNAME AS DriverLastName,
      CLIENT_ORDER.USERNAME AS ClientName,
      CLIENT_ORDER.USERLASTNAME AS ClientLastName,
      CLIENT_ORDER.TELEPHONE AS ClientTelephone,
      TICKET.COUNT_PLACES,
      TICKET.COST,
      LANDING_FROM_CITY.BUSSTOPNAME as LandingFromCityName,
      LANDING_TO_CITY.BUSSTOPNAME as LandingToCityName,
      SUM(TICKET.COST) AS TicketCost
    FROM TRIP 
    INNER JOIN TICKET ON TRIP.TRIPID = TICKET.TRIPID 
    INNER JOIN CLIENT AS CLIENT_ORDER ON TICKET.USERID = CLIENT_ORDER.USERID
    INNER JOIN CLIENT ON TRIP.DRIVERID = CLIENT.USERID
    INNER JOIN ROUTE ON TRIP.ROUTEID = ROUTE.ROUTEID
    INNER JOIN BUSSTOP as LANDING_FROM_CITY ON ROUTE.ROUTEID = LANDING_FROM_CITY.ROUTEID AND LANDING_FROM_CITY.BUSSTOPID = TICKET.LANDING_FROM_ID
    INNER JOIN BUSSTOP as LANDING_TO_CITY ON ROUTE.ROUTEID = LANDING_TO_CITY.ROUTEID AND LANDING_TO_CITY.BUSSTOPID = TICKET.LANDING_TO_ID 
    INNER JOIN BUS ON TRIP.BUSID = BUS.BUSID
    WHERE $tableName.$columnTripId = ?
    GROUP BY 
    CLIENT_ORDER.USERNAME,
    CLIENT_ORDER.USERLASTNAME
    ORDER BY LANDING_FROM_CITY.BUSSTOPORDER
    ''';

    List<Map<String, dynamic>> results = await db.rawQuery(sqlQuery, [tripId]);

    return results;
  }


  Future<int?> getDriverIdByTripId(int tripId) async {
    try {
      List<Map<String, dynamic>> results = await db.query(tableName,
          columns: [columnDriverId],
          where: '$columnTripId = ?',
          whereArgs: [tripId]);
      if (results.isNotEmpty) {
        return results.first[columnDriverId] as int?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving DRIVERID by TRIPID: $e');
      return null;
    }
  }



  Future close() async => db.close();
}