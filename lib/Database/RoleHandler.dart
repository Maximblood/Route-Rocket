
import 'package:kursovoy/Models/Role.dart';
import 'package:sqflite/sqflite.dart';

const String tableName = 'ROLE';
const String columnRoleID = 'ROLEID';
const String columnRoleName = 'ROLENAME';



class RoleHandler{
  late Database db;
  RoleHandler(this.db);
  Future createTable() async{
    await db.execute('''
        create table IF NOT EXISTS $tableName ($columnRoleID INTEGER PRIMARY KEY autoincrement,
                                $columnRoleName TEXT not null unique)
      ''');
  }
  Future<int> insert(Role role) async{
    return await db.insert(tableName, role.toMap());
  }
  Future<Role?> getRole(int id) async{
    List<Map> maps = await db.query(tableName,
        columns: [columnRoleID, columnRoleID],
        where: '$columnRoleID = ?',
        whereArgs: [id]);
    if(maps.isNotEmpty){
      return Role.fromMap(maps.first);
    }
    return null;
  }
  Future<int> delete(int id) async{
    return await db.delete(tableName, where: '$columnRoleID = ?', whereArgs: [id]);
  }
  Future<int> update(Role role) async{
    return await db.update(tableName, role.toMap(), where: '$columnRoleID = ?', whereArgs: [role.id]);
  }
  Future<List<Role>> getAllRoles() async{
    List<Map<String, dynamic>> maps = await db.query(tableName);
    List<Role> roles = [];
    for(var map in maps){
      roles.add(Role.fromMap(map));
    }
    return roles;
  }

  Future close() async => db.close();
}