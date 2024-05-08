import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kursovoy/Database/DatabaseNotifier.dart';
import 'package:kursovoy/Database/TicketHandler.dart';
import 'package:provider/provider.dart';

class TicketInfoPage extends StatefulWidget {
  final DatabaseNotifier databaseNotifier;
  int selectedTicketId;

  TicketInfoPage({required this.selectedTicketId, required this.databaseNotifier});

  @override
  _TicketInfoPageState createState() => _TicketInfoPageState();
}

class _TicketInfoPageState extends State<TicketInfoPage> {
  late int selectedTicketId;
  late Future<List<Map<String, dynamic>>> _ticketFuture;

  @override
  void initState() {
    super.initState();
    selectedTicketId = widget.selectedTicketId;
    _searchTicketInfo();
  }

  Future  _searchTicketInfo() async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    print(selectedTicketId);
    _ticketFuture = TicketHandler(dbHelper.db).getInfoAboutTicket(selectedTicketId);
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 58;
    return Scaffold(
        appBar: AppBar(
          title: Text("Данные заказа"),
        ),
        body:_buildTicketPage()
    );
  }



  Widget _buildTicketPage() {
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _ticketFuture,
              builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Stack(
                        children: [
                          Center(
                              child: CircularProgressIndicator(),
                          ),
                        ],
                      );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<Map<String, dynamic>> tickets = snapshot.data ?? [];
                    if (tickets.isEmpty) {
                      return Center(
                        child: Text('Нет доступных рейсов', style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.2,),),
                      );

                    }
                    else{
                      return Container(
                        child:
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID билета: ${tickets[0]['TICKETID'].toString()}', style: TextStyle(fontSize: 20),),
                                SizedBox(height: 3,),
                                Text('Рейс: ', style: TextStyle(fontSize: 20)),
                                Text('${tickets[0]['DepartureCityName']} - ${tickets[0]['DestinationCityName']}', style: TextStyle(fontSize: 20)),
                                SizedBox(height: 10,),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text('${tickets[0]['DEPARTURE_DATE']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                              Text('${tickets[0]['DEPARTURE_TIME']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                              SizedBox(height: 20,),
                                              Text('${tickets[0]['DESTINATION_DATE']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                              Text('${tickets[0]['DESTINATION_TIME']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          SizedBox(width: 40,),
                                          Column(
                                            children: [
                                              Text('${tickets[0]['DepartureCityName']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                              Text('${tickets[0]['LandingFromCityName']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                              SizedBox(height: 20,),
                                              Text('${tickets[0]['DestinationCityName']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                              Text('${tickets[0]['LandingToCityName']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Text('${tickets[0]['ROUTE_TIME']} в пути', style: TextStyle(fontSize: 20)),
                                SizedBox(height: 3,),
                                Text('Водитель: ${tickets[0]['DriverName']} ${tickets[0]['DriverLastName']}' , style: TextStyle(fontSize: 20)),
                                SizedBox(height: 3,),
                                Text('Бус: ${tickets[0]['BUSBRAND']} (${tickets[0]['BUSNUMBER']})' , style: TextStyle(fontSize: 20)),
                                SizedBox(height: 3,),
                                Text('Заказчик: ${tickets[0]['ClientName']} ${tickets[0]['ClientLastName']}' , style: TextStyle(fontSize: 20)),
                                SizedBox(height: 3,),
                                Text('Телефон заказчика: ${tickets[0]['ClientTelephone']}' , style: TextStyle(fontSize: 20)),
                                SizedBox(height: 3,),
                                Text('Количество заказанных мест: ${tickets[0]['COUNT_PLACES']}' , style: TextStyle(fontSize: 20)),
                                SizedBox(height: 3,),
                                Text('Стоимость проезда: ${tickets[0]['COST']} руб.' , style: TextStyle(fontSize: 20)),

                              ],
                            )
                      );
                    }
                }
              },
            ),
        )
    );
  }




}
