
import 'package:sqflite/sqflite.dart';
import 'package:kursovoy/Models/Client.dart';

const String tableName = 'CLIENT';
const String columnUserId = 'USERID';
const String columnUserEmail = 'USEREMAIL';
const String columnUserPassword = 'USERPASSWORD';
const String columnUsername = 'USERNAME';
const String columnUserLastname = 'USERLASTNAME';
const String columnTelephone = 'TELEPHONE';
const String columnRoleId = 'USERROLEID';
const String columnStatus = 'USERSTATUS';



class ClientHandler{
  late Database db;

  ClientHandler(this.db);

  Future createTable() async{
      await db.execute('''
        create table IF NOT EXISTS $tableName ($columnUserId INTEGER PRIMARY KEY autoincrement,
                                $columnUserEmail TEXT not null,
                                $columnUserPassword TEXT NOT NULL,
                                $columnUsername TEXT,
                                $columnUserLastname TEXT,
                                $columnTelephone TEXT,
                                $columnRoleId INTEGER,
                                $columnStatus TEXT CHECK($columnStatus IN ('REGISTERED', 'UNREGISTERED')), 
                                FOREIGN KEY ($columnRoleId) REFERENCES ROLE(ROLEID))
      ''');

  }
  Future<int> insert(Client client) async{
    return await db.insert(tableName, client.toMap());
  }
  Future<Client?> getClient(int id) async{
    List<Map> maps = await db.query(tableName,
        columns: [columnUserId, columnUserEmail, columnUserPassword, columnUsername, columnUserLastname, columnTelephone, columnRoleId, columnStatus],
        where: '$columnUserId = ?',
        whereArgs: [id]);
    if(maps.isNotEmpty){
      return Client.fromMap(maps.first);
    }
    return null;
  }

  Future<Client?> getClientByPhone(String phoneNumber) async{
    List<Map> maps = await db.query(tableName,
        columns: [columnUserId, columnUserEmail, columnUserPassword, columnUsername, columnUserLastname, columnTelephone, columnRoleId, columnStatus],
        where: '$columnTelephone = ?',
        whereArgs: [phoneNumber]);
    if(maps.isNotEmpty){
      return Client.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getCountOrders(String telephone, int tripID) async{
    String sqlQuery = '''
    SELECT COUNT(TICKETID), TICKET.TICKETID
    FROM $tableName
    INNER JOIN TICKET ON $tableName.$columnUserId = TICKET.$columnUserId
    INNER JOIN TRIP ON TICKET.TRIPID = TRIP.TRIPID 
    WHERE $tableName.$columnTelephone = ? and TRIP.TRIPID = ?
    GROUP BY TICKET.TICKETID
  ''';

    List<Map<String, dynamic>> result = await db.rawQuery(sqlQuery, [telephone, tripID]);

    return result;
  }


  Future<List<Map<String, dynamic>>> getFreeDrivers(String input, String departure_date, String destination_date, String departure_time, String destination_time) async{
    String sqlQuery = '''
    SELECT *
    FROM CLIENT
    WHERE USERID NOT IN (
    SELECT DRIVERID
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
    ) AND (CLIENT.USERNAME LIKE ? OR CLIENT.USERLASTNAME LIKE ?) AND CLIENT.USERROLEID = ?
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
      searchTerm, searchTerm, 1
    ]);

    return result;
  }







  Future<String> getUserRole(int userId) async {
    var result = await db.rawQuery('''
      SELECT ROLE.ROLENAME
      FROM $tableName
      JOIN ROLE ON $tableName.$columnRoleId = ROLE.ROLEID
      WHERE $columnUserId = ?
    ''', [userId]);

    if (result.isNotEmpty) {
      return result.first['ROLENAME'] as String;
    } else {
      return "";
    }
  }

  Future<int> delete(int id) async{
    return await db.delete(tableName, where: '$columnUserId = ?', whereArgs: [id]);
  }
  Future<int> update(Client client, int id) async{
    return await db.update(tableName, client.toMap(), where: '$columnUserId = ?', whereArgs: [id]);
  }

  Future<void> updateRoleId(int userId, int newRoleId) async {
    await db.update(
      tableName,
      {columnRoleId: newRoleId},
      where: '$columnUserId = ?',
      whereArgs: [userId],
    );
  }


  Future<List<Client>> getAllClients() async{
    List<Map<String, dynamic>> maps = await db.query(tableName, where: 'USERSTATUS = ?', whereArgs: ['REGISTERED']);
    List<Client> clients = [];
    for(var map in maps){
      clients.add(Client.fromMap(map));
    }
    return clients;
  }


  Future<List<Client>> getAllClientsUnregistered() async{
    List<Map<String, dynamic>> maps = await db.query(tableName, where: 'USERSTATUS = ?', whereArgs: ['UNREGISTERED']);
    List<Client> clients = [];
    for(var map in maps){
      clients.add(Client.fromMap(map));
    }
    return clients;
  }

  Future<int> getDriverCountTrips(int driverID) async {
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(TRIP.TRIPID) FROM $tableName INNER JOIN TRIP ON CLIENT.USERID = TRIP.DRIVERID WHERE $tableName.$columnUserId = ?',
      [driverID],
    );
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }



  Future<List<Map<String, dynamic>>> getClientAdmin(String input) async{
    String sqlQuery = '''
    SELECT * FROM $tableName inner join ROLE ON $tableName.$columnRoleId = ROLE.ROLEID
    WHERE CLIENT.USERNAME LIKE ? OR CLIENT.USERLASTNAME LIKE ? OR CLIENT.TELEPHONE LIKE ?
  ''';
    String searchTerm = '%$input%';
    List<Map<String, dynamic>> result = await db.rawQuery(sqlQuery, [searchTerm, searchTerm, searchTerm]);
    return result;
  }


  Future close() async => db.close();
}