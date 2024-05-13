import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kursovoy/Database/BusHandler.dart';
import 'package:kursovoy/Database/CityHandler.dart';
import 'package:kursovoy/Database/ClientHandler.dart';
import 'package:kursovoy/Database/DatabaseNotifier.dart';
import 'package:kursovoy/Database/RoleHandler.dart';
import 'package:kursovoy/Database/RouteHandler.dart';
import 'package:kursovoy/Database/TicketHandler.dart';
import 'package:kursovoy/Database/TripHandler.dart';
import 'package:kursovoy/Models/City.dart';
import 'package:kursovoy/Models/Client.dart';
import 'package:kursovoy/Models/Role.dart';
import 'package:kursovoy/Models/Trip.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


class TripAdminPage extends StatefulWidget {
  final DatabaseNotifier databaseNotifier;

  TripAdminPage({required this.databaseNotifier});

  @override
  _TripAdminPageState createState() => _TripAdminPageState();
}

class _TripAdminPageState extends State<TripAdminPage> {
  DateTime pickedValue = DateTime.now();
  String formattedDate = DateFormat('dd MMMM yyyy', 'ru_RU').format(
      DateTime.now().add(Duration(days: 1)));
  Future<void> _initFuture = initializeDateFormatting('ru_RU', null);
  TextEditingController _secondDateController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _timeRouteController = TextEditingController();
  TextEditingController _firstTimeController = TextEditingController();
  TextEditingController _secondTimeController = TextEditingController();
  TextEditingController _costController = TextEditingController();
  TextEditingController _searchDriversController = TextEditingController();
  TextEditingController _driverIdController = TextEditingController();
  TextEditingController _searchBusesController = TextEditingController();
  TextEditingController _busIdController = TextEditingController();
  TextEditingController _placesController = TextEditingController();
  TextEditingController _searchDriversUpdateController = TextEditingController();
  TextEditingController _searchUpdateController = TextEditingController();
  TextEditingController _tripIdController = TextEditingController();
  TextEditingController _driverIdUpdateController = TextEditingController();
  TextEditingController _searchBusesUpdateController = TextEditingController();
  TextEditingController _busIdUpdateController = TextEditingController();
  TextEditingController _placesUpdateController = TextEditingController();
  TextEditingController _costUpdateController = TextEditingController();
  TextEditingController _tripIdDeleteController = TextEditingController();
  TextEditingController _searchDeleteController = TextEditingController();

  List<Map<String, dynamic>> _ticketsList = [];
  List<Map<String, dynamic>> _filteredRoutesList = [];
  List<Map<String, dynamic>> _filteredDriversList = [];
  List<Map<String, dynamic>> _filteredBusesList = [];
  List<Map<String, dynamic>> _filteredTripsList = [];
  List<Map<String, dynamic>> _filteredDriversUpdateList = [];
  List<Map<String, dynamic>> _filteredBusesUpdateList = [];
  List<Map<String, dynamic>> _filteredTripsDeleteList = [];
  bool isCheckRoutes = false;
  bool isRouteAdded = false;
  bool isCheckDrivers = false;
  bool isCheckBuses = false;
  bool isDestinationTimeGot = false;
  bool isAddedDriver = false;
  bool isAddedBus = false;
  bool isTripsCheck = false;
  bool isTripAdded = false;
  bool isDriverUpdateCheck = false;
  bool isBusesUpdateCheck = false;
  bool isAddedUpdateDriver = false;
  bool isCheckUpdateDrivers = false;
  bool isAddedUpdateBus = false;
  bool isCostUpdateCheck = false;
  bool isTripsDeleteCheck = false;
  bool isTripDeleteAdded = false;

  Trip selectedTrip = Trip('', '', '', '', 0, 0, 0, 0, 0, "");


  @override
  void initState() {
    super.initState();
  }

  Future<void> _getTickets() async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    String searchQuery = _searchController.text.trim();
    List<Map<String, dynamic>> result = await RouteHandler(dbHelper.db).getRouteWithFilter(searchQuery);
    setState(() {
      _ticketsList = result;
      if(result.length > 50){
        _filteredRoutesList = result.sublist(0, 50);
      }
      else{
        _filteredRoutesList = result;
      }
    });
  }



  Future<void> _getTrips() async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    String searchQuery = _searchUpdateController.text.trim();
    List<Map<String, dynamic>> result = await TripHandler(dbHelper.db).getAllTripsUpdate(searchQuery);
    setState(() {
      _ticketsList = result;
      if(result.length > 50){
        _filteredTripsList = result.sublist(0, 50);
      }
      else{
        _filteredTripsList = result;
      }
    });
  }


  Future<void> _getTripsDelete() async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    String searchQuery = _searchDeleteController.text.trim();
    List<Map<String, dynamic>> result = await TripHandler(dbHelper.db).getAllTripsUpdate(searchQuery);
    setState(() {
      _ticketsList = result;
      if(result.length > 50){
        _filteredTripsDeleteList = result.sublist(0, 50);
      }
      else{
        _filteredTripsDeleteList = result;
      }
    });
  }



  Future<void> _getDrivers() async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    String searchQuery = _searchDriversController.text.trim();
    DateTime departureDate = DateFormat('dd MMMM yyyy', 'ru_RU').parse(formattedDate);
    DateTime destinationDate = DateFormat('dd MMMM yyyy', 'ru_RU').parse(_secondDateController.text);
    String departureDateString = DateFormat('yyyy-MM-dd').format(departureDate);
    String destinationDateString = DateFormat('yyyy-MM-dd').format(destinationDate);


    List<Map<String, dynamic>> result = await ClientHandler(dbHelper.db).getFreeDrivers(searchQuery, departureDateString, destinationDateString, _firstTimeController.text, _secondTimeController.text);
    setState(() {
      if(result.length > 50){
        _filteredDriversList = result.sublist(0, 50);
      }
      else{
        _filteredDriversList = result;
      }
    });
  }
Future<void> _getDriversUpdate() async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    String searchQuery = _searchDriversUpdateController.text.trim();
    List<Map<String, dynamic>> result = await ClientHandler(dbHelper.db).getFreeDrivers(searchQuery, selectedTrip.departureDate, selectedTrip.destinationDate, selectedTrip.departureTime, selectedTrip.destinationTime);
    setState(() {
      if(result.length > 50){
        _filteredDriversUpdateList = result.sublist(0, 50);
      }
      else{
        _filteredDriversUpdateList = result;
      }
    });
  }

  void addTrip(Trip trip) async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    await TripHandler(dbHelper.db).insert(trip);
    _showDialog('Рейс успешно добавлен', 'Успех');
    setState(() {
      isDestinationTimeGot = false;
      _secondDateController.text = '';
      _secondTimeController.text = '';
      isCheckDrivers = false;
      _driverIdController.text = '';
      isCheckBuses = false;
      isCheckRoutes = false;
      _busIdController.text = '';
      _placesController.text = '';
      _costController.text = '';
      isAddedDriver = false;
      isAddedBus = false;
      _firstTimeController.text = '';
      isRouteAdded = false;
      _timeRouteController.text = '';
      _idController.text = '';
    });
  }


  void deleteTrip() async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Подтверждение"),
          content: Text("Вы уверены, что хотите удалить данный рейс?"),
          actions: <Widget>[
            TextButton(
              child: Text("Нет"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("Да"),
              onPressed: () async{
                await TripHandler(dbHelper.db).delete(int.parse(_tripIdDeleteController.text));
                Navigator.of(context).pop(true);
                _showDialog('Рейс успешно удален', 'Успех');
                setState(() {
                 _tripIdDeleteController.text = '';
                 isTripsDeleteCheck = false;
                 isTripDeleteAdded = false;
                });
              },
            ),
          ],
        );
      },
    );
  }



  void _updateTrip() async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    int driverId = selectedTrip.driverId;
    int busId = selectedTrip.busId;
    double cost = selectedTrip.cost;
    int places = selectedTrip.countFreePlaces;
    bool isAllValid = true;

    if(_driverIdUpdateController.text != ''){
      driverId = int.parse(_driverIdUpdateController.text);
    }

    if(_busIdUpdateController.text != ''){
      busId = int.parse(_busIdUpdateController.text);
    }

    if(_placesUpdateController.text != ''){
      places = int.parse(_placesUpdateController.text);
    }

    if(_costUpdateController.text != ''){
      String pattern = r'[0-9]';
      String pattern1 = r'^\d{1,3}(\.\d{1,2})?$';
      RegExp regExp = new RegExp(pattern);
      RegExp regExp1 = new RegExp(pattern1);

      bool isValid = regExp.hasMatch(_costUpdateController.text);
      bool isValid1 = regExp1.hasMatch(_costUpdateController.text);

      if(isValid && isValid1){
        if((_costUpdateController.text.length == 1 && _costUpdateController.text == '0') || (_costController.text.length > 1 && (_costController.text[0] == "0" && _costController.text[1] != '.'))){
          _showDialog('Введите верную цену. Либо просто число, либо число с точкой', 'Ошибка');
          isAllValid = false;
        }
        else{
          cost = double.parse(_costUpdateController.text);
        }
      }
      else{
        _showDialog('Введите верную цену. Либо просто число, либо число с точкой', 'Ошибка');
        isAllValid = false;
      }
    }


    if(isAllValid){
      await TripHandler(dbHelper.db).update(int.parse(_tripIdController.text), driverId, busId, places, cost);
      _showDialog('Рейс успешно обновлен', 'Успех');
      setState(() {
        isTripAdded = false;
        _tripIdController.text = '';
        _driverIdUpdateController.text = '';
        isBusesUpdateCheck = false;
        _busIdUpdateController.text = '';
        isCostUpdateCheck = false;
        _costUpdateController.text = '';
        isAddedUpdateBus = false;
        isAddedUpdateDriver = false;
        isDriverUpdateCheck = false;
        isTripsCheck = false;
      });
    }

  }


  Future<void> _getBuses() async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    String searchQuery = _searchBusesController.text.trim();
    DateTime departureDate = DateFormat('dd MMMM yyyy', 'ru_RU').parse(formattedDate);
    DateTime destinationDate = DateFormat('dd MMMM yyyy', 'ru_RU').parse(_secondDateController.text);

    String departureDateString = DateFormat('yyyy-MM-dd').format(departureDate);
    String destinationDateString = DateFormat('yyyy-MM-dd').format(destinationDate);

    List<Map<String, dynamic>> result = await BusHandler(dbHelper.db).getFreeBuses(searchQuery, departureDateString, destinationDateString, _firstTimeController.text, _secondTimeController.text);
    setState(() {
      if(result.length > 50){
        _filteredBusesList = result.sublist(0, 50);
      }
      else{
        _filteredBusesList = result;
      }
    });
  }
  Future<void> _getBusesUpdate() async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    String searchQuery = _searchBusesUpdateController.text.trim();
    print(selectedTrip.countFreePlaces);
    List<Map<String, dynamic>> result = await BusHandler(dbHelper.db).getFreeBusesUpdate(searchQuery, selectedTrip.departureDate, selectedTrip.destinationDate, selectedTrip.departureTime, selectedTrip.destinationTime);
    setState(() {
      if(result.length > 50){
        _filteredBusesUpdateList = result.sublist(0, 50);
      }
      else{
        _filteredBusesUpdateList = result;
      }
    });
  }


  int _getDestinationTime() {
    String departureTime = _firstTimeController.text;
    String date = _timeRouteController.text;
    String hoursDeparture = '';
    String hours = '';
    String minutesDeparture = '';
    String minutes = '';
    String resultMinutes = '';
    String resultHours = '';
    int resultMinutesInt = 0;
    int resultHoursInt = 0;
    int resultDaysInt = 0;

    //Часы во времени пути
    if(date[5] == '0' && date[6] != '0'){
      hours += date[6];
    }
    else if((date[5] != '0' && date[6] != '0') || (date[5] != '0' && date[6] == '0')){
      hours += '${date[5]}${date[6]}';
    }
    else{
      hours = '';
    }
    //часы отправления
    if(departureTime[0] == '0' && departureTime[1] != '0'){
      hoursDeparture += departureTime[1];
    }
    else if((departureTime[0] != '0' && departureTime[1] != '0') || (departureTime[0] != '0' && departureTime[1] == '0')){
      hoursDeparture += '${departureTime[0]}${departureTime[1]}';
    }
    else{
      hoursDeparture = '0';
    }


    //минуты пути
    if(date[10] == '0' && date[11] != '0'){
      minutes += date[10];
    }
    else if((date[10] != '0' && date[11] != '0') || (date[10] != '0' && date[11] == '0')){
      minutes += '${date[10]}${date[11]}';
    }
    else{
      minutes += '0';
    }

    //минуты отправления
    if(departureTime[3] == '0' && departureTime[4] != '0'){
      minutesDeparture += departureTime[4];
    }
    else if((departureTime[3] != '0' && departureTime[4] != '0') || (departureTime[3] != '0' && departureTime[4] == '0')){
      minutesDeparture += '${departureTime[3]}${departureTime[4]}';
    }
    else{
      minutesDeparture += '0';
    }

    if(minutes == "0" && minutesDeparture == "0"){
      resultMinutes = "00";
    }
    else{
      int minutesRoute = int.parse(minutes);
      int minutesDep = int.parse(minutesDeparture);
      resultMinutesInt = minutesRoute + minutesDep;
      if(resultMinutesInt == 60){
        resultMinutes = '00';
        resultHoursInt += 1;
      }
      else if(resultMinutesInt > 60){
        int tempResultMinutesInt = resultMinutesInt - 60;
        if(tempResultMinutesInt >= 10){
          resultMinutes = tempResultMinutesInt.toString();
        }
        else{
          resultMinutes = '0' + tempResultMinutesInt.toString();
        }
        resultHoursInt += 1;
      }
      else{
        if(resultMinutesInt >= 10){
          resultMinutes = resultMinutesInt.toString();
        }
        else{
          resultMinutes = '0' + resultMinutesInt.toString();
        }
      }
    }

      int hoursRoute = int.parse(hours);
      int hoursDep = int.parse(hoursDeparture);
      resultHoursInt += (hoursRoute + hoursDep);
      if(resultHoursInt == 24){
        resultHours = '00';
        resultDaysInt += 1;
      }
      else if(resultHoursInt > 24){
        int tempResultHoursInt = resultHoursInt - 24;
        if(tempResultHoursInt >= 10){
          resultHours = tempResultHoursInt.toString();
        }
        else{
          resultHours = '0' + tempResultHoursInt.toString();
        }
        resultDaysInt += 1;
      }
      else{
        if(resultHoursInt >= 10){
          resultHours = resultHoursInt.toString();
        }
        else{
          resultHours = '0' + resultHoursInt.toString();
        }
      }

      String resultTime = '$resultHours:$resultMinutes';
      setState(() {
        _secondTimeController.text = resultTime;
      });

    return resultDaysInt;
  }



  String _getDestinationDate(String date, int resultDaysInt) {
    DateTime departureDate = DateFormat('dd MMMM yyyy', 'ru_RU').parse(formattedDate);
    String routeTime = '';
    String destinationDate = '';


    if(date[0] == '0' && date[1] != '0'){
      routeTime += date[1];
    }
    else if((date[0] != '0' && date[1] != '0') || (date[0] != '0' && date[1] == '0')){
      routeTime += '${date[0]}${date[1]}';
    }
    else{
      routeTime += '';
    }

    if(routeTime == '' && resultDaysInt == 0){
      destinationDate = formattedDate;
    }
    else if(routeTime == '' && resultDaysInt != 0){
      DateTime arrivalDate = departureDate.add(Duration(days: 1));
      destinationDate = DateFormat('dd MMMM yyyy', 'ru_RU').format(arrivalDate);
    }
    else{
      int days = int.parse(routeTime) + resultDaysInt;
      DateTime arrivalDate = departureDate.add(Duration(days: days));
      destinationDate = DateFormat('dd MMMM yyyy', 'ru_RU').format(arrivalDate);
    }
    return destinationDate;
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



  Future<void> _selectDate(BuildContext context) async {
    await _initFuture;
    final DateTime initialDate = DateFormat('dd MMMM yyyy', 'ru_RU')
        .parse(formattedDate);
    final DateTime tomorrow = DateTime.now().add(Duration(days: 1));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      lastDate: DateTime(DateTime.now().year, 12, 31),
      locale: Locale('ru', 'RU'),
    );

    if (picked != null) {
      setState(() {
        pickedValue = picked;
        formattedDate =
            DateFormat('dd MMMM yyyy', 'ru_RU').format(picked);
      });
      if(isDestinationTimeGot){
        setState(() {
          isDestinationTimeGot = false;
          _secondDateController.text = '';
          _secondTimeController.text = '';
          isCheckDrivers = false;
          _driverIdController.text = '';
          isCheckBuses = false;
          isCheckRoutes = false;
          _busIdController.text = '';
          _placesController.text = '';
          _costController.text = '';
          isAddedDriver = false;
          isAddedBus = false;
          _firstTimeController.text = '';
          isRouteAdded = false;
          _timeRouteController.text = '';
          _idController.text = '';
        });
      }
    }
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
        title: Text('Управление рейсами'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10,),
            Text('Добавление', style: TextStyle(fontSize: 22),),
            SizedBox(height: 10,),
            InkWell(
              onTap: () {
                _selectDate(context);
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Дата отправления: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10,),

            if(!isCheckRoutes)
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () async{
                    await _getTickets();
                    setState(() {
                      isCheckRoutes = true;
                      _timeRouteController.text = '';
                      _idController.text = '';
                      isRouteAdded = false;
                    });
                    if(isDestinationTimeGot){
                      setState(() {
                        isDestinationTimeGot = false;
                        _secondDateController.text = '';
                        _secondTimeController.text = '';
                        isCheckBuses = false;
                        isCheckDrivers = false;
                        _driverIdController.text = '';
                        _busIdController.text = '';
                        _placesController.text = '';
                        _costController.text = '';
                        isAddedDriver = false;
                        isAddedBus = false;
                        _firstTimeController.text = '';
                        isRouteAdded = false;
                        _timeRouteController.text = '';
                        _idController.text = '';

                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Выбор маршрута',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            if(isCheckRoutes)
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
                    itemCount: _filteredRoutesList.length,
                    itemBuilder: (context, index) {
                      double? dividerWith =
                      getDividerWidth(_getDate(_filteredRoutesList[index]['ROUTE_TIME']));
                      return GestureDetector(
                        onTap: () async{
                          setState(() {
                            _idController.text = _filteredRoutesList[index]['ROUTEID'].toString();
                            _timeRouteController.text = _filteredRoutesList[index]['ROUTE_TIME'];
                            isRouteAdded = true;
                            isCheckRoutes = false;
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Маршрут № ${_filteredRoutesList[index]["ROUTEID"].toString()}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Text('Маршрут: '),
                                        Text(
                                          _filteredRoutesList[index]["POINTOFDEPARTURE"],
                                          style: const TextStyle(
                                              fontSize: 18,),
                                        ),
                                        Text('-'),
                                        Text(
                                          _filteredRoutesList[index]
                                          ["POINTOFDESTINATION"],
                                          style: const TextStyle(
                                              fontSize: 18,),
                                        ),
                                      ],
                                    ),
                                    Text('Время маршрута: ${_getDate(_filteredRoutesList[index]["ROUTE_TIME"])}')

                                  ],
                                ),
                              )),
                        ),
                      );
                    },
                  ),
                ],
              ),


            if(isRouteAdded)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ID маршрута',
                      ),
                      enabled: false,
                      onChanged: (value) {
                        _getTickets();
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: _timeRouteController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Время пути',
                      ),
                      enabled: false,
                      onChanged: (value) {
                        _getTickets();
                      },
                    ),
                  ),
                ],
              ),

            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _firstTimeController,
                onChanged: (value){
                  if(isDestinationTimeGot){
                    setState(() {
                      isDestinationTimeGot = false;
                      _secondDateController.text = '';
                      _secondTimeController.text = '';
                      isCheckDrivers = false;
                      _driverIdController.text = '';
                      isCheckBuses = false;
                      _busIdController.text = '';
                      _placesController.text = '';
                      _costController.text = '';
                      isAddedDriver = false;
                      isAddedBus = false;

                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Время отправления (00:00)',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9:]*$')),
                  LengthLimitingTextInputFormatter(5),
                ],
              ),
            ),

            if(_firstTimeController.text.length == 5 && !isDestinationTimeGot && _idController.text != '')
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () async{
                    String pattern = r'^((0[0-9]|1[0-9]|2[0-3])):((0[0-9]|[1-5][0-9]))?$';
                    RegExp regExp = new RegExp(pattern);

                    bool isValid = regExp.hasMatch(_firstTimeController.text);
                    if(isValid){
                      setState(() {
                        isDestinationTimeGot = true;
                        int days = _getDestinationTime();
                        String destinationDate = _getDestinationDate(_timeRouteController.text, days);
                        _secondDateController.text = destinationDate;
                      });
                    }
                    else{
                      _showDialog('Введите верное время', 'Ошибка');
                    }

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Получить время прибытия',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            if(isDestinationTimeGot)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _secondDateController,
                      decoration: InputDecoration(
                        labelText: 'Дата прибытия',
                        border: OutlineInputBorder(),
                      ),
                      enabled:false,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _secondTimeController,
                      decoration: InputDecoration(
                        labelText: 'Время прибытия',
                        border: OutlineInputBorder(),
                      ),
                      enabled:false,
                    ),
                  ),
                ],
              ),

            if(_secondTimeController.text != '')
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _costController,
                onChanged: (value){
                  if(_driverIdController.text != ''){
                    setState(() {
                      isCheckDrivers = false;
                      _driverIdController.text = '';
                      isCheckBuses = false;
                      _busIdController.text = '';
                      _placesController.text = '';
                      _costController.text = '';
                      isAddedDriver = false;
                      isAddedBus = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Цена',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9.]*$')),
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
            ),

            if(_costController.text != '' && !isCheckDrivers)
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () async{
                      String pattern = r'[0-9]';
                      String pattern1 = r'^\d{1,3}(\.\d{1,2})?$';
                      RegExp regExp = new RegExp(pattern);
                      RegExp regExp1 = new RegExp(pattern1);

                      bool isValid = regExp.hasMatch(_costController.text);
                      bool isValid1 = regExp1.hasMatch(_costController.text);

                      if(isValid && isValid1){
                        if((_costController.text.length == 1 && _costController.text == '0') || (_costController.text.length > 1 && (_costController.text[0] == "0" && _costController.text[1] != '.'))){
                          _showDialog('Введите верную цену. Либо просто число, либо число с точкой', 'Ошибка');
                        }
                        else{
                          await _getDrivers();
                          setState(() {
                            isCheckDrivers = true;
                            if(isAddedDriver){
                              isAddedDriver = false;
                              _driverIdController.text = '';
                            }
                          });
                        }

                      }
                      else{
                        _showDialog('Введите верную цену. Либо просто число, либо число с точкой', 'Ошибка');
                      }

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Выбрать водителя',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),


            if(isCheckDrivers && _costController.text != '')
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: _searchDriversController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Введите текст для фильтрации',
                      ),
                      onChanged: (value) {
                        _getDrivers();
                      },
                    ),
                  ),

                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredDriversList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async{
                          setState(() {
                            _driverIdController.text = _filteredDriversList[index]['USERID'].toString();
                            isCheckDrivers = false;
                            isAddedDriver = true;
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [

                                        Text(
                                          _filteredDriversList[index]["USERNAME"],
                                          style: const TextStyle(
                                            fontSize: 18,),
                                        ),
                                        Text(' '),
                                        Text(
                                          _filteredDriversList[index]
                                          ["USERLASTNAME"],
                                          style: const TextStyle(
                                            fontSize: 18,),
                                        ),
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
              ),

              if(isAddedDriver)
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _driverIdController,
                    decoration: InputDecoration(
                      labelText: 'ID водителя',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                  ),
                ),


            if(_driverIdController.text != '' && !isCheckBuses)
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () async{

                        setState(() {
                          isCheckBuses = true;
                          _getBuses();
                          if(isAddedBus){
                            isAddedBus = false;
                            _busIdController.text = '';
                            _placesController.text = '';
                          }
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
                      'Выбрать маршрутку',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),


            if(isCheckBuses)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: _searchBusesController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Введите текст для фильтрации',
                      ),
                      onChanged: (value) {
                        _getBuses();
                      },
                    ),
                  ),

                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredBusesList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async{
                          setState(() {
                            _busIdController.text = _filteredBusesList[index]['BUSID'].toString();
                            _placesController.text = _filteredBusesList[index]["COUNT_PLACES"].toString();
                            isCheckBuses = false;
                            isAddedBus = true;
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [

                                        Text('${_filteredBusesList[index]["BUSBRAND"]} (${_filteredBusesList[index]["BUSNUMBER"]})'
                                          ,
                                          style: const TextStyle(
                                            fontSize: 18,),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [

                                        Text('Количество мест: ${_filteredBusesList[index]["COUNT_PLACES"].toString()}'
                                          ,
                                          style: const TextStyle(
                                            fontSize: 18,),
                                        ),
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
              ),

            if(isAddedBus)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _busIdController,
                      decoration: InputDecoration(
                        labelText: 'ID маршрутки',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _placesController,
                      decoration: InputDecoration(
                        labelText: 'Количество мест',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                  ),
                ],
              ),


            if(_driverIdController.text != '' && _busIdController.text != '')
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () async{
                      DateTime departureDate = DateFormat('dd MMMM yyyy', 'ru_RU').parse(formattedDate);
                      DateTime destinationDate = DateFormat('dd MMMM yyyy', 'ru_RU').parse(_secondDateController.text);

                      String departureDateString = DateFormat('yyyy-MM-dd').format(departureDate);
                      String destinationDateString = DateFormat('yyyy-MM-dd').format(destinationDate);
                      Trip trip = Trip(departureDateString, destinationDateString, _firstTimeController.text, _secondTimeController.text, int.parse(_placesController.text), double.parse(_costController.text), int.parse(_idController.text), int.parse(_busIdController.text), int.parse(_driverIdController.text), 'AVAILABLE');
                      addTrip(trip);

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Добавить рейс',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),


            SizedBox(height: 10,),
            Text('Изменение', style: TextStyle(fontSize: 22),),
            Text('Изменять можно только рейсы, для которых ещё не заказаны билеты', textAlign: TextAlign.center),
            SizedBox(height: 10,),

            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () async{
                    _getTrips();

                    setState(() {
                      isTripsCheck = true;
                      if(isTripAdded){
                        isTripAdded = false;
                        _tripIdController.text = '';
                        _driverIdUpdateController.text = '';
                        isBusesUpdateCheck = false;
                        _busIdUpdateController.text = '';
                        isCostUpdateCheck = false;
                        _costUpdateController.text = '';
                        isAddedUpdateBus = false;
                        isAddedUpdateDriver = false;
                        isDriverUpdateCheck = false;
                      }
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
                    'Получить список рейсов',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),



            if(isTripsCheck)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: _searchUpdateController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Введите текст для фильтрации',
                      ),
                      onChanged: (value) {
                        _getTrips();
                      },
                    ),
                  ),
                  Container(
                    height: height * 0.4,

                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredTripsList.length,
                      itemBuilder: (context, index) {
                        double? dividerWith =
                        getDividerWidth(_getDate(_filteredTripsList[index]['ROUTE_TIME']));
                        String routeTime = _getDate(_filteredTripsList[index]['ROUTE_TIME'].toString());
                        return GestureDetector(
                          onTap: () async{
                            setState(() {
                              selectedTrip = Trip(_filteredTripsList[index]['DEPARTURE_DATE'], _filteredTripsList[index]['DESTINATION_DATE'], _filteredTripsList[index]['DEPARTURE_TIME'], _filteredTripsList[index]['DESTINATION_TIME'], _filteredTripsList[index]['COUNT_FREE_PLACES'], _filteredTripsList[index]['COST'], _filteredTripsList[index]['ROUTEID'], _filteredTripsList[index]['BUSID'], _filteredTripsList[index]['USERID'], _filteredTripsList[index]['STATUS']);
                              isTripsCheck = false;
                              _tripIdController.text = _filteredTripsList[index]['TRIPID'].toString();
                              isTripAdded = true;
                            });
                          },
                          child:  ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            title: Container(
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(226, 216, 246, 1.0),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_filteredTripsList[index]['DEPARTURE_DATE'], style: const TextStyle(fontWeight: FontWeight.w500),),
                                          Text(_filteredTripsList[index]['DESTINATION_DATE'], style: const TextStyle(fontWeight: FontWeight.w500),)
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_filteredTripsList[index]['DEPARTURE_TIME'], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),),
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
                                          Text(_filteredTripsList[index]['DESTINATION_TIME'], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),)
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_filteredTripsList[index]["DepartureCityName"],style: const TextStyle(fontSize: 20),),
                                          Text(_filteredTripsList[index]["DestinationCityName"], style: const TextStyle(fontSize: 20),)
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(_filteredTripsList[index]["COST"].toString() + " руб.", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),),
                                              Text(_filteredTripsList[index]["COUNT_FREE_PLACES"].toString() + ' свободных мест', style: TextStyle(color: Colors.green),),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Водитель: ${_filteredTripsList[index]["USERNAME"]} ${_filteredTripsList[index]["USERLASTNAME"]}',),
                                              Text('Бус: ${_filteredTripsList[index]["BUSBRAND"]} (${_filteredTripsList[index]["BUSNUMBER"]})'),
                                            ],
                                          ),
                                        ],
                                      ),


                                    ],
                                  ),
                                )
                            ),
                          ),
                        );
                      },
                    ),
                  )

                ],
              ),

              if(isTripAdded)
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: TextField(
                        controller: _tripIdController,
                        decoration: InputDecoration(
                          labelText: 'ID рейса',
                          border: OutlineInputBorder(),
                        ),
                        enabled: false,
                      ),
                    ),


                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: () async{
                            _getDriversUpdate();

                            setState(() {
                              isCostUpdateCheck = true;

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
                            'Изменить цену',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if(isCostUpdateCheck)
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: TextField(
                          controller: _costUpdateController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Новая цена',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^[0-9.]*$')),
                            LengthLimitingTextInputFormatter(6),
                          ],
                        ),
                      ),

                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: () async{
                            _getDriversUpdate();

                            setState(() {
                              isDriverUpdateCheck = true;
                              if(isAddedUpdateDriver){
                                isAddedUpdateDriver = false;
                                _tripIdController.text = '';
                              }
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
                            'Изменить водителя',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if(isDriverUpdateCheck)
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: TextField(
                              controller: _searchDriversUpdateController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Введите текст для фильтрации',
                              ),
                              onChanged: (value) {
                                _getDriversUpdate();
                              },
                            ),
                          ),

                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filteredDriversUpdateList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () async{
                                  setState(() {
                                    _driverIdUpdateController.text = _filteredDriversUpdateList[index]['USERID'].toString();
                                    isDriverUpdateCheck = false;
                                    isAddedUpdateDriver = true;
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [

                                                Text(
                                                  _filteredDriversUpdateList[index]["USERNAME"],
                                                  style: const TextStyle(
                                                    fontSize: 18,),
                                                ),
                                                Text(' '),
                                                Text(
                                                  _filteredDriversUpdateList[index]
                                                  ["USERLASTNAME"],
                                                  style: const TextStyle(
                                                    fontSize: 18,),
                                                ),
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
                      ),

                    if(isAddedUpdateDriver)
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextField(
                          controller: _driverIdUpdateController,
                          decoration: InputDecoration(
                            labelText: 'ID водителя',
                            border: OutlineInputBorder(),
                          ),
                          enabled: false,
                        ),
                      ),

                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: () async{
                            _getBusesUpdate();
                            setState(() {
                              isBusesUpdateCheck = true;

                              if(isAddedUpdateBus){
                                isAddedUpdateBus = false;
                                _busIdUpdateController.text = '';
                                _placesUpdateController.text = '';
                              }
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
                            'Изменить маршрутку',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),



                    if(isBusesUpdateCheck)
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: TextField(
                              controller: _searchBusesUpdateController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Введите текст для фильтрации',
                              ),
                              onChanged: (value) {
                                _getBusesUpdate();
                                setState(() {

                                });
                              },
                            ),
                          ),

                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filteredBusesUpdateList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () async{
                                  setState(() {
                                    _busIdUpdateController.text = _filteredBusesUpdateList[index]['BUSID'].toString();
                                    _placesUpdateController.text = _filteredBusesUpdateList[index]["COUNT_PLACES"].toString();
                                    isBusesUpdateCheck = false;
                                    isAddedUpdateBus = true;
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [

                                                Text('${_filteredBusesUpdateList[index]["BUSBRAND"]} (${_filteredBusesUpdateList[index]["BUSNUMBER"]})'
                                                  ,
                                                  style: const TextStyle(
                                                    fontSize: 18,),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [

                                                Text('Количество мест: ${_filteredBusesUpdateList[index]["COUNT_PLACES"].toString()}'
                                                  ,
                                                  style: const TextStyle(
                                                    fontSize: 18,),
                                                ),
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
                      ),

                    if(isAddedUpdateBus)
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: TextField(
                              controller: _busIdUpdateController,
                              decoration: InputDecoration(
                                labelText: 'ID маршрутки',
                                border: OutlineInputBorder(),
                              ),
                              enabled: false,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: TextField(
                              controller: _placesUpdateController,
                              decoration: InputDecoration(
                                labelText: 'Новое кол-во мест',
                                border: OutlineInputBorder(),
                              ),
                              enabled: false,
                            ),
                          ),
                        ],
                      ),

                      if(_costUpdateController.text != '' || _busIdUpdateController.text != '' || _driverIdUpdateController.text != '')
                        SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                              onPressed: () async{
                                _updateTrip();
                                setState(() {

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
                                'Подтвердить изменения',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
            SizedBox(height: 10,),
            Text('Удаление', style: TextStyle(fontSize: 22),),
            Text('Удалять можно только рейсы, для которых ещё не заказаны билеты', textAlign: TextAlign.center),
            SizedBox(height: 10,),

            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () async{
                    _getTripsDelete();

                    setState(() {
                      isTripsDeleteCheck = true;
                      if(isTripDeleteAdded){
                        isTripDeleteAdded = false;
                        _tripIdDeleteController.text = '';
                      }
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
                    'Получить список рейсов',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            if(isTripsDeleteCheck)
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _searchDeleteController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Введите текст для фильтрации',
                    ),
                    onChanged: (value) {
                      _getTrips();
                    },
                  ),
                ),
                Container(
                  height: height * 0.4,

                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredTripsDeleteList.length,
                    itemBuilder: (context, index) {
                      double? dividerWith =
                      getDividerWidth(_getDate(_filteredTripsDeleteList[index]['ROUTE_TIME']));
                      String routeTime = _getDate(_filteredTripsDeleteList[index]['ROUTE_TIME'].toString());
                      return GestureDetector(
                        onTap: () async{
                          setState(() {
                            isTripsDeleteCheck = false;
                            _tripIdDeleteController.text = _filteredTripsDeleteList[index]['TRIPID'].toString();
                            isTripDeleteAdded = true;
                          });
                        },
                        child:  ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          title: Container(
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(226, 216, 246, 1.0),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_filteredTripsDeleteList[index]['DEPARTURE_DATE'], style: const TextStyle(fontWeight: FontWeight.w500),),
                                        Text(_filteredTripsDeleteList[index]['DESTINATION_DATE'], style: const TextStyle(fontWeight: FontWeight.w500),)
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_filteredTripsDeleteList[index]['DEPARTURE_TIME'], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),),
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
                                        Text(_filteredTripsDeleteList[index]['DESTINATION_TIME'], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),)
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_filteredTripsDeleteList[index]["DepartureCityName"],style: const TextStyle(fontSize: 20),),
                                        Text(_filteredTripsDeleteList[index]["DestinationCityName"], style: const TextStyle(fontSize: 20),)
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(_filteredTripsDeleteList[index]["COST"].toString() + " руб.", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),),
                                            Text(_filteredTripsDeleteList[index]["COUNT_FREE_PLACES"].toString() + ' свободных мест', style: TextStyle(color: Colors.green),),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Водитель: ${_filteredTripsDeleteList[index]["USERNAME"]} ${_filteredTripsDeleteList[index]["USERLASTNAME"]}',),
                                            Text('Бус: ${_filteredTripsDeleteList[index]["BUSBRAND"]} (${_filteredTripsDeleteList[index]["BUSNUMBER"]})'),
                                          ],
                                        ),
                                      ],
                                    ),


                                  ],
                                ),
                              )
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),

            if(isTripDeleteAdded)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _tripIdDeleteController,
                      decoration: InputDecoration(
                        labelText: 'ID рейса',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () async{
                          deleteTrip();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          'Удалить',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )


          ],
        ),
      ),
    );
  }
}
