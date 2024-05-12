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

class UpdateTicketAdminPage extends StatefulWidget {
  int selectedTripId;
  int selectedTicketId;
  final DatabaseNotifier databaseNotifier;
  UpdateTicketAdminPage({required this.selectedTripId, required this.selectedTicketId, required this.databaseNotifier } );

  @override
  _UpdateTicketAdminPageState createState() => _UpdateTicketAdminPageState();
}

class _UpdateTicketAdminPageState extends State<UpdateTicketAdminPage> {
  late int selectedTripId;
  late int selectedTicketId;

  late DatabaseNotifier _databaseNotifier;
  final UserSharedHandler _userSharedHandler = UserSharedHandler("user_data");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  Map<String, dynamic> selectedTicket = {};
  int _passengerCount = 0;

  String _landingPlace = 'Откуда';
  String _exitPlace = '';
  double _resultCost = 0;
  late TripHandler _tripHandler;
  List<String> _landings = [];
  List<String> _exits = [];
  List<String> _exitsTemp = [];
  int ticketNumber = 0;

  @override
  void initState() {
    super.initState();
    _databaseNotifier = widget.databaseNotifier;
    selectedTripId = widget.selectedTripId;
    selectedTicketId = widget.selectedTicketId;
    _ticketInfoUser();
    _loadStops(selectedTripId);
  }


  Future<void> _loadStops(int tripID) async {
    try{
      final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
      _tripHandler = TripHandler(dbHelper.db);
      selectedTicket = await TicketHandler(dbHelper.db).getTicketById(selectedTicketId);
      List<Map<String, dynamic>> trips = await _tripHandler.getTripStops(tripID);
      setState(() {
        _landings = trips.map((trip) => trip['BUSSTOPNAME'] as String).toList();
        _exits = List.from(_landings)..removeAt(0);
        _exitsTemp.addAll(_exits);
        var landingFrom = _landings.firstWhere(
              (item) => item == selectedTicket["LandingFromCityName"],
          orElse: () => 'DefaultValue',
        );
        var landingTo = _landings.firstWhere(
              (item) => item == selectedTicket["LandingToCityName"],
          orElse: () => 'DefaultValue',
        );
        if (_landings.isNotEmpty) {
          _landingPlace = landingFrom;
          if(_landings.length > 1){
            _landings.removeLast();
          }

        }
        if(_exits.isNotEmpty){
          _exitPlace = landingTo;
        }
      });
    }
    catch(e){
      print("error: $e");
    }
  }




  void _showDialog(String message, String result){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(result),
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

  Future _updateTicket(int routeId) async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    TicketHandler ticketHandler = TicketHandler(dbHelper.db);
    BusStopHandler busStopHandler = BusStopHandler(dbHelper.db);
    int landingFromId = await busStopHandler.getBusStopId(_landingPlace, routeId);
    int landingToId = await busStopHandler.getBusStopId(_exitPlace, routeId);
    await ticketHandler.updateTicketDetails(selectedTicketId, landingFromId, landingToId, _resultCost, _passengerCount);
  }


  void _ticketInfoUser() async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    selectedTicket = await TicketHandler(dbHelper.db).getTicketById(selectedTicketId);
    setState(() {
      _nameController.text = selectedTicket['ClientName'];
      _surnameController.text = selectedTicket['ClientLastName'];
      _phoneNumberController.text = selectedTicket['ClientTelephone'];
      _passengerCount = selectedTicket["COUNT_PLACES"];
    });
  }


  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 58;
    if(selectedTicket.isNotEmpty){
      var costDouble = selectedTicket["TRIPCOST"] as num;
      _resultCost = _passengerCount * costDouble.toDouble();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Оформление заказа"),
        ),
        body:_buildTicketPage()
    );
  }

  Widget _buildTicketPage() {
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
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,

                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _surnameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Фамилия',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,

                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Номер телефона',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,


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
                                if (_passengerCount < (selectedTicket["TRIPFREEPLACES"] + selectedTicket["COUNT_PLACES"])) {
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
                            _exits.clear();
                            _exits.addAll(_exitsTemp);
                            int index = _exits.indexOf(_landingPlace);
                            _exits.removeRange(0, index + 1);
                          }
                          else{
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
                          child: Container(
                            width: 200,
                            child: Text(
                              trip,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                          child: Container(
                            width: 200,
                            child: Text(
                              trip,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                      int userId = await _userSharedHandler.loadUser();
                      setState(() {
                        if(_passengerCount != 0){

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Подтверждение"),
                                  content: Text("Вы действительно хотите изменить билет?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () async{
                                        await _updateTicket(selectedTicket['ROUTEID']);
                                        Navigator.pop(context, true);
                                        Navigator.pop(context, true);
                                        _showDialog("Билет успешно обновлен. ID билета: $selectedTicketId", 'Успех');
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
                        else{
                          _showDialog("Количество пассажиров не может равняться 0", 'Ошибка');
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
