class Route{

  final String columnRouteId = 'ROUTEID';
  final String columnPointOfDepartureID  = 'POINT_OF_DEPARTUREID';
  final String columnPointOfDestinationID = 'POINT_OF_DESTINATIONID';
  final String columnRouteTime = 'ROUTE_TIME';

  int id = 0;
  late int pointOfDepartureID;
  late int pointOfDestinationID;
  late String routeTime;

  Route(
      this.pointOfDepartureID,
      this.pointOfDestinationID,
      this.routeTime
      );

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnPointOfDepartureID: pointOfDepartureID,
      columnPointOfDestinationID: pointOfDestinationID,
      columnRouteTime: routeTime
    };
    return map;
  }

  Route.fromMap(Map<dynamic, dynamic> map){
    id = map[columnRouteId];
    pointOfDepartureID = map[columnPointOfDepartureID];
    pointOfDestinationID = map[columnPointOfDestinationID];
    routeTime = map[columnRouteTime];
  }
}