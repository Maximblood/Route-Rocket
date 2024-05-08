
class Trip{

  final String columnTripId = 'TRIPID';
  final String columnDepartureDate = 'DEPARTURE_DATE';
  final String columnDestinationDate = 'DESTINATION_DATE';
  final String columnDepartureTime  = 'DEPARTURE_TIME';
  final String columnDestinationTime = 'DESTINATION_TIME';
  final String columnCountFreePlaces = 'COUNT_FREE_PLACES';
  final String columnCost = 'COST';
  final String columnRouteId = 'ROUTEID';
  final String columnBusId = 'BUSID';
  final String columnDriverId = 'DRIVERID';
  final String columnStatus = 'STATUS';



  int id = 0;
  late String departureDate;
  late String destinationDate;
  late String departureTime;
  late String destinationTime;
  late int countFreePlaces;
  late double cost;
  late int routeId;
  late int busId;
  late int driverId;
  late String status;


  Trip(
      this.departureDate,
      this.destinationDate,
      this.departureTime,
      this.destinationTime,
      this.countFreePlaces,
      this.cost,
      this.routeId,
      this.busId,
      this.driverId,
      this.status
      );

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnDepartureDate: departureDate,
      columnDestinationDate: destinationDate,
      columnDepartureTime: departureTime,
      columnDestinationTime: destinationTime,
      columnCountFreePlaces: countFreePlaces,
      columnCost: cost,
      columnRouteId: routeId,
      columnBusId: busId,
      columnDriverId: driverId,
      columnStatus: status
    };
    return map;
  }

  Trip.fromMap(Map<dynamic, dynamic> map){
    id = map[columnTripId];
    departureDate = map[columnDepartureDate];
    destinationDate = map[columnDestinationDate];
    departureTime = map[columnDepartureTime];
    destinationTime = map[columnDestinationTime];
    countFreePlaces = map[columnCountFreePlaces];
    cost = map[columnCost];
    routeId = map[columnRouteId];
    busId = map[columnBusId];
    driverId = map[columnDriverId];
    status = map[columnStatus];
  }
}