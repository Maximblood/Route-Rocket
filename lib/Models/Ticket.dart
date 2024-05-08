import 'dart:math';

class Ticket{

  final String columnTicketId = 'TICKETID';
  final String columnTripId = 'TRIPID';
  final String columnUserId = 'USERID';
  final String columnLandingFromId  = 'LANDING_FROM_ID';
  final String columnLandingToId = 'LANDING_TO_ID';
  final String columnCountPlaces = 'COUNT_PLACES';
  final String columnCost = 'COST';



  int id = 0;
  late int tripId;
  late int userId;
  late int landingFromId;
  late int landingToId;
  late int countPlaces;
  late double cost;


  Ticket(
      this.tripId,
      this.userId,
      this.landingFromId,
      this.landingToId,
      this.countPlaces,
      this.cost
      );

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnTripId: tripId,
      columnUserId: userId,
      columnLandingFromId: landingFromId,
      columnLandingToId: landingToId,
      columnCountPlaces: countPlaces,
      columnCost: cost,
    };
    return map;
  }

  Ticket.fromMap(Map<dynamic, dynamic> map){
    id = map[columnTicketId] ?? 0;
    tripId = map[columnTripId] ?? 0;
    userId = map[columnUserId] ?? 0;
    landingFromId = map[columnLandingFromId] ?? 0;
    landingToId = map[columnLandingToId] ?? 0;
    countPlaces = map[columnCountPlaces] ?? 0;
    cost = map[columnCost] ?? 0.0;
  }

}