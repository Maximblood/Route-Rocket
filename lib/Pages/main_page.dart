import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kursovoy/Database/BusHandler.dart';
import 'package:kursovoy/Database/BusStopHandler.dart';
import 'package:kursovoy/Database/CityHandler.dart';
import 'package:kursovoy/Database/ClientHandler.dart';
import 'package:kursovoy/Database/DatabaseNotifier.dart';
import 'package:kursovoy/Database/RoleHandler.dart';
import 'package:kursovoy/Database/RouteHandler.dart';
import 'package:kursovoy/Database/TicketHandler.dart';
import 'package:kursovoy/Database/TripHandler.dart';
import 'package:kursovoy/Models/Bus.dart';
import 'package:kursovoy/Models/BusStop.dart';
import 'package:kursovoy/Models/City.dart';
import 'package:kursovoy/Models/Client.dart';
import 'package:kursovoy/Models/Role.dart';
import 'package:kursovoy/Models/Route.dart'  as Rroute;
import 'package:kursovoy/Models/Ticket.dart';
import 'package:kursovoy/Models/Trip.dart';
import 'package:kursovoy/Pages/booking_a_ticket_page.dart';
import 'package:kursovoy/Pages/city_search_page.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  final DatabaseNotifier databaseNotifier;

  MainPage({required this.databaseNotifier});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late DatabaseNotifier _databaseNotifier;
  late Future<List<Map<String, dynamic>>> _tripFuture;
  String firstText = 'Откуда';
  String secondText = 'Куда';
  int firstTextId = 0;
  int secondTextId = 0;
  String _textFromField1 = '';
  String _textFromField2 = '';
  int _textFromFieldID1 = 0;
  int _textFromFieldID2 = 0;
  Future<void> _initFuture = initializeDateFormatting('ru_RU', null);
  String formattedDate = DateFormat('dd MMMM yyyy (EEEE)', 'ru_RU').format(
      DateTime.now());
  bool _showResult = false;
  DateTime pickedValue = DateTime.now();
  void swapText() {
    setState(() {
      _textFromField1 = firstText;
      _textFromField2 = secondText;
      firstText = _textFromField2;
      secondText = _textFromField1;
      _textFromFieldID1 = firstTextId;
      _textFromFieldID2 = secondTextId;
      firstTextId = _textFromFieldID2;
      secondTextId = _textFromFieldID1;
      if((firstText != 'Откуда' && firstText != 'Куда') && (secondText != 'Куда' && secondText != 'Откуда')){
        _tripFuture = _searchTrips();
      }
    });

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

  @override
  void initState() {
    super.initState();
    _initFuture = initializeDateFormatting('ru_RU', null);
    _databaseNotifier = widget.databaseNotifier;
  }
  Future<List<Map<String, dynamic>>> _searchTrips() async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    await Future.delayed(const Duration(seconds: 1));
    if((firstText != 'Откуда' && firstText != 'Куда') && (secondText != 'Куда' && secondText != 'Откуда')){
      setState(() {
        _showResult = true;
      });
      return await TripHandler(dbHelper.db).getAllTrips(firstTextId, secondTextId, DateFormat('yyyy-MM-dd').format(pickedValue));
    }
    else{
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Ошибка'),
            content: Text("Проверьте правильность выбранных параметров"),
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
      return [];
    }
  }
  Future<void> _selectDate(BuildContext context) async {
    await _initFuture;
    final DateTime initialDate = DateFormat('dd MMMM yyyy (EEEE)', 'ru_RU')
        .parse(formattedDate);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDate: DateTime(DateTime.now().year, 12, 31),
      locale: Locale('ru', 'RU'),
    );

    if (picked != null) {
      setState(() {
        pickedValue = picked;
        formattedDate =
            DateFormat('dd MMMM yyyy (EEEE)', 'ru_RU').format(picked);
      });
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


  Future<void> _openCitySearchPage(String selectedCity) async {
    bool resultBack = false;
    if (selectedCity == 'first') {
      String selectedCity = '';
      int id = 0;

      dynamic result = await Navigator.push(context, MaterialPageRoute(
          builder: (context) => CitySearchPage(selectedCity: secondText)));
      if (result != null) {
        resultBack = result['result'];
        if(resultBack == true){
          selectedCity = result['cityName'];
          id = result['id'];
        }
      }
      if (resultBack == true) {
        setState(() {
          firstText = selectedCity;
          firstTextId = id;
        });

        String selectedCity2 = '';
        int id2 = 0;
        dynamic result2 = await Navigator.push(context, MaterialPageRoute(
            builder: (context) => CitySearchPage(selectedCity: firstText)));
        if (result2 != null) {
          selectedCity2 = result2['cityName'];
          id2 = result2['id'];
        }
        if (selectedCity2 != null) {
          setState(() {
            secondText = selectedCity2;
            secondTextId = id2;
          });
        }
      }
    }
    else if (selectedCity == 'second') {
      String selectedCity2 = '';
      int id2 = 0;
      dynamic result2 = await Navigator.push(context, MaterialPageRoute(
          builder: (context) => CitySearchPage(selectedCity: firstText)));
      if (result2 != null) {
        selectedCity2 = result2['cityName'];
        id2 = result2['id'];
      }
      if (selectedCity2 != null) {
        setState(() {
          secondText = selectedCity2;
          secondTextId = id2;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbHelper = _databaseNotifier.databaseHelper;
    double height = MediaQuery
        .of(context)
        .size
        .height - 58;
    double width = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _showResult
              ? _buildResultPage(height, width)
              : _buildSearchPage(height, width),
        ),
      ),
    );
  }

  Widget _buildSearchPage(double height, double width) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/doroga.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Stack(
            children: [
              SizedBox(
                height: height * 0.34,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 35),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                          const Divider(
                            indent: 15,
                            endIndent: 15,
                            color: Colors.grey,
                            height: 0.05,
                          ),
                          padding: const EdgeInsets.all(5),
                          shrinkWrap: true,
                          itemCount: 3,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 3) {
                              return const Divider(color: Colors.grey,
                                height: 0.05,);
                            }
                            if (index < 2) {
                              return Row(
                                children: [
                                  Expanded(child: ListTile(
                                    title: Text(index == 0 ? firstText : index == 1
                                        ? secondText
                                        : formattedDate),
                                    onTap: () {
                                      if (index == 0) {
                                        _openCitySearchPage('first');
                                      } else if (index == 1) {
                                        _openCitySearchPage('second');
                                      } else {
                                        _selectDate(context);
                                      }
                                    },
                                  )),
                                ],
                              );
                            }
                            else {
                              return ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(formattedDate),
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  if (index == 2) {
                                    _selectDate(context);
                                  }
                                },
                              );
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.orange),
                              minimumSize: MaterialStateProperty.all(
                                  Size(width, 50)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  )
                              )
                          ),
                          onPressed: () async{
                            setState(() {
                              _tripFuture = _searchTrips();
                            });
                          },
                          child: const Text('Найти билет',
                            style: TextStyle(color: Colors.white, fontSize: 18),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 35,
                right: 20,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                  ),
                  child: IconButton(
                    onPressed: () {
                      swapText();
                    },
                    icon: const Icon(Icons.swap_vert_outlined),
                    iconSize: 30,
                    color: Colors.white,
                    splashRadius: 25,
                  ),
                )
              ),
            ],
          )

        ],
      ),
    );
  }

  Widget _buildResultPage(double height, double width) {
    return Container(
      color: const Color.fromRGBO(184, 184, 184, 1),
      height: height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
              child: Stack(
                children: [
                  SizedBox(
                    height: height * 0.32,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 35),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              separatorBuilder: (BuildContext context, int index) =>
                              const Divider(
                                color: Colors.grey,
                                height: 0.05,
                                indent: 10,
                                endIndent: 15,
                              ),
                              padding: const EdgeInsets.all(5),
                              shrinkWrap: true,
                              itemCount: 3,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == 3) {
                                  return const Divider(
                                    color: Colors.grey, height: 0.05,);
                                }

                                if (index < 2) {
                                  return Row(
                                    children: [
                                      Expanded(child: ListTile(
                                        title: Text(
                                            index == 0 ? firstText : index == 1
                                                ? secondText
                                                : formattedDate),
                                        onTap: () {
                                          if (index == 0) {
                                            _openCitySearchPage('first');
                                          } else if (index == 1) {
                                            _openCitySearchPage('second');
                                          } else {
                                            _selectDate(context);
                                          }
                                        },
                                        )
                                      ),

                                    ],
                                  );
                                }
                                else {
                                  return ListTile(
                                    title: Text(formattedDate),
                                    onTap: () {
                                      if (index == 2) {
                                        _selectDate(context);
                                      }
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.orange),
                                  minimumSize: MaterialStateProperty.all(
                                      Size(width, 50)),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7),
                                      )
                                  )
                              ),
                              onPressed: () {
                                setState(() {
                                  _tripFuture = _searchTrips();
                                });
                              },
                              child: const Text('Найти билет', style: TextStyle(
                                  color: Colors.white, fontSize: 18),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      top: 35,
                      right: 20,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange,
                        ),
                        child: IconButton(
                          onPressed: () {
                            swapText();
                          },
                          icon: const Icon(Icons.swap_vert_outlined),
                          iconSize: 30,
                          color: Colors.white,
                          splashRadius: 25,
                        ),
                      )
                  ),
                ],
              )
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _tripFuture,
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
                  List<Map<String, dynamic>> trips = snapshot.data ?? [];
                  if (trips.isEmpty) {
                    return Center(
                      child: Text('Нет доступных рейсов', style: TextStyle(fontSize: 18, // Размер шрифта
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.2,),),
                    );

                  }
                  else{
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          String date = _getDate(trips[index]['ROUTE_TIME']);
                          double? dividerWith = getDividerWidth(date);
                          String routeTime = _getDate(trips[index]['ROUTE_TIME'].toString());
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            title: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(trips[index]['DEPARTURE_DATE'], style: const TextStyle(fontWeight: FontWeight.w500),),
                                          Text(trips[index]['DESTINATION_DATE'], style: const TextStyle(fontWeight: FontWeight.w500),)
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(trips[index]['DEPARTURE_TIME'], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),),
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                child: SizedBox(
                                                  width: dividerWith,
                                                  child: const Divider(
                                                    thickness: 1,
                                                    color: Colors.black,
                                                  ),
                                                ),),

                                              Text(routeTime),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                child: SizedBox(
                                                  width: dividerWith,
                                                  child: const Divider(
                                                    thickness: 1,
                                                    color: Colors.black,
                                                  ),
                                                ),),
                                            ],
                                          ),
                                          Text(trips[index]['DESTINATION_TIME'], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),)
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(trips[index]["DepartureCityName"],style: const TextStyle(fontSize: 20),),
                                          Text(trips[index]["DestinationCityName"], style: const TextStyle(fontSize: 20),)
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(trips[index]["COST"].toString() + " руб.", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),),
                                              Text(trips[index]["COUNT_FREE_PLACES"].toString() + ' свободных мест', style: TextStyle(color: Colors.green),),
                                            ],
                                          ),
                                          Container(
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color.fromRGBO(32, 194, 32, 1.0),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  final result = await Navigator.push(context, MaterialPageRoute(
                                                      builder: (context) => BookingATicketPage(selectedTrip: trips[index], databaseNotifier: Provider.of<DatabaseNotifier>(context, listen: false))));
                                                  if(result != null){
                                                    setState(() {
                                                      _tripFuture = _searchTrips();
                                                    });
                                                  }
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                                  child: Text('Заказать', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w400),),
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                            ),
                          );
                        },
                        itemCount: trips.length,
                        shrinkWrap: true,
                      ),
                    );
                  }

                }
              },
            ),
          ],
        ),
      ),
    );
  }
}