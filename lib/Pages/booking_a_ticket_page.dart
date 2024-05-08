import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kursovoy/Database/BusStopHandler.dart';
import 'package:kursovoy/Database/ClientHandler.dart';
import 'package:kursovoy/Database/DatabaseNotifier.dart';
import 'package:kursovoy/Database/RoleHandler.dart';
import 'package:kursovoy/Database/TicketHandler.dart';
import 'package:kursovoy/Database/TripHandler.dart';
import 'package:kursovoy/Database/UserSharedHandler.dart';
import 'package:kursovoy/Models/BusStop.dart';
import 'package:kursovoy/Models/City.dart';
import 'package:kursovoy/Database/CityHandler.dart';
import 'package:kursovoy/Models/Client.dart';
import 'package:kursovoy/Models/Role.dart';
import 'package:kursovoy/Models/Ticket.dart';
import 'package:provider/provider.dart';

class BookingATicketPage extends StatefulWidget {
  Map<String, dynamic> selectedTrip;
  final DatabaseNotifier databaseNotifier;
  BookingATicketPage({required this.selectedTrip, required this.databaseNotifier } );

  @override
  _BookingATicketPageState createState() => _BookingATicketPageState();
}

class _BookingATicketPageState extends State<BookingATicketPage> {
  late Map<String, dynamic> selectedTrip;
  late DatabaseNotifier _databaseNotifier;
  final UserSharedHandler _userSharedHandler = UserSharedHandler("user_data");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  int _passengerCount = 0;

  String _landingPlace = 'Откуда';
  String _exitPlace = '';
  double _resultCost = 0;
  late TripHandler _tripHandler;
  List<String> _landings = [];
  List<String> _exits = [];
  List<String> _exitsTemp = [];
  bool _isAuthorized = false;
  int ticketNumber = 0;

  @override
  void initState() {
    super.initState();
    _databaseNotifier = widget.databaseNotifier;
    selectedTrip = widget.selectedTrip;
    _initializeState();
    _loadStops(selectedTrip);
    _profileInfoUser();
  }

  void _initializeState() async {
    int userId = await _userSharedHandler.loadUser();
    if (userId != 0) {
      setState(() {
        _isAuthorized = true;
      });
    } else {
      setState(() {
        _isAuthorized = false;
      });
    }

  }

  Future<void> _loadStops(Map<String, dynamic> selected) async {
      try{
        final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
        _tripHandler = TripHandler(dbHelper.db);
        List<Map<String, dynamic>> trips = await _tripHandler.getTripStops(selected["TRIPID"]);
        setState(() {
          _landings = trips.map((trip) => trip['BUSSTOPNAME'] as String).toList();
          _exits = List.from(_landings)..removeAt(0);
          _exitsTemp.addAll(_exits);
          if (_landings.isNotEmpty) {
            _landingPlace = _landings.first;
            if(_landings.length > 1){
              _landings.removeLast();
            }
          }
          if(_exits.isNotEmpty){
            _exitPlace = _exits.last;
          }
        });
      }
    catch(e){
      print("error: $e");
    }
  }

  Future<Map<String, dynamic>> _checkCount(String phone, int tripId) async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    List<Map<String, dynamic>> ticketsInfo = await ClientHandler(dbHelper.db).getCountOrders(phone, tripId);
    int ticketId = 0;
    int ticketCount = 0;
    for (Map<String, dynamic> ticketInfo in ticketsInfo) {
      ticketId = ticketInfo['TICKETID'];
      ticketCount = ticketInfo['COUNT(TICKETID)'];
    }
    print(ticketCount);
    bool hasTickets = ticketCount > 0;
    Map<String, dynamic> result = {
      'result': hasTickets,
      'ticketId': hasTickets ? ticketId : 0,
    };

    return result;
  }


  Future<int?> _checkDriverId(int tripId) async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    int? result = await TripHandler(dbHelper.db).getDriverIdByTripId(tripId);
    return result;
  }



  Future _profileInfoUser() async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    ClientHandler clientHandler = ClientHandler(dbHelper.db);
    int id = await _userSharedHandler.loadUser();
    Client? client = await clientHandler.getClient(id);
    if(client != null){
      _isAuthorized = true;
      _nameController.text = client.userName;
      _surnameController.text = client.userLastName;
      _phoneNumberController.text = client.telephone;
    }
    else{
      _isAuthorized = false;
    }
  }

  Future _addTicketAuthorizedUser(Map<String, dynamic> selected) async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    TicketHandler ticketHandler = TicketHandler(dbHelper.db);
    int userId = await _userSharedHandler.loadUser();
    BusStopHandler busStopHandler = BusStopHandler(dbHelper.db);
    int landingFromId = await busStopHandler.getBusStopId(_landingPlace, selected["ROUTEID"]);
    int landingToId = await busStopHandler.getBusStopId(_exitPlace, selected["ROUTEID"]);
    Ticket ticket = Ticket(selected["TRIPID"], userId, landingFromId, landingToId, _passengerCount, _resultCost);
    await ticketHandler.insert(ticket);
    List<Ticket> tickets = await TicketHandler(dbHelper.db).getAllTickets();
    ticketNumber = tickets.last.id;
    print(ticketNumber);
    _showDialog("Билет успешно заказан. ID билета: $ticketNumber");
  }
  Future _addTicketUnauthorizedUser(Map<String, dynamic> selected) async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    TicketHandler ticketHandler = TicketHandler(dbHelper.db);
    ClientHandler clientHandler = ClientHandler(dbHelper.db);
    String phone = "+375${_phoneNumberController.text}";
    Client? client = await clientHandler.getClientByPhone(phone);
    if(client != null){
      int userId = client.id;
      print(userId);
      BusStopHandler busStopHandler = BusStopHandler(dbHelper.db);
      int landingFromId = await busStopHandler.getBusStopId(_landingPlace, selected["ROUTEID"]);
      int landingToId = await busStopHandler.getBusStopId(_exitPlace, selected["ROUTEID"]);
      Ticket ticket = Ticket(selected["TRIPID"], userId, landingFromId, landingToId, _passengerCount, _resultCost);
      await ticketHandler.insert(ticket);

    }
    else{
      Client clientUnauthorized = Client('', '', _nameController.text, _surnameController.text, phone, 2, 'UNREGISTERED');
      await clientHandler.insert(clientUnauthorized);
      Client? searchClient = await clientHandler.getClientByPhone(clientUnauthorized.telephone);
      if(searchClient != null){
        int userId = searchClient.id;
        print(userId);
        BusStopHandler busStopHandler = BusStopHandler(dbHelper.db);
        int landingFromId = await busStopHandler.getBusStopId(_landingPlace, selected["ROUTEID"]);
        int landingToId = await busStopHandler.getBusStopId(_exitPlace, selected["ROUTEID"]);
        Ticket ticket = Ticket(selected["TRIPID"], userId, landingFromId, landingToId, _passengerCount, _resultCost);
        await ticketHandler.insert(ticket);
      }
    }
    List<Ticket> tickets = await TicketHandler(dbHelper.db).getAllTickets();
    ticketNumber = tickets.last.id;
    print(ticketNumber);
    _showDialog("Билет успешно заказан. ID билета: $ticketNumber");
  }



  void _showDialog(String message){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ошибка'),
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
    if (selectedTrip != null && selectedTrip.containsKey("COST")) {
      var costDouble = selectedTrip["COST"] as num;
      _resultCost = _passengerCount * costDouble.toDouble();
    }
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 58;

    return Scaffold(
      appBar: AppBar(
        title: Text("Оформление заказа"),
      ),
      body:_buildTicketPage()
    );
  }

  Widget _buildTicketPage() {
    var cost = selectedTrip["COST"] as num;
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10,),
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Имя',
                  prefixIcon: Icon(Icons.person),
                  prefixIconColor: _isAuthorized ? Colors.grey : Colors.black,
                  border: OutlineInputBorder(),
                ),
                enabled: _isAuthorized ? false : true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Zа-яА-Я]*$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите имя';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _surnameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Фамилия',
                  prefixIcon: Icon(Icons.person),
                  prefixIconColor: _isAuthorized ? Colors.grey : Colors.black,
                  border: OutlineInputBorder(),
                ),
                enabled: _isAuthorized ? false : true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Zа-яА-Я]*$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите фамилию';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Номер телефона',
                  prefixText: _isAuthorized ? "" : '+375',
                  prefixIcon: Icon(Icons.phone),
                  prefixIconColor: _isAuthorized ? Colors.grey : Colors.black,
                  border: OutlineInputBorder(),
                ),
                enabled: _isAuthorized ? false : true,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[^+\d]')),
                  _isAuthorized ? LengthLimitingTextInputFormatter(13) : LengthLimitingTextInputFormatter(9),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите номер телефона';
                  }
                  else if((_isAuthorized && value.length < 13) || (!_isAuthorized && value.length < 9)){
                    return 'Введите верный номер телефона';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Количество пассажиров:',
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (_passengerCount < selectedTrip["COUNT_FREE_PLACES"]) {
                                _passengerCount++;
                              }
                            });
                          },
                          icon: Icon(Icons.add),
                          color: Colors.green,
                        ),
                        Text(
                          '$_passengerCount',
                          style: TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_passengerCount > 0) {
                              setState(() {
                                _passengerCount--;
                              });
                            }
                          },
                          icon: Icon(Icons.remove),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text("Место посадки: ", style: TextStyle(fontSize: 17),),
                  DropdownButton<String>(
                    value: _landingPlace,
                    onChanged: (newValue) {
                      setState(() {
                        _landingPlace = newValue!;
                        if(_exitsTemp.contains(_landingPlace)){
                          print('true');
                          _exits.clear();
                          _exits.addAll(_exitsTemp);
                          int index = _exits.indexOf(_landingPlace);
                          _exits.removeRange(0, index + 1);
                        }
                        else{
                          print('false');
                          _exits.clear();
                          _exits.addAll(_exitsTemp);
                        }
                        if (_exits.isNotEmpty) {
                          _exitPlace = _exits.last;
                        }
                      });
                    },
                    items: _landings.map((trip) {
                      return DropdownMenuItem<String>(
                        value: trip,
                        child: Text(trip),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Row(
                children: [
                  Text("Место высадки: ", style: TextStyle(fontSize: 17),),
                  DropdownButton<String>(
                    value: _exitPlace,
                    onChanged: (newValue) {
                      setState(() {
                        _exitPlace = newValue!;
                      });
                    },
                    items: _exits.map((trip) {
                      return DropdownMenuItem<String>(
                        value: trip,
                        child: Text(trip),
                      );
                    }).toList(),
                  ),
                ],
              ),

              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Количество пассажиров:", style: TextStyle(fontSize: 18),),
                          Text('$_passengerCount',style: TextStyle(fontSize: 18),)
                        ],
                      ),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Стоимость проезда:',style: TextStyle(fontSize: 18),),
                          Text('$cost руб.',style: TextStyle(fontSize: 18),)
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Итого:',style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),),
                          Text('$_resultCost руб.',style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),)
                        ],
                      )
                    ],
                  ),
                )
              ),

              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () async{
                  if (_formKey.currentState!.validate()) {
                    Map<String, dynamic> checkResult = await _checkCount(_phoneNumberController.text,selectedTrip["TRIPID"]);
                    int? driverID = await _checkDriverId(selectedTrip["TRIPID"]);
                    int userId = await _userSharedHandler.loadUser();
                    setState(() {
                        if(_passengerCount != 0){
                          if(checkResult['result']){
                            _showDialog("Вы уже заказали билет на этот рейс. ID заказанного билета: ${checkResult['ticketId']}");
                          }
                          else if(driverID != null && driverID == userId){
                            _showDialog("Вы не можете забронировать место на данный рейс, т.к. являетесь водителем на данном рейсе");
                          }
                          else{
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Подтверждение"),
                                  content: Text("Вы действительно хотите заказать билет?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        _isAuthorized ? _addTicketAuthorizedUser(selectedTrip) : _addTicketUnauthorizedUser(selectedTrip);
                                        Navigator.of(context).pop(true);
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Text("Да"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text("Нет"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        }
                        else{
                          _showDialog("Количество пассажиров не может равняться 0");
                        }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Подтвердить',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
