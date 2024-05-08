
import 'package:kursovoy/Models/City.dart';
import 'package:sqflite/sqflite.dart';

const String tableName = 'CITY';
const String columnCityID = 'CITYNAMEID';
const String columnCityName = 'CITYNAME';
const String columnLocation = 'LOCATION';



class CityHandler{
  late Database db;

  CityHandler(this.db);

  Future createTable() async{
    await db.execute('''
        create table IF NOT EXISTS $tableName ($columnCityID INTEGER PRIMARY KEY autoincrement,
                                $columnCityName TEXT not null,
                                $columnLocation TEXT not null)
      ''');

  }
  Future<int> insert(City city) async{
    return await db.insert(tableName, city.toMap());
  }
  Future<City?> getCity(int id) async{
    List<Map> maps = await db.query(tableName,
        columns: [columnCityID, columnCityName, columnLocation],
        where: '$columnCityID = ?',
        whereArgs: [id]);
    if(maps.isNotEmpty){
      return City.fromMap(maps.first);
    }
    return null;
  }
  Future<int> delete(int id) async{
    return await db.delete(tableName, where: '$columnCityID = ?', whereArgs: [id]);
  }
  Future<int> update(City city) async{
    return await db.update(tableName, city.toMap(), where: '$columnCityID = ?', whereArgs: [city.id]);
  }
  Future<List<City>> getAllCities(String selectedCity, String searchText) async {
    List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'cityName LIKE ?',
        whereArgs: ['%$searchText%']
    );
    List<City> cities = [];
    for (var map in maps) {
      City city = City.fromMap(map);
      if (city.cityName != selectedCity) {
        cities.add(city);
      }
    }
    return cities;
  }

  Future close() async => db.close();
}