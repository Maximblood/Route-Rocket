import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:kursovoy/Database/BusStopHandler.dart';
import 'package:kursovoy/Database/CityHandler.dart';
import 'package:kursovoy/Database/ClientHandler.dart';
import 'package:kursovoy/Database/DatabaseNotifier.dart';
import 'package:kursovoy/Database/RoleHandler.dart';
import 'package:kursovoy/Database/TicketHandler.dart';
import 'package:kursovoy/Models/City.dart';
import 'package:kursovoy/Models/Client.dart';
import 'package:kursovoy/Models/Role.dart';
import 'package:kursovoy/Pages/update_ticket_admin_page.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


class TicketAdminPage extends StatefulWidget {
  final DatabaseNotifier databaseNotifier;

  TicketAdminPage({required this.databaseNotifier});

  @override
  _TicketAdminPageState createState() => _TicketAdminPageState();
}

class _TicketAdminPageState extends State<TicketAdminPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _ticketsList = [];
  List<Map<String, dynamic>> _filteredTicketsList = [];
  bool isEditAndDelete = false;

  @override
  void initState() {
    super.initState();
    _getTickets();
  }

  Future<void> _getTickets() async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    String searchQuery = _searchController.text.trim();
    List<Map<String, dynamic>> result = await TicketHandler(dbHelper.db).getTicketsWithFilter(searchQuery);
    setState(() {
      _ticketsList = result;
      if(result.length > 50){
        _filteredTicketsList = result.sublist(0, 50);
      }
      else{
        _filteredTicketsList = result;
      }
    });
    print('Tickets updated.');

  }




  Future<void> _deleteTicket(int id) async {
    final dbHelper =
        Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    TicketHandler(dbHelper.db).delete(id);
  }




  double? getDividerWidth(String result) {
    switch (result.length) {
      case 3:
        return 65;
      case 4:
        return 65;
      case 7:
        return 52;
      case 8:
        return 45;
      case 9:
        return 45;
      case 11:
        return 40;
      case 12:
        return 35;
      case 13:
        return 28;
      case 14:
        return 20;
      default:
        return 0;
    }
  }


  String _getDate(String date){
    String routeTime = '';
    bool daysAdded = false;
    bool hoursAdded = false;


    if(date[0] == '0' && date[1] != '0'){
      routeTime += '${date[1]} д';
      daysAdded = true;
    }
    else if((date[0] != '0' && date[1] != '0') || (date[0] != '0' && date[1] == '0')){
      routeTime += '${date[0]}${date[1]} д';
      daysAdded = true;
    }
    else{
      routeTime += '';
      daysAdded = false;
    }

    if(date[5] == '0' && date[6] != '0'){
      if(daysAdded){
        routeTime += " ";
      }
      routeTime += '${date[6]} ч';
      hoursAdded = true;
    }
    else if((date[5] != '0' && date[6] != '0') || (date[5] != '0' && date[6] == '0')){
      if(daysAdded){
        routeTime += " ";
      }
      routeTime += '${date[5]}${date[6]} ч';
      hoursAdded = true;
    }
    else{
      routeTime += '';
      hoursAdded = false;
    }


    if(date[10] == '0' && date[11] != '0'){
      if(hoursAdded){
        routeTime += " ";
      }
      routeTime += '${date[10]} м';
    }
    else if((date[10] != '0' && date[11] != '0') || (date[10] != '0' && date[11] == '0')){
      if(hoursAdded){
        routeTime += " ";
      }
      routeTime += '${date[10]}${date[11]} м';
    }
    else{
      routeTime += '';
    }

    return routeTime;
  }


  String getDate(String unformattedDate){
    DateTime date = DateTime.parse(unformattedDate);

    String formattedDate = DateFormat('dd MMMM', 'ru').format(date); // 'ru' указывает, что мы хотим использовать русский язык для месяца

    return formattedDate;
  }



  void _showDialog(String message, String result){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(result),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Понятно'),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 58;
    return Scaffold(
      appBar: AppBar(
        title: Text('Управление билетами'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () {
                    _showDialog('Вы можете добавить билет через гостя', 'Предупреждение');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Добавить',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            if(!isEditAndDelete)
              SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditAndDelete = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Изменение и удаление',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            if(isEditAndDelete)
              Column(
                children: [
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Введите текст для фильтрации',
                        ),
                        onChanged: (value) {
                          _getTickets();
                        },
                      ),
                    ),

                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredTicketsList.length,
                    itemBuilder: (context, index) {
                      double? dividerWith =
                      getDividerWidth(_getDate(_filteredTicketsList[index]['ROUTE_TIME']));
                      return GestureDetector(
                        onTap: () async{
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdateTicketAdminPage(
                                      selectedTripId: _filteredTicketsList[index]['TRIPID'],
                                      selectedTicketId: _filteredTicketsList[index]['TICKETID'],
                                      databaseNotifier: Provider.of<DatabaseNotifier>(context, listen: false)
                                  )
                              )
                          ).then((result) async{
                            if (result != null && result == true) {
                              WidgetsBinding.instance.addPostFrameCallback((_) async {
                                await _getTickets();
                              });
                            }
                          });



                          },
                        child: ListTile(
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                          title: Container(
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(226, 216, 246, 1.0),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Билет № ${_filteredTicketsList[index]["TICKETID"].toString()}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    Row(

                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: width*0.85,
                                          child: Text(
                                            "Заказчик: ${_filteredTicketsList[index]["USERNAME"]} ${_filteredTicketsList[index]["USERLASTNAME"]}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: width*0.85,
                                          child: Text(
                                            "Номер: ${_filteredTicketsList[index]["TELEPHONE"]}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          getDate(_filteredTicketsList[index]["DEPARTURE_DATE"]),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          getDate(_filteredTicketsList[index]
                                          ["DESTINATION_DATE"]),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(

                                          _filteredTicketsList[index]["DEPARTURE_TIME"],
                                          style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                              const EdgeInsets.fromLTRB(
                                                  10, 0, 10, 0),
                                              child: SizedBox(
                                                width: dividerWith,
                                                child: const Divider(
                                                  thickness: 1,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _getDate(_filteredTicketsList[index]
                                            ["ROUTE_TIME"])),
                                            Padding(
                                              padding:
                                              const EdgeInsets.fromLTRB(
                                                  10, 0, 10, 0),
                                              child: SizedBox(
                                                width: dividerWith,
                                                child: const Divider(
                                                  thickness: 1,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          _filteredTicketsList[index]
                                          ["DESTINATION_TIME"],
                                          style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _filteredTicketsList[index]["DepartureCityName"],
                                          style: const TextStyle(
                                              fontSize: 20),
                                        ),

                                        Text(
                                          _filteredTicketsList[index]
                                          ["DestinationCityName"],
                                          style: const TextStyle(
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _filteredTicketsList[index]["COST"]
                                                  .toString() +
                                                  " руб.",
                                              style: TextStyle(
                                                  fontSize: 28,
                                                  fontWeight:
                                                  FontWeight.w600),
                                            ),
                                            Text(
                                              'Количество мест: ${_filteredTicketsList[index]["COUNT_PLACES"].toString()}',
                                              style: TextStyle(),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          child: ElevatedButton(
                                              style:
                                              ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                shape:
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      5),
                                                ),
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext
                                                  context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          "Подтверждение"),
                                                      content: Text(
                                                          "Вы действительно хотите отказаться от брони?"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () async {
                                                            _deleteTicket(
                                                                _filteredTicketsList[index]
                                                          [
                                                          "TICKETID"]);
                                                      Navigator.of(
                                                          context)
                                                          .pop(true);
                                                      await _getTickets();
                                                          },
                                                          child: Text("Да"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                context)
                                                                .pop(false);
                                                          },
                                                          child:
                                                          Text("Нет"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Padding(
                                                padding:
                                                EdgeInsets.fromLTRB(
                                                    10, 10, 10, 10),
                                                child: Text(
                                                  'Отказаться',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17,
                                                      fontWeight:
                                                      FontWeight.w400),
                                                ),
                                              )),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      );
                    },
                  ),
                ],
              )

          ],
        ),
      ),
    );
  }
}
