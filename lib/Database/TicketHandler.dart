
import 'package:kursovoy/Models/Ticket.dart';
import 'package:sqflite/sqflite.dart';

const String tableName = 'TICKET';
const String columnTicketId = 'TICKETID';
const String columnTripId = 'TRIPID';
const String columnUserId = 'USERID';
const String columnLandingFromId = 'LANDING_FROM_ID';
const String columnLandingToId = 'LANDING_TO_ID';
const String columnCountPlaces = 'COUNT_PLACES';
const String columnCost = 'COST';



class TicketHandler{
  late Database db;
  TicketHandler(this.db);
  Future createTable() async{
    await db.execute('''
        create table IF NOT EXISTS $tableName ($columnTicketId INTEGER PRIMARY KEY autoincrement,
                                $columnTripId INTEGER not null,
                                $columnUserId INTEGER not null,
                                $columnLandingFromId INTEGER not null,
                                $columnLandingToId INTEGER not null,
                                $columnCountPlaces INTEGER not null,
                                $columnCost Real not null,
                                FOREIGN KEY ($columnUserId) REFERENCES CLIENT(USERID),
                                FOREIGN KEY ($columnTripId) REFERENCES TRIP(TRIPID),
                                FOREIGN KEY ($columnLandingFromId) REFERENCES BUSSTOP(BUS_STOP_ID),
                                FOREIGN KEY ($columnLandingToId) REFERENCES BUSSTOP(BUS_STOP_ID))
      ''');

  }

  Future createTriggers() async{
    await db.execute('''
        CREATE TRIGGER decrease_count_places_aft_del
        AFTER DELETE ON ticket
        FOR EACH ROW
        BEGIN
          UPDATE trip 
          SET count_free_places = count_free_places + OLD.count_places
          WHERE tripid = OLD.tripid;
        END;
    ''');

    await db.execute('''
        CREATE TRIGGER increase_count_places
        AFTER INSERT ON ticket
        FOR EACH ROW
        BEGIN
          UPDATE trip 
          SET count_free_places = count_free_places - NEW.count_places
          WHERE tripid = NEW.tripid;
        END;
    ''');

  }

  Future<int> insert(Ticket ticket) async{
    return await db.insert(tableName, ticket.toMap());
  }
  Future<Ticket?> getTicket(int id) async{
    List<Map> maps = await db.query(tableName,
        columns: [columnTicketId, columnTripId, columnUserId, columnLandingFromId,columnLandingToId,columnCountPlaces,columnCost],
        where: '$columnTicketId = ?',
        whereArgs: [id]);
    if(maps.isNotEmpty){
      return Ticket.fromMap(maps.first);
    }
    return null;
  }



  Future<List<Map<String, dynamic>>> getTicketsByIdAuthorized(int userId) async{
    String sqlQuery = '''
    SELECT  $tableName.$columnTicketId,TRIP.TRIPID, ROUTE.ROUTEID ,TRIP.DEPARTURE_DATE, TRIP.DESTINATION_DATE, TRIP.DEPARTURE_TIME, TRIP.DESTINATION_TIME, $tableName.$columnCost, $tableName.$columnCountPlaces, ROUTE_TIME, CITY_DEPARTURE.CITYNAME as DepartureCityName,
      CITY_DESTINATION.CITYNAME as DestinationCityName
    FROM CLIENT
    INNER JOIN $tableName ON CLIENT.$columnUserId = $tableName.$columnUserId
    INNER JOIN TRIP ON $tableName.$columnTripId = TRIP.TRIPID
    INNER JOIN ROUTE ON ROUTE.ROUTEID = TRIP.ROUTEID
    INNER JOIN CITY as CITY_DEPARTURE ON ROUTE.POINT_OF_DEPARTUREID = CITY_DEPARTURE.CITYNAMEID
    INNER JOIN CITY as CITY_DESTINATION ON ROUTE.POINT_OF_DESTINATIONID = CITY_DESTINATION.CITYNAMEID
    WHERE $tableName.$columnUserId = ? and CLIENT.USERSTATUS = ?
  ''';
    List<Map<String, dynamic>> results = await db.rawQuery(sqlQuery, [userId, 'REGISTERED']);
    return results;
  }

  Future<List<Map<String, dynamic>>> getTicketByIdUnauthorized(int ticketID) async{
    String sqlQuery = '''
    SELECT  $tableName.$columnTicketId,TRIP.TRIPID, ROUTE.ROUTEID ,TRIP.DEPARTURE_DATE, TRIP.DESTINATION_DATE, TRIP.DEPARTURE_TIME, TRIP.DESTINATION_TIME, $tableName.$columnCost, $tableName.$columnCountPlaces, ROUTE_TIME, CITY_DEPARTURE.CITYNAME as DepartureCityName,
      CITY_DESTINATION.CITYNAME as DestinationCityName
    FROM CLIENT
    INNER JOIN $tableName ON CLIENT.$columnUserId = $tableName.$columnUserId
    INNER JOIN TRIP ON $tableName.$columnTripId = TRIP.TRIPID
    INNER JOIN ROUTE ON ROUTE.ROUTEID = TRIP.ROUTEID
    INNER JOIN CITY as CITY_DEPARTURE ON ROUTE.POINT_OF_DEPARTUREID = CITY_DEPARTURE.CITYNAMEID
    INNER JOIN CITY as CITY_DESTINATION ON ROUTE.POINT_OF_DESTINATIONID = CITY_DESTINATION.CITYNAMEID
    WHERE $tableName.$columnTicketId = ? and CLIENT.USERSTATUS = ?
  ''';
    List<Map<String, dynamic>> results = await db.rawQuery(sqlQuery, [ticketID, 'UNREGISTERED']);
    return results;
  }



  Future<List<Map<String, dynamic>>> getInfoAboutTicket(int ticketId) async{
    String sqlQuery = '''
    SELECT 
      $tableName.$columnTicketId,
      $tableName.$columnCost,
      $tableName.$columnCountPlaces,
      ROUTE.ROUTEID,
      TRIP.TRIPID,
      TRIP.DEPARTURE_DATE,
      TRIP.DESTINATION_DATE,
      TRIP.DEPARTURE_TIME,
      TRIP.DESTINATION_TIME,
      CLIENT.USERNAME AS DriverName,
      CLIENT.USERLASTNAME AS DriverLastName,
      CLIENT_ORDER.USERNAME AS ClientName,
      CLIENT_ORDER.USERLASTNAME AS ClientLastName,
      CLIENT_ORDER.TELEPHONE AS ClientTelephone,
      BUS.BUSBRAND,
      BUS.BUSNUMBER,
      ROUTE_TIME,
      CITY_DEPARTURE.CITYNAME as DepartureCityName,
      CITY_DESTINATION.CITYNAME as DestinationCityName,
      LANDING_FROM_CITY.BUSSTOPNAME as LandingFromCityName,
      LANDING_TO_CITY.BUSSTOPNAME as LandingToCityName
    FROM TICKET
    INNER JOIN TRIP ON TICKET.TRIPID = TRIP.TRIPID
    INNER JOIN CLIENT AS CLIENT_ORDER ON TICKET.USERID = CLIENT_ORDER.USERID
    INNER JOIN CLIENT ON TRIP.DRIVERID = CLIENT.USERID
    INNER JOIN ROUTE ON TRIP.ROUTEID = ROUTE.ROUTEID
    INNER JOIN CITY as CITY_DEPARTURE ON ROUTE.POINT_OF_DEPARTUREID = CITY_DEPARTURE.CITYNAMEID
    INNER JOIN CITY as CITY_DESTINATION ON ROUTE.POINT_OF_DESTINATIONID = CITY_DESTINATION.CITYNAMEID
    INNER JOIN BUS ON TRIP.BUSID = BUS.BUSID
    INNER JOIN BUSSTOP as LANDING_FROM_CITY ON ROUTE.ROUTEID = LANDING_FROM_CITY.ROUTEID AND LANDING_FROM_CITY.BUSSTOPID = TICKET.LANDING_FROM_ID
    INNER JOIN BUSSTOP as LANDING_TO_CITY ON ROUTE.ROUTEID = LANDING_TO_CITY.ROUTEID AND LANDING_TO_CITY.BUSSTOPID = TICKET.LANDING_TO_ID 
    WHERE $tableName.$columnTicketId = ?
    ''';

    List<Map<String, dynamic>> results = await db.rawQuery(sqlQuery, [ticketId]);

    return results;
  }



  Future<int> delete(int id) async{
    return await db.delete(tableName, where: '$columnTicketId = ?', whereArgs: [id]);
  }
  Future<int> update(Ticket ticket) async{
    return await db.update(tableName, ticket.toMap(), where: '$columnTicketId = ?', whereArgs: [ticket.id]);
  }
  Future<List<Ticket>> getAllTickets() async{
    List<Map<String, dynamic>> maps = await db.query(tableName);
    List<Ticket> tickets = [];
    for(var map in maps){
      tickets.add(Ticket.fromMap(map));
    }
    return tickets;
  }

  Future close() async => db.close();
}