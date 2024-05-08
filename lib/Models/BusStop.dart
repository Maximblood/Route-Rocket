class BusStop{

  final String columnBusStopId = 'BUSSTOPID';
  final String columnBusStopName = 'BUSSTOPNAME';
  final String columnRouteId = 'ROUTEID';
  final String columnBusStopOrder = 'BUSSTOPORDER';


  int busStopId = 0;
  late String busStopName;
  late int routeId;
  late int busStopOrder;

  BusStop(
      this.busStopName,
      this.routeId,
      this.busStopOrder,
      );

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnBusStopName: busStopName,
      columnRouteId: routeId,
      columnBusStopOrder: busStopOrder,
    };
    return map;
  }

  BusStop.fromMap(Map<dynamic, dynamic> map){
    busStopId = map[columnBusStopId];
    busStopName = map[columnBusStopName];
    routeId = map[columnRouteId];
    busStopOrder = map[columnBusStopOrder];
  }
}