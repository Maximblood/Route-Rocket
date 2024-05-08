class City{

  final String columnCityId = 'CITYNAMEID';
  final String columnCityName = 'CITYNAME';
  final String columnLocation = 'LOCATION';

  int id = 0;
  late String cityName;
  late String location;

  City(
      this.cityName,
      this.location
      );

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnCityName: cityName,
      columnLocation: location
    };
    return map;
  }

  City.fromMap(Map<dynamic, dynamic> map){
    id = map[columnCityId];
    cityName = map[columnCityName];
    location = map[columnLocation];
  }
}