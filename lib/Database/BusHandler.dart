
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
  Future<int> updateBus(int busId, int seats) async {
    return await db.update(
      tableName,
      {columnCountPlaces: seats},
      where: '$columnBusID = ?',
      whereArgs: [busId],
    );
  }
  Future<List<Bus>> getAllBuses() async{
    List<Map<String, dynamic>> maps = await db.query(tableName);
    List<Bus> buses = [];
    for(var map in maps){
      buses.add(Bus.fromMap(map));
    }
    return buses;
  }

  Future<int> getBusId(String number) async{
    List<Map<String, Object?>> result = await db.query(tableName,
        columns: [columnBusID],
        where: '$columnBusNumber = ?',
        whereArgs: [number]);

    if (result.isNotEmpty) {
      return result.first[columnBusID] as int;
    } else {
      return 0;
    }
  }

  Future<int> getBusCount(int BusId) async {
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(TRIP.TRIPID) FROM $tableName inner join TRIP ON  TRIP.BUSID = BUS.BUSID WHERE TRIP.BUSID = ?',
      [BusId],
    );
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }


  Future<int> getBusCountById(String number) async {
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(BUS.BUSID) FROM $tableName WHERE BUS.$columnBusNumber = ?',
      [number],
    );
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }


  Future<List<Map<String, dynamic>>> getFreeBuses(String input, String departure_date, String destination_date, String departure_time, String destination_time) async{
    String sqlQuery = '''
    SELECT *
    FROM BUS
    WHERE BUSID NOT IN (
    SELECT BUSID
    FROM TRIP
    WHERE (
        (DATETIME(departure_date) < DATETIME(?) AND DATETIME(DESTINATION_DATE) > DATETIME(?)) OR 
        (DATETIME(departure_date) < DATETIME(?) AND DATETIME(DESTINATION_DATE) >= DATETIME(?)) OR 
        (DATETIME(departure_date) >= DATETIME(?) AND DATETIME(DESTINATION_DATE) < DATETIME(?) AND time(destination_time) > ?) OR 
        (DATETIME(departure_date) > DATETIME(?) AND DATETIME(DESTINATION_DATE) <= DATETIME(?)) OR 
        (DATETIME(departure_date) < DATETIME(?) AND DATETIME(DESTINATION_DATE) > DATETIME(?) AND DATETIME(DESTINATION_DATE) <= DATETIME(?)) OR
        (DATETIME(departure_date) = DATETIME(?) AND DATETIME(DESTINATION_DATE) = DATETIME(?) AND time(DESTINATION_TIME) BETWEEN time(?) AND time(?)) OR 
        (DATETIME(departure_date) = DATETIME(?) AND DATETIME(DESTINATION_DATE) = DATETIME(?) AND time(departure_time) BETWEEN time(?) AND time(?)) OR
        (DATETIME(?) = DATETIME(?) AND DATETIME(departure_date) = DATETIME(?) AND DATETIME(DESTINATION_DATE) = DATETIME(?) AND time(departure_time) < time(?) AND time(DESTINATION_TIME) >= time(?)) OR
        (DATETIME(?) = DATETIME(?) AND DATETIME(departure_date) = DATETIME(?) AND DATETIME(DESTINATION_DATE) = DATETIME(?) AND time(departure_time) >= time(?) AND time(DESTINATION_TIME) <= time(?)) OR
        (DATETIME(?) = DATETIME(?) AND DATETIME(departure_date) = DATETIME(?) AND DATETIME(DESTINATION_DATE) = DATETIME(?) AND time(?) >= time(departure_time) AND time(?) <= time(DESTINATION_TIME))
      )
    ) AND (BUS.BUSBRAND LIKE ? OR BUS.BUSNUMBER LIKE ?)
    ''';

    String searchTerm = '%$input%';

    List<Map<String, dynamic>> result = await db.rawQuery(sqlQuery, [
      departure_date, departure_date,
      departure_date, destination_date,
      departure_date, destination_date, departure_time,
      departure_date, destination_date,
      departure_date, departure_date, destination_date,
      departure_date, departure_date, departure_time, destination_time,
      departure_date, destination_date, departure_time, destination_time,
      departure_date, destination_date, departure_date, destination_date, departure_time, departure_time,
      departure_date, destination_date, departure_date, destination_date, departure_time, destination_time,
      departure_date, destination_date, departure_date, destination_date, departure_time, departure_time,
      searchTerm, searchTerm
    ]);

    return result;
  }




  Future<List<Map<String, dynamic>>> getFreeBusesUpdate(String input, String departure_date, String destination_date, String departure_time, String destination_time) async{
    String sqlQuery = '''
    SELECT *
    FROM BUS
    WHERE BUSID NOT IN (
    SELECT BUSID
    FROM TRIP
    WHERE (
        (DATETIME(departure_date) < DATETIME(?) AND DATETIME(DESTINATION_DATE) > DATETIME(?)) OR 
        (DATETIME(departure_date) < DATETIME(?) AND DATETIME(DESTINATION_DATE) >= DATETIME(?)) OR 
        (DATETIME(departure_date) >= DATETIME(?) AND DATETIME(DESTINATION_DATE) < DATETIME(?) AND time(destination_time) > ?) OR 
        (DATETIME(departure_date) > DATETIME(?) AND DATETIME(DESTINATION_DATE) <= DATETIME(?)) OR 
        (DATETIME(departure_date) < DATETIME(?) AND DATETIME(DESTINATION_DATE) > DATETIME(?) AND DATETIME(DESTINATION_DATE) <= DATETIME(?)) OR
        (DATETIME(departure_date) = DATETIME(?) AND DATETIME(DESTINATION_DATE) = DATETIME(?) AND time(DESTINATION_TIME) BETWEEN time(?) AND time(?)) OR 
        (DATETIME(departure_date) = DATETIME(?) AND DATETIME(DESTINATION_DATE) = DATETIME(?) AND time(departure_time) BETWEEN time(?) AND time(?)) OR
        (DATETIME(?) = DATETIME(?) AND DATETIME(departure_date) = DATETIME(?) AND DATETIME(DESTINATION_DATE) = DATETIME(?) AND time(departure_time) < time(?) AND time(DESTINATION_TIME) >= time(?)) OR
        (DATETIME(?) = DATETIME(?) AND DATETIME(departure_date) = DATETIME(?) AND DATETIME(DESTINATION_DATE) = DATETIME(?) AND time(departure_time) >= time(?) AND time(DESTINATION_TIME) <= time(?)) OR
        (DATETIME(?) = DATETIME(?) AND DATETIME(departure_date) = DATETIME(?) AND DATETIME(DESTINATION_DATE) = DATETIME(?) AND time(?) >= time(departure_time) AND time(?) <= time(DESTINATION_TIME))
      )
    ) AND (BUS.BUSBRAND LIKE ? OR BUS.BUSNUMBER LIKE ?)
    ''';

    String searchTerm = '%$input%';

    List<Map<String, dynamic>> result = await db.rawQuery(sqlQuery, [
      departure_date, departure_date,
      departure_date, destination_date,
      departure_date, destination_date, departure_time,
      departure_date, destination_date,
      departure_date, departure_date, destination_date,
      departure_date, departure_date, departure_time, destination_time,
      departure_date, destination_date, departure_time, destination_time,
      departure_date, destination_date, departure_date, destination_date, departure_time, departure_time,
      departure_date, destination_date, departure_date, destination_date, departure_time, destination_time,
      departure_date, destination_date, departure_date, destination_date, departure_time, departure_time,
      searchTerm, searchTerm
    ]);

    return result;
  }






  Future close() async => db.close();
}