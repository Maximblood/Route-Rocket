import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kursovoy/Database/BusHandler.dart';
import 'package:kursovoy/Database/BusStopHandler.dart';
import 'package:kursovoy/Database/CityHandler.dart';
import 'package:kursovoy/Database/DatabaseNotifier.dart';
import 'package:kursovoy/Database/RouteHandler.dart';
import 'package:kursovoy/Database/TicketHandler.dart';
import 'package:kursovoy/Models/BusStop.dart';
import 'package:kursovoy/Models/City.dart';
import 'package:kursovoy/Models/Route.dart' as Rroute;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


class RouteAdminPage extends StatefulWidget {
  final DatabaseNotifier databaseNotifier;

  RouteAdminPage({required this.databaseNotifier});

  @override
  _RouteAdminPageState createState() => _RouteAdminPageState();
}

class _RouteAdminPageState extends State<RouteAdminPage> {
  TextEditingController _departureBusStopcontroller = TextEditingController();
  TextEditingController _destinationStopcontroller = TextEditingController();

  TextEditingController _firstBusStopcontroller = TextEditingController();
  TextEditingController _secondBusStopcontroller = TextEditingController();
  TextEditingController _thirdBusStopcontroller = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _idDepartureController = TextEditingController();
  TextEditingController _nameDepartureController = TextEditingController();
  TextEditingController _idDestinationController = TextEditingController();
  TextEditingController _nameDestinationController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  TextEditingController _nameDepartureUpdateController = TextEditingController();
  TextEditingController _nameDestinationUpdateController = TextEditingController();
  TextEditingController _timeUpdateController = TextEditingController();
  TextEditingController _idDestinationUpdateController = TextEditingController();
  TextEditingController _idDepartureUpdateController = TextEditingController();
  TextEditingController _idUpdateController = TextEditingController();
  TextEditingController _timeUpdatedController = TextEditingController();

  TextEditingController _nameDepartureDeleteController = TextEditingController();
  TextEditingController _nameDestinationDeleteController = TextEditingController();
  TextEditingController _timeDeleteController = TextEditingController();
  TextEditingController _idDestinationDeleteController = TextEditingController();
  TextEditingController _idDepartureDeleteController = TextEditingController();
  TextEditingController _idDeleteController = TextEditingController();


  List<Map<String, dynamic>> _citiesFirstBusStop = [];
  List<Map<String, dynamic>> _citiesSecondBusStop = [];
  List<Map<String, dynamic>> _citiesThirdBusStop = [];
  List<City> _citiesDelete = [];
  List<Route> _routesSearch = [];
  List<Map<String, dynamic>> _cities = [];
  bool _showList = false;
  bool _firstFlag = false;
  bool _secondFlag = false;
  bool _thirdFlag = false;

  TextEditingController _controller = TextEditingController();


  bool _showListFirstBusStop = false;
  bool _showListSecondBusStop = false;
  bool _showListThirdBusStop = false;

  bool _showListDeparture = false;
  bool _showListDestination = false;

  bool _showListDepartureUpdate = false;
  bool _showListDestinationUpdate = false;

  bool _showListDepartureDelete = false;
  bool _showListDestinationDelete = false;


  bool firstBusStopAdded = false;
  bool secondBusStopAdded = false;
  bool thirdBusStopAdded = false;



  void _searchCities(String query) async {
    final username = 'blood';
    final url =
        'http://api.geonames.org/searchJSON?name_startsWith=$query&username=$username';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _cities = (data['geonames'] as List)
            .map((city) => {
          'name': city['name'],
          'region': city['adminName1'],
          'country': city['countryName'],
        })
            .toList();
      });
    } else {
      throw Exception('Failed to load cities');
    }
  }

  void _selectCity(Map<String, dynamic> city, int flag) {
    _cityController.text = city['name'];
    _locationController.text = '${city['region']}, ${city['country']}';
    setState(() {
      _showList = false;
      if(flag == 1){
        _firstBusStopcontroller.text = '${city['name']} (${city['region']}, ${city['country']})';
        _firstFlag = true;
      }
      else if (flag == 2){
        _secondBusStopcontroller.text = '${city['name']} (${city['region']}, ${city['country']})';
        _secondFlag = true;
      }
      else{
        _thirdBusStopcontroller.text = '${city['name']} (${city['region']}, ${city['country']})';
        _thirdFlag = true;
      }
    });
  }



  void _addRoute() async{
    String pattern = r'^([0-9]{2} д )((0[0-9]|1[0-9]|2[0-3]) ч )((0[0-9]|[1-5][0-9]) м)?$';
    String pattern1 = r'^([0-9]{2} d )?((0[0-9]|1[0-9]|2[0-3]) h )?((0[0-9]|[1-5][0-9]) m)?$';

    RegExp regExp = new RegExp(pattern);
    RegExp regExp1 = new RegExp(pattern1);

    bool isValid = regExp.hasMatch(_timeController.text);
    bool isValid1 = regExp1.hasMatch(_timeController.text);

    print(isValid);
    print(isValid1);

    if(_idDestinationController.text == '' || _idDepartureController.text == ''){
      _showDialog('Выберите город отправления и город прибытия', "Ошибка");
    }
    else{
        if(_timeController.text != ''){
          if(_timeController.text == '00 d 00 h 00 m' || _timeController.text == '00 д 00 ч 00 м'){
            isValid = false;
            isValid1 = false;
            _showDialog("Введите верное время", 'Ошибка');
          }
          else{
            if(isValid || isValid1){

              String timeResult = _timeController.text
                  .replaceAll('d', 'д')
                  .replaceAll('h', 'ч')
                  .replaceAll('m', 'м');



              if(thirdBusStopAdded){
                if(!_thirdFlag){
                  _showDialog('Укажите четвертую остановку', 'Ошибка');
                }
                else{
                  final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
                  Rroute.Route route = Rroute.Route(int.parse(_idDepartureController.text), int.parse(_idDestinationController.text), timeResult);
                  int count = await RouteHandler(dbHelper.db).getRouteCount(route);
                  if(_firstBusStopcontroller.text != _nameDepartureController.text && _firstBusStopcontroller.text != _nameDestinationController.text && _secondBusStopcontroller.text != _nameDepartureController.text && _secondBusStopcontroller.text != _nameDestinationController.text && _secondBusStopcontroller.text != _firstBusStopcontroller.text && _thirdBusStopcontroller.text != _nameDepartureController.text && _thirdBusStopcontroller.text != _nameDestinationController.text && _thirdBusStopcontroller.text != _firstBusStopcontroller.text && _thirdBusStopcontroller.text != _secondBusStopcontroller.text){
                    if(count == 0){
                      await RouteHandler(dbHelper.db).insert(route);
                      int routeId = await RouteHandler(dbHelper.db).getRouteId(route);
                      await BusStopHandler(dbHelper.db).insert(BusStop(_nameDepartureController.text, routeId, 1));
                      await BusStopHandler(dbHelper.db).insert(BusStop(_firstBusStopcontroller.text, routeId, 2));
                      await BusStopHandler(dbHelper.db).insert(BusStop(_secondBusStopcontroller.text, routeId, 3));
                      await BusStopHandler(dbHelper.db).insert(BusStop(_thirdBusStopcontroller.text, routeId, 4));
                      await BusStopHandler(dbHelper.db).insert(BusStop(_nameDestinationController.text, routeId, 5));
                      _showDialog('Успешно добавлено', 'Успех');
                      setState(() {
                        _departureBusStopcontroller.text = '';
                        _destinationStopcontroller.text = '';
                        firstBusStopAdded = false;
                        secondBusStopAdded = false;
                        thirdBusStopAdded = false;
                        _nameDepartureController.text = '';
                        _nameDestinationController.text = '';
                        _idDepartureController.text = '';
                        _idDestinationController.text = '';
                        _timeController.text = '';
                        _firstBusStopcontroller.text = '';
                        _secondBusStopcontroller.text = '';
                        _thirdBusStopcontroller.text = '';
                      });
                    }
                    else{
                      _showDialog('Такой маршрут уже существует', 'Ошибка');
                    }
                  }
                  else{
                    _showDialog('Остановка не может совпадать с городом отправления, прибытия и с другой остановкой', 'Ошибка');
                  }
                }
              }
              else if(secondBusStopAdded){
                if(!_secondFlag){
                  _showDialog('Укажите третью остановку', 'Ошибка');
                }
                else{
                  final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
                  Rroute.Route route = Rroute.Route(int.parse(_idDepartureController.text), int.parse(_idDestinationController.text), timeResult);
                  int count = await RouteHandler(dbHelper.db).getRouteCount(route);
                  if(_firstBusStopcontroller.text != _nameDepartureController.text && _firstBusStopcontroller.text != _nameDestinationController.text && _secondBusStopcontroller.text != _nameDepartureController.text && _secondBusStopcontroller.text != _nameDestinationController.text && _secondBusStopcontroller.text != _firstBusStopcontroller.text){
                    if(count == 0){
                      await RouteHandler(dbHelper.db).insert(route);
                      int routeId = await RouteHandler(dbHelper.db).getRouteId(route);
                      await BusStopHandler(dbHelper.db).insert(BusStop(_nameDepartureController.text, routeId, 1));
                      await BusStopHandler(dbHelper.db).insert(BusStop(_firstBusStopcontroller.text, routeId, 2));
                      await BusStopHandler(dbHelper.db).insert(BusStop(_secondBusStopcontroller.text, routeId, 3));
                      await BusStopHandler(dbHelper.db).insert(BusStop(_nameDestinationController.text, routeId, 4));
                      _showDialog('Успешно добавлено', 'Успех');
                      setState(() {
                        _departureBusStopcontroller.text = '';
                        _destinationStopcontroller.text = '';
                        firstBusStopAdded = false;
                        secondBusStopAdded = false;
                        _nameDepartureController.text = '';
                        _nameDestinationController.text = '';
                        _idDepartureController.text = '';
                        _idDestinationController.text = '';
                        _timeController.text = '';
                        _firstBusStopcontroller.text = '';
                        _secondBusStopcontroller.text = '';
                      });
                    }
                    else{
                      _showDialog('Такой маршрут уже существует', 'Ошибка');
                    }
                  }
                  else{
                    _showDialog('Остановка не может совпадать с городом отправления, прибытия и с другой остановкой', 'Ошибка');
                  }
                }
              }
              else if(firstBusStopAdded){
                if(!_firstFlag){
                  _showDialog('Укажите вторую остановку', 'Ошибка');
                }
                else{
                  final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
                  Rroute.Route route = Rroute.Route(int.parse(_idDepartureController.text), int.parse(_idDestinationController.text), timeResult);
                  int count = await RouteHandler(dbHelper.db).getRouteCount(route);
                  if(_firstBusStopcontroller.text != _nameDepartureController.text && _firstBusStopcontroller.text != _nameDestinationController.text){
                    if(count == 0){
                      await RouteHandler(dbHelper.db).insert(route);
                      int routeId = await RouteHandler(dbHelper.db).getRouteId(route);
                      await BusStopHandler(dbHelper.db).insert(BusStop(_nameDepartureController.text, routeId, 1));
                      await BusStopHandler(dbHelper.db).insert(BusStop(_firstBusStopcontroller.text, routeId, 2));
                      await BusStopHandler(dbHelper.db).insert(BusStop(_nameDestinationController.text, routeId, 3));
                      _showDialog('Успешно добавлено', 'Успех');
                      setState(() {
                        _departureBusStopcontroller.text = '';
                        _destinationStopcontroller.text = '';
                        firstBusStopAdded = false;
                        _nameDepartureController.text = '';
                        _nameDestinationController.text = '';
                        _idDepartureController.text = '';
                        _idDestinationController.text = '';
                        _timeController.text = '';
                        _firstBusStopcontroller.text = '';
                      });


                    }
                    else{
                      _showDialog('Такой маршрут уже существует', 'Ошибка');
                    }
                  }
                  else{
                    _showDialog('Остановка не может совпадать с городом отправления и прибытия', 'Ошибка');
                  }
                }
              }
              else{
                final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
                Rroute.Route route = Rroute.Route(int.parse(_idDepartureController.text), int.parse(_idDestinationController.text), timeResult);
                int count = await RouteHandler(dbHelper.db).getRouteCount(route);
                if(count == 0){
                  await RouteHandler(dbHelper.db).insert(route);
                  int routeId = await RouteHandler(dbHelper.db).getRouteId(route);
                  await BusStopHandler(dbHelper.db).insert(BusStop(_nameDepartureController.text, routeId, 1));
                  await BusStopHandler(dbHelper.db).insert(BusStop(_firstBusStopcontroller.text, routeId, 2));
                  await BusStopHandler(dbHelper.db).insert(BusStop(_nameDestinationController.text, routeId, 3));
                  _showDialog('Успешно добавлено', 'Успех');
                  setState(() {
                    _departureBusStopcontroller.text = '';
                    _destinationStopcontroller.text = '';
                    _nameDepartureController.text = '';
                    _nameDestinationController.text = '';
                    _idDepartureController.text = '';
                    _idDestinationController.text = '';
                    _timeController.text = '';
                  });


                }
                else{
                  _showDialog('Такой маршрут уже существует', 'Ошибка');
                }
              }

            }
            else{
              _showDialog("Введите правильное время в формате 00 d 00 h 00 m или 00 д 00 ч 00 м", 'Ошибка');
            }
          }
        }
        else{
          _showDialog("Введите время маршрута", 'Ошибка');
        }

    }


  }



  void _selectDirectionCity(City city, String direction) {
    if(direction == 'departure'){
      setState(() {
        _nameDepartureController.text = city.cityName;
        _departureBusStopcontroller.text = '${city.cityName} (${city.location})';
        _idDepartureController.text = city.id.toString();
        _showListDeparture = false;
      });
    }
    else if(direction == 'destination'){
      setState(() {
        _nameDestinationController.text = city.cityName;
        _destinationStopcontroller.text = '${city.cityName} (${city.location})';
        _idDestinationController.text = city.id.toString();
        _showListDestination = false;
      });
    }
    else if(direction == 'departureUpdate'){
      setState(() {
        _nameDepartureUpdateController.text = city.cityName;
        _idDepartureUpdateController.text = city.id.toString();
        _showListDepartureUpdate = false;
      });
    }
    else if(direction == 'destinationUpdate'){
      setState(() {
        _nameDestinationUpdateController.text = city.cityName;
        _idDestinationUpdateController.text = city.id.toString();
        _showListDestinationUpdate = false;
      });
    }
    else if(direction == 'departureDelete'){
      setState(() {
        _nameDepartureDeleteController.text = city.cityName;
        _idDepartureDeleteController.text = city.id.toString();
        _showListDepartureDelete = false;
      });
    }
    else if(direction == 'destinationDelete'){
      setState(() {
        _nameDestinationDeleteController.text = city.cityName;
        _idDestinationDeleteController.text = city.id.toString();
        _showListDestinationDelete = false;
      });
    }
  }



  void _searchAllCities(String selectedCity, String searchText) async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    _citiesDelete = await CityHandler(dbHelper.db).getAllCities(selectedCity,searchText);
  }

   void updateRoute() async{
     String pattern = r'^([0-9]{2} д )((0[0-9]|1[0-9]|2[0-3]) ч )((0[0-9]|[1-5][0-9]) м)?$';
     String pattern1 = r'^([0-9]{2} d )?((0[0-9]|1[0-9]|2[0-3]) h )?((0[0-9]|[1-5][0-9]) m)?$';

     RegExp regExp = new RegExp(pattern);
     RegExp regExp1 = new RegExp(pattern1);

     bool isValid = regExp.hasMatch(_timeUpdatedController.text);
     bool isValid1 = regExp1.hasMatch(_timeUpdatedController.text);

     String timeResult = "";
     if(isValid){
       timeResult = _timeUpdatedController.text;
       final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
       Rroute.Route route = Rroute.Route(int.parse(_idDepartureUpdateController.text), int.parse(_idDestinationUpdateController.text), timeResult);
       int count = await RouteHandler(dbHelper.db).getRouteCount(route);
       if(count == 0){
         int count = await RouteHandler(dbHelper.db).getRouteCountTrips(int.parse(_idDeleteController.text));
         if(count == 0){
           await RouteHandler(dbHelper.db).update(route, int.parse(_idUpdateController.text));
           _showDialog('Успешно измененно', 'Успех');
           setState(() {
             _nameDepartureUpdateController.text = '';
             _idDepartureUpdateController.text = '';
             _nameDestinationUpdateController.text = '';
             _idDestinationUpdateController.text = '';
             _timeUpdateController.text = '';
             _idUpdateController.text = '';
             _timeUpdatedController.text = '';
           });         }
         else{
           _showDialog('Данный маршрут уже прикреплен к рейсу', 'Ошибка');
         }

       }
       else{
         _showDialog("Данный маршрут уже существует", "Ошибка");
       }


     }
     else if(isValid1){
       timeResult = _timeUpdatedController.text
           .replaceAll('d', 'д')
           .replaceAll('h', 'ч')
           .replaceAll('m', 'м');

       final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
       Rroute.Route route = Rroute.Route(int.parse(_idDepartureUpdateController.text), int.parse(_idDestinationUpdateController.text), timeResult);
       int count = await RouteHandler(dbHelper.db).getRouteCount(route);
       if(count == 0){
         final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
         int count = await RouteHandler(dbHelper.db).getRouteCountTrips(int.parse(_idUpdateController.text));
         if(count == 0){
           await RouteHandler(dbHelper.db).update(route, int.parse(_idUpdateController.text));
           _showDialog('Успешно измененно', 'Успех');
           setState(() {
             _nameDepartureUpdateController.text = '';
             _idDepartureUpdateController.text = '';
             _nameDestinationUpdateController.text = '';
             _idDestinationUpdateController.text = '';
             _timeUpdateController.text = '';
             _idUpdateController.text = '';
             _timeUpdatedController.text = '';
           });         }
         else{
           _showDialog('Данный маршрут уже прикреплен к рейсу', 'Ошибка');
         }


       }
       else{
         _showDialog("Данный маршрут уже существует", "Ошибка");
       }
     }
     else{
       _showDialog('Введите время в верном формате', 'Ошибка');
     }
   }

   void deleteRoute() async{
     final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
     int count = await RouteHandler(dbHelper.db).getRouteCountTrips(int.parse(_idDeleteController.text));
      if(count == 0){
        await RouteHandler(dbHelper.db).delete(int.parse(_idDeleteController.text));
        _showDialog('Успешно удалено', 'Успех');
        _nameDepartureDeleteController.text = '';
        _idDeleteController.text = '';
        _idDepartureDeleteController.text = '';
        _idDestinationDeleteController.text = '';
        _timeDeleteController.text = '';
        _nameDestinationDeleteController.text = '';
      }
      else{
        _showDialog('Данный маршрут уже прикреплен к рейсу', 'Ошибка');
      }

   }


  void _searchIdRoute() async {
    String pattern = r'^([0-9]{2} д )((0[0-9]|1[0-9]|2[0-3]) ч )((0[0-9]|[1-5][0-9]) м)?$';
    String pattern1 = r'^([0-9]{2} d )?((0[0-9]|1[0-9]|2[0-3]) h )?((0[0-9]|[1-5][0-9]) m)?$';

    RegExp regExp = new RegExp(pattern);
    RegExp regExp1 = new RegExp(pattern1);

    bool isValid = regExp.hasMatch(_timeUpdateController.text);
    bool isValid1 = regExp1.hasMatch(_timeUpdateController.text);

    String timeResult = "";
    if(isValid){
      timeResult = _timeUpdateController.text;
      final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
      Rroute.Route route = Rroute.Route(int.parse(_idDepartureUpdateController.text), int.parse(_idDestinationUpdateController.text), timeResult);
      int routeID = await RouteHandler(dbHelper.db).getRouteId(route);
      setState(() {
        _idUpdateController.text = routeID.toString();
      });
      if(routeID == 0){
        setState(() {
          _timeUpdatedController.text = '';
        });
      }
    }
    else if(isValid1){
      timeResult = _timeUpdateController.text
          .replaceAll('d', 'д')
          .replaceAll('h', 'ч')
          .replaceAll('m', 'м');

      final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
      Rroute.Route route = Rroute.Route(int.parse(_idDepartureUpdateController.text), int.parse(_idDestinationUpdateController.text), timeResult);
      int routeID = await RouteHandler(dbHelper.db).getRouteId(route);
      setState(() {
        _idUpdateController.text = routeID.toString();
      });
      if(routeID == 0){
        setState(() {
          _timeUpdatedController.text = '';
        });
      }
    }
    else{
      _showDialog('Введите время в верном формате', 'Ошибка');
    }
  }



  void _searchIdRouteDelete() async {
    String pattern = r'^([0-9]{2} д )((0[0-9]|1[0-9]|2[0-3]) ч )((0[0-9]|[1-5][0-9]) м)?$';
    String pattern1 = r'^([0-9]{2} d )?((0[0-9]|1[0-9]|2[0-3]) h )?((0[0-9]|[1-5][0-9]) m)?$';

    RegExp regExp = new RegExp(pattern);
    RegExp regExp1 = new RegExp(pattern1);

    bool isValid = regExp.hasMatch(_timeDeleteController.text);
    bool isValid1 = regExp1.hasMatch(_timeDeleteController.text);

    String timeResult = "";
    if(isValid){
      timeResult = _timeDeleteController.text;
      final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
      Rroute.Route route = Rroute.Route(int.parse(_idDepartureDeleteController.text), int.parse(_idDestinationDeleteController.text), timeResult);
      int routeID = await RouteHandler(dbHelper.db).getRouteId(route);
      setState(() {
        _idDeleteController.text = routeID.toString();
      });
      if(routeID == 0){
        setState(() {
          _timeDeleteController.text = '';
        });
      }
    }
    else if(isValid1){
      timeResult = _timeDeleteController.text
          .replaceAll('d', 'д')
          .replaceAll('h', 'ч')
          .replaceAll('m', 'м');

      final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
      Rroute.Route route = Rroute.Route(int.parse(_idDepartureDeleteController.text), int.parse(_idDestinationDeleteController.text), timeResult);
      int routeID = await RouteHandler(dbHelper.db).getRouteId(route);
      setState(() {
        _idDeleteController.text = routeID.toString();
      });
    }
    else{
      _showDialog('Введите время в верном формате', 'Ошибка');
    }
  }







  @override
  void initState() {
    super.initState();
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
        title: Text('Управление маршрутами'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 10,),
            Text('Добавление', style: TextStyle(fontSize: 22),),
            SizedBox(height: 10,),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _nameDepartureController,
                onChanged: (value){
                  if (value.length >= 3) {
                    setState(() {
                      _showListDeparture = true;
                    });
                    _searchAllCities(_nameDestinationController.text,value);
                  } else {
                    setState(() {
                      _citiesDelete = [];
                      _showListDeparture = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Город отправления',
                  border: OutlineInputBorder(),
                ),

              ),
            ),

            if (_showListDeparture)
              Container(
                height: height * 0.2,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _citiesDelete.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _selectDirectionCity(_citiesDelete[index], 'departure');
                            },
                            child: ListTile(
                              title: Text(_citiesDelete[index].cityName ?? ''),
                              subtitle: Text(
                                '${_citiesDelete[index].location}',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _idDepartureController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'ID города отправления',
                  border: OutlineInputBorder(),
                ),

              ),
            ),






            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _nameDestinationController,
                onChanged: (value){
                  if (value.length >= 3) {
                    setState(() {
                      _showListDestination = true;
                    });
                    _searchAllCities(_nameDepartureController.text,value);
                  } else {
                    setState(() {
                      _citiesDelete = [];
                      _showListDestination = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Город прибытия',
                  border: OutlineInputBorder(),
                ),

              ),
            ),

            if (_showListDestination)
              Container(
                height: height * 0.2,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _citiesDelete.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _selectDirectionCity(_citiesDelete[index], 'destination');
                            },
                            child: ListTile(
                              title: Text(_citiesDelete[index].cityName ?? ''),
                              subtitle: Text(
                                '${_citiesDelete[index].location}',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _idDestinationController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'ID города прибытия',
                  border: OutlineInputBorder(),
                ),

              ),
            ),



            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: 'Время поездки (Например 00 д 00 ч 01 м)',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(14),
                  ],
                  maxLength: 14
              ),
            ),



            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                  controller: _departureBusStopcontroller,
                  decoration: InputDecoration(
                    labelText: 'Первая остановка',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
              ),
            ),



            if(!firstBusStopAdded)
              TextButton(
                onPressed: () {
                  setState(() {
                    firstBusStopAdded = true;
                  });
                },
                child: Text(
                  'Добавить остановку',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),



            if(firstBusStopAdded)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _firstBusStopcontroller,
                      onChanged: (value) {
                        if (value.length >= 3) {
                          _searchCities(value);
                          setState(() {
                            _showListFirstBusStop = true;
                          });
                        } else {
                          setState(() {
                            _cities = [];
                            _showListFirstBusStop = false;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Вторая остановка',
                        border: OutlineInputBorder(),
                        suffixIcon: !secondBusStopAdded ? IconButton(
                          onPressed: () {
                            setState(() {
                              firstBusStopAdded = false;
                              _firstBusStopcontroller.text = '';
                            });
                          },
                          icon: Icon(Icons.clear),
                        ) : null,
                      ),
                    ),
                  ),
                  if (_showListFirstBusStop)
                    Container(
                      height: height * 0.4,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _cities.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    _selectCity(_cities[index], 1);
                                    setState(() {
                                      _showListFirstBusStop = _showList;
                                    });
                                  },
                                  child: ListTile(
                                    title: Text(_cities[index]['name'] ?? ''),
                                    subtitle: Text(
                                      '${_cities[index]['region']}, ${_cities[index]['country']}',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  if(!secondBusStopAdded && _firstFlag)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          secondBusStopAdded = true;
                        });
                      },
                      child: Text(
                        'Добавить остановку',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),



            if(secondBusStopAdded)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _secondBusStopcontroller,
                      onChanged: (value) {
                        if (value.length >= 3) {
                          _searchCities(value);
                          setState(() {
                            _showListSecondBusStop = true;
                          });
                        } else {
                          setState(() {
                            _cities = [];
                            _showListSecondBusStop = false;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Третья остановка',
                        border: OutlineInputBorder(),
                        suffixIcon: !thirdBusStopAdded ? IconButton(
                          onPressed: () {
                            setState(() {
                              secondBusStopAdded = false;
                              _secondBusStopcontroller.text = '';
                            });
                          },
                          icon: Icon(Icons.clear),
                        ) : null,
                      ),
                    ),
                  ),
                  if (_showListSecondBusStop)
                    Container(
                      height: height * 0.4,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _cities.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    _selectCity(_cities[index], 2);
                                    setState(() {
                                      _showListSecondBusStop = _showList;
                                    });
                                  },
                                  child: ListTile(
                                    title: Text(_cities[index]['name'] ?? ''),
                                    subtitle: Text(
                                      '${_cities[index]['region']}, ${_cities[index]['country']}',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  if(!thirdBusStopAdded && _secondFlag)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          thirdBusStopAdded = true;
                        });
                      },
                      child: Text(
                        'Добавить остановку',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),








            if(thirdBusStopAdded)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _thirdBusStopcontroller,
                      onChanged: (value) {
                        if (value.length >= 3) {
                          setState(() {
                            _showListThirdBusStop = true;
                            _searchCities(value);
                          });
                        } else {
                          setState(() {
                            _cities = [];
                            _showListThirdBusStop = false;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Четвертая остановка',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              thirdBusStopAdded = false;
                              _thirdBusStopcontroller.text = '';
                            });
                          },
                          icon: Icon(Icons.clear),
                        ),
                      ),
                    ),
                  ),
                  if (_showListThirdBusStop)
                    Container(
                      height: height * 0.4,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _cities.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    _selectCity(_cities[index], 3);
                                    setState(() {
                                      _showListThirdBusStop = _showList;
                                    });
                                  },
                                  child: ListTile(
                                    title: Text(_cities[index]['name'] ?? ''),
                                    subtitle: Text(
                                      '${_cities[index]['region']}, ${_cities[index]['country']}',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),




            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _destinationStopcontroller,
                decoration: InputDecoration(
                  labelText: 'Последняя остановка',
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
                  onPressed: () {

                    _addRoute();

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


            SizedBox(height: 10,),
            Text('Изменение', style: TextStyle(fontSize: 22),),
            SizedBox(height: 10,),


            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _nameDepartureUpdateController,
                onChanged: (value){
                  if (value.length >= 3) {
                    setState(() {
                      _showListDepartureUpdate = true;
                    });
                    _searchAllCities(_nameDestinationUpdateController.text,value);
                  } else {
                    setState(() {
                      _citiesDelete = [];
                      _showListDepartureUpdate = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Город отправления',
                  border: OutlineInputBorder(),
                ),

              ),
            ),

            if (_showListDepartureUpdate)
              Container(
                height: height * 0.2,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _citiesDelete.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _selectDirectionCity(_citiesDelete[index], 'departureUpdate');
                            },
                            child: ListTile(
                              title: Text(_citiesDelete[index].cityName ?? ''),
                              subtitle: Text(
                                '${_citiesDelete[index].location}',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _idDepartureUpdateController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'ID города отправления',
                  border: OutlineInputBorder(),
                ),

              ),
            ),






            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _nameDestinationUpdateController,
                onChanged: (value){
                  if (value.length >= 3) {
                    setState(() {
                      _showListDestinationUpdate = true;
                    });
                    _searchAllCities(_nameDepartureUpdateController.text,value);
                  } else {
                    setState(() {
                      _citiesDelete = [];
                      _showListDestinationUpdate = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Город прибытия',
                  border: OutlineInputBorder(),
                ),

              ),
            ),

            if (_showListDestinationUpdate)
              Container(
                height: height * 0.2,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _citiesDelete.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _selectDirectionCity(_citiesDelete[index], 'destinationUpdate');
                            },
                            child: ListTile(
                              title: Text(_citiesDelete[index].cityName ?? ''),
                              subtitle: Text(
                                '${_citiesDelete[index].location}',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _idDestinationUpdateController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'ID города прибытия',
                  border: OutlineInputBorder(),
                ),

              ),
            ),



            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                  controller: _timeUpdateController,
                  decoration: InputDecoration(
                    labelText: 'Время поездки (Например 00 д 00 ч 01 м)',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(14),
                  ],
                  maxLength: 14
              ),
            ),


            if(_idDepartureUpdateController.text != '' && _idDestinationUpdateController.text != '' && _timeUpdateController.text != '')
              Container(
                height: height * 0.2,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ElevatedButton(
                            onPressed: () {

                              _searchIdRoute();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text(
                              'Получить ID',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextField(
                            controller: _idUpdateController,
                            decoration: InputDecoration(
                              labelText: 'Id маршрута',
                              border: OutlineInputBorder(),
                            ),
                           enabled: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),


            if(_idUpdateController.text != '0' && _idUpdateController.text != '')
              Padding(
                padding: EdgeInsets.all(10.0),
                child: TextField(
                    controller: _timeUpdatedController,
                    decoration: InputDecoration(
                      labelText: 'Новое время (Например 00 д 00 ч 01 м)',
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(14),
                    ],
                    maxLength: 14
                ),
              ),

            if(_timeUpdatedController.text.length == 14)
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      updateRoute();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Изменить времени для маршрута',
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
            Text('Удаление', style: TextStyle(fontSize: 22),),
            SizedBox(height: 10,),

            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _nameDepartureDeleteController,
                onChanged: (value){
                  if (value.length >= 3) {
                    setState(() {
                      _showListDepartureDelete = true;
                    });
                    _searchAllCities(_nameDestinationDeleteController.text,value);
                  } else {
                    setState(() {
                      _citiesDelete = [];
                      _showListDepartureDelete = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Город отправления',
                  border: OutlineInputBorder(),
                ),

              ),
            ),

            if (_showListDepartureDelete)
              Container(
                height: height * 0.2,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _citiesDelete.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _selectDirectionCity(_citiesDelete[index], 'departureDelete');
                            },
                            child: ListTile(
                              title: Text(_citiesDelete[index].cityName ?? ''),
                              subtitle: Text(
                                '${_citiesDelete[index].location}',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _idDepartureDeleteController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'ID города отправления',
                  border: OutlineInputBorder(),
                ),

              ),
            ),






            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _nameDestinationDeleteController,
                onChanged: (value){
                  if (value.length >= 3) {
                    setState(() {
                      _showListDestinationDelete = true;
                    });
                    _searchAllCities(_nameDepartureDeleteController.text,value);
                  } else {
                    setState(() {
                      _citiesDelete = [];
                      _showListDestinationDelete = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Город прибытия',
                  border: OutlineInputBorder(),
                ),

              ),
            ),

            if (_showListDestinationDelete)
              Container(
                height: height * 0.2,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _citiesDelete.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _selectDirectionCity(_citiesDelete[index], 'destinationDelete');
                            },
                            child: ListTile(
                              title: Text(_citiesDelete[index].cityName ?? ''),
                              subtitle: Text(
                                '${_citiesDelete[index].location}',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _idDestinationDeleteController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'ID города прибытия',
                  border: OutlineInputBorder(),
                ),

              ),
            ),



            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                  controller: _timeDeleteController,
                  decoration: InputDecoration(
                    labelText: 'Время поездки (Например 00 д 00 ч 01 м)',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(14),
                  ],
                  maxLength: 14
              ),
            ),


            if(_idDepartureDeleteController.text != '' && _idDestinationDeleteController.text != '' && _timeDeleteController.text != '')
              Container(
                height: height * 0.2,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ElevatedButton(
                            onPressed: () {

                              _searchIdRouteDelete();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text(
                              'Получить ID',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextField(
                          controller: _idDeleteController,
                          decoration: InputDecoration(
                            labelText: 'Id маршрута',
                            border: OutlineInputBorder(),
                          ),
                          enabled: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if(_idDeleteController.text != '' && _idDeleteController.text != "0")
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      deleteRoute();
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
        ),
      ),
    );
  }
}







