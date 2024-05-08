class BusStop{

  final String columnBusStopId = 'BUSSTOPID';
  final String columnBusStopName = 'BUSSTOPNAME';
  final String columnLocation = 'LOCATION';
  final String columnRouteId = 'ROUTEID';
  final String columnBusStopOrder = 'BUSSTOPORDER';


  int busStopId = 0;
  late String busStopName;
  late String location;
  late int routeId;
  late int busStopOrder;

  BusStop(
      this.busStopName,
      this.location,
      this.routeId,
      this.busStopOrder,
      );

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnBusStopName: busStopName,
      columnLocation: location,
      columnRouteId: routeId,
      columnBusStopOrder: busStopOrder,
    };
    return map;
  }

  BusStop.fromMap(Map<dynamic, dynamic> map){
    busStopId = map[columnBusStopId];
    busStopName = map[columnBusStopName];
    location = map[columnLocation];
    routeId = map[columnRouteId];
    busStopOrder = map[columnBusStopOrder];
  }
}