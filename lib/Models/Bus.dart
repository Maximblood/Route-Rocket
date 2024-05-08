class Bus{

  final String columnBusId = 'BUSID';
  final String columnBusBrand = 'BUSBRAND';
  final String columnBusNumber = 'BUSNUMBER ';
  final String columnCountPlaces = 'COUNT_PLACES';


  int id = 0;
  late String busBrand;
  late String busNumber;
  late int countPlace;

  Bus(
      this.busBrand,
      this.busNumber,
      this.countPlace,
      );

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnBusBrand: busBrand,
      columnBusNumber: busNumber,
      columnCountPlaces: countPlace,
    };
    return map;
  }

  Bus.fromMap(Map<dynamic, dynamic> map){
    id = map[columnBusId];
    busBrand = map[columnBusBrand];
    busNumber = map[columnBusNumber];
    countPlace = map[columnCountPlaces];
  }
}