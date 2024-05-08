import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kursovoy/Database/DatabaseNotifier.dart';
import 'package:kursovoy/Database/TicketHandler.dart';
import 'package:kursovoy/Database/TripHandler.dart';
import 'package:kursovoy/Database/UserSharedHandler.dart';
import 'package:kursovoy/Models/City.dart';
import 'package:kursovoy/Database/CityHandler.dart';
import 'package:kursovoy/Models/Ticket.dart';
import 'package:kursovoy/Pages/ticket_info_page.dart';
import 'package:kursovoy/Providers/AuthProvider.dart';
import 'package:provider/provider.dart';

class TripsPage extends StatefulWidget {
  final DatabaseNotifier databaseNotifier;
  TripsPage({required this.databaseNotifier});

  @override
  _TripsPageState createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  final _formKey = GlobalKey<FormState>();
  final UserSharedHandler _userSharedHandler = UserSharedHandler("user_data");
  final TextEditingController _identificatorController =
      TextEditingController();
  late Future<List<Map<String, dynamic>>>? _ticketsFuture;
  late Future<List<Map<String, dynamic>>>? _ticketsFutureAuth;
  late Future _authFuture;

  Future<List<Map<String, dynamic>>> _searchTickets(int id) async {
    final dbHelper =
        Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    return await TicketHandler(dbHelper.db).getTicketByIdUnauthorized(id);
  }

  @override
  void initState() {
    super.initState();
    _ticketsFuture = null;
    _ticketsFutureAuth = null;
    _authFuture = _getTickets();
  }

  Future<void> _getTickets() async {
    int userId = await _userSharedHandler.loadUser();
    final dbHelper =
        Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    setState(() {
      _ticketsFutureAuth =
          TicketHandler(dbHelper.db).getTicketsByIdAuthorized(userId);
    });
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 58;
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: FutureBuilder(
            future: _authFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                if (authProvider.isAuthorized) {
                  return _buildAuthorizedTrips(height, width);
                } else {
                  return _buildUnauthorizedTrips(height, width);
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorizedTrips(double height, double width) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ваши билеты',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () async {
                      await _getTickets();
                    },
                    icon: const Icon(
                      Icons.update,
                      size: 32,
                    ))
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _ticketsFutureAuth,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Ошибка: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  List<Map<String, dynamic>> tickets = snapshot.data ?? [];
                  if (tickets.isEmpty) {
                    return Center(
                      child: Text(
                        'Нет доступных рейсов',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.2,
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          double? dividerWith =
                              getDividerWidth(tickets[index]['ROUTE_TIME']);
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TicketInfoPage(
                                          selectedTicketId: tickets[index]
                                              ['TICKETID'],
                                          databaseNotifier:
                                              Provider.of<DatabaseNotifier>(
                                                  context,
                                                  listen: false))));
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
                                              "Билет № ${tickets[index]["TICKETID"].toString()}",
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
                                              tickets[index]["DEPARTURE_DATE"],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              tickets[index]
                                                  ["DESTINATION_DATE"],
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
                                              tickets[index]["DEPARTURE_TIME"],
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
                                                Text(tickets[index]
                                                    ["ROUTE_TIME"]),
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
                                              tickets[index]
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
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tickets[index]["COST"]
                                                          .toString() +
                                                      " руб.",
                                                  style: TextStyle(
                                                      fontSize: 28,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Text(
                                                  'Количество мест: ${tickets[index]["COUNT_PLACES"].toString()}',
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
                                                                    tickets[index]
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
                        itemCount: tickets.length,
                        shrinkWrap: true,
                      ),
                    );
                  }
                } else {
                  return Text('Нет данных');
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUnauthorizedTrips(double height, double width) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _identificatorController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ID билета',
                      prefixIcon: Icon(Icons.route),
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[^\d]')),
                      LengthLimitingTextInputFormatter(9),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите ID билета';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 1),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    color: Colors.blue,
                  ),
                  child: InkWell(
                    onTap: () {
                      if (_formKey.currentState != null) {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _ticketsFuture = _searchTickets(
                                int.parse(_identificatorController.text));
                          });
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _ticketsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Ошибка: ${snapshot.error}');
              } else if (snapshot.hasData) {
                List<Map<String, dynamic>> tickets = snapshot.data ?? [];
                if (tickets.isEmpty) {
                  return Center(
                    child: Text(
                      'Нет доступных рейсов',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.2,
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        double? dividerWith =
                            getDividerWidth(tickets[index]['ROUTE_TIME']);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TicketInfoPage(
                                        selectedTicketId: tickets[index]
                                            ['TICKETID'],
                                        databaseNotifier:
                                            Provider.of<DatabaseNotifier>(
                                                context,
                                                listen: false))));
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
                                            "Билет № ${tickets[index]["TICKETID"].toString()}",
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
                                            tickets[index]["DEPARTURE_DATE"],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            tickets[index]["DESTINATION_DATE"],
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
                                            tickets[index]["DEPARTURE_TIME"],
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
                                                  tickets[index]["ROUTE_TIME"]),
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
                                            tickets[index]["DESTINATION_TIME"],
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
                                            tickets[index]["COST"].toString() +
                                                " руб.",
                                            style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            'Количество мест: ${tickets[index]["COUNT_PLACES"].toString()}',
                                            style: TextStyle(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        );
                      },
                      itemCount: tickets.length,
                      shrinkWrap: true,
                    ),
                  );
                }
              } else {
                return Text('Нет данных');
              }
            },
          )),
        ],
      ),
    );
  }
}
