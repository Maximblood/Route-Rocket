import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kursovoy/Database/CityHandler.dart';
import 'package:kursovoy/Database/DatabaseNotifier.dart';
import 'package:kursovoy/Database/TicketHandler.dart';
import 'package:kursovoy/Models/City.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


class CityAdminPage extends StatefulWidget {
  final DatabaseNotifier databaseNotifier;

  CityAdminPage({required this.databaseNotifier});

  @override
  _CityAdminPageState createState() => _CityAdminPageState();
}

class _CityAdminPageState extends State<CityAdminPage> {
  TextEditingController _controller = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _nameDeleteController = TextEditingController();
  List<Map<String, dynamic>> _cities = [];
  List<City> _citiesDelete = [];

  bool _showList = false;
  bool _showListDelete = false;



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

  void _selectCity(Map<String, dynamic> city) {
    _cityController.text = city['name'];
    _locationController.text = '${city['region']}, ${city['country']}';
    setState(() {
      _showList = false;
    });
  }


  void _selectDeleteCity(City city) {
    _idController.text = city.id.toString();
    setState(() {
      _showListDelete = false;
    });
  }
  
  void _addCity(String cityName, String location) async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    int count = await CityHandler(dbHelper.db).getCityCount(cityName, location);
    if(count > 0){
      _showDialog('Данный город уже существует в Базе данных', 'Ошибка');
    }
    else{
      await CityHandler(dbHelper.db).insert(City(cityName, location));
      _showDialog('Город успешно добавлен', 'Успех');
      _controller.text = '';
      _locationController.text = '';
      _cityController.text = '';
    }
  }

  void _searchAllCities(String searchText) async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    _citiesDelete = await CityHandler(dbHelper.db).getAllCities('',searchText);
  }


  void _deleteCity(int id) async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    int count = await CityHandler(dbHelper.db).getCityInRoutesCount(id);
    if(count > 0){
      _showDialog('Данный город используется в существующих маршрутах', 'Ошибка');
    }
    else{
      await CityHandler(dbHelper.db).delete(id);
      _showDialog('Город успешно удален', 'Успех');
      _idController.text = '';
      _nameDeleteController.text = '';
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
        title: Text('Управление городами'),
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
                controller: _controller,
                onChanged: (value) {
                  if (value.length >= 3) {
                    _showList = true;
                    _searchCities(value);
                  } else {
                    setState(() {
                      _cities = [];
                      _showList = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Введите название города',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            if (_showList)
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
                              _selectCity(_cities[index]);
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

            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Название города',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Локация',
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
                    if(_cityController.text == '' || _locationController.text == ''){
                      _showDialog('Выберите город из списка для добавления', 'Ошибка');
                    }
                    else{
                      _addCity(_cityController.text, _locationController.text);
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
            Text('Удаление', style: TextStyle(fontSize: 22),),
            SizedBox(height: 10,),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _nameDeleteController,
                onChanged: (value){
                  if (value.length >= 3) {
                    _showListDelete = true;
                    _searchAllCities(value);
                  } else {
                    setState(() {
                      _citiesDelete = [];
                      _showListDelete = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Введите название города',
                  border: OutlineInputBorder(),
                ),

              ),
            ),

            if (_showListDelete)
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
                              _selectDeleteCity(_citiesDelete[index]);
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
                controller: _idController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'ID города',
                  border: OutlineInputBorder(),
                ),

              ),
            ),

            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () {
                    if(_idController.text == ''){
                      _showDialog('Выберите город для удаления', 'Ошибка');
                    }
                    else{
                      _deleteCity(int.parse(_idController.text));
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
