import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kursovoy/Database/BusHandler.dart';
import 'package:kursovoy/Database/CityHandler.dart';
import 'package:kursovoy/Database/DatabaseNotifier.dart';
import 'package:kursovoy/Database/TicketHandler.dart';
import 'package:kursovoy/Models/Bus.dart';
import 'package:kursovoy/Models/City.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


class BusAdminPage extends StatefulWidget {
  final DatabaseNotifier databaseNotifier;

  BusAdminPage({required this.databaseNotifier});

  @override
  _BusAdminPageState createState() => _BusAdminPageState();
}

class _BusAdminPageState extends State<BusAdminPage> {
  TextEditingController _placesController = TextEditingController();
  TextEditingController _brandController = TextEditingController();
  TextEditingController _numberController = TextEditingController();

  TextEditingController _numberUpdateController = TextEditingController();
  TextEditingController _placesUpdateController = TextEditingController();
  TextEditingController _idUpdateController = TextEditingController()
  ;
  TextEditingController _idDeleteController = TextEditingController();
  TextEditingController _numberDeleteController = TextEditingController();


  void addBus() async{
    String pattern = r'^\d{4}\s[A-Z]{2}-[1-7]{1}$';
    RegExp regExp = new RegExp(pattern);
    bool isValid = regExp.hasMatch(_numberController.text);

    if(isValid){
      if(_placesController.text[0] == '0'){
        _showDialog('Введите корректное кол-во мест', 'Ошибка');
      }
      else{
        if(_brandController.text[0] == ' ' || _brandController.text.length < 3){
          _showDialog('Введите корректную модель', 'Ошибка');
        }
        else{
          final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;

          int count = await BusHandler(dbHelper.db).getBusCountById(_numberController.text);
          if(count == 0){
            Bus bus = Bus(_brandController.text, _numberController.text, int.parse(_placesController.text));
            await BusHandler(dbHelper.db).insert(bus);
            _showDialog('Маршрутка успешно добавлена', 'Успех');
            setState(() {
              _brandController.text = '';
              _numberController.text = '';
              _placesController.text = '';
            });
          }
          else{
            _showDialog('Маршрутка c таким номером уже существует', 'Ошибка');
          }
        }
      }
    }
    else{
      _showDialog('Номер не удовлетворяет требуемому формату (0000 AA-1)', 'Ошибка');
    }
  }


  void _updateBus() async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    int count = await BusHandler(dbHelper.db).getBusCount(int.parse(_idUpdateController.text));
    if(count == 0){
      await BusHandler(dbHelper.db).updateBus(int.parse(_idUpdateController.text), int.parse(_placesUpdateController.text));
      _showDialog('Успешно обновлено', 'Успех');
      setState(() {
        _numberUpdateController.text = '';
        _idUpdateController.text = '';
        _placesUpdateController.text = '';
      });
    }
    else{
      _showDialog('Вы не можете изменить маршрутку с этим номером, т.к. она закреплена за маршрутом', 'Ошибка');
    }
  }


  void _deleteBus() async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    int count = await BusHandler(dbHelper.db).getBusCount(int.parse(_idDeleteController.text));
    if(count == 0){
      await BusHandler(dbHelper.db).delete(int.parse(_idDeleteController.text));
      _showDialog('Успешно удалено', 'Успех');
      setState(() {
        _numberDeleteController.text = '';
        _idDeleteController.text = '';
      });
    }
    else{
      _showDialog('Вы не можете удалить маршрутку с этим номером, т.к. она закреплена за маршрутом', 'Ошибка');
    }
  }



  void _searchBusId() async{
    String pattern = r'^\d{4}\s[A-Z]{2}-[1-7]{1}$';
    RegExp regExp = new RegExp(pattern);
    bool isValid = regExp.hasMatch(_numberUpdateController.text);
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;

    if(isValid){
      int id = await BusHandler(dbHelper.db).getBusId(_numberUpdateController.text);
      setState(() {
        _idUpdateController.text = id.toString();
      });
    }
    else{
      _showDialog('Номер не удовлетворяет требуемому формату (0000 AA-1)', 'Ошибка');
    }
  }



  void _searchBusIdDelete() async{
    String pattern = r'^\d{4}\s[A-Z]{2}-[1-7]{1}$';
    RegExp regExp = new RegExp(pattern);
    bool isValid = regExp.hasMatch(_numberDeleteController.text);
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;

    if(isValid){
      int id = await BusHandler(dbHelper.db).getBusId(_numberDeleteController.text);
      setState(() {
        _idDeleteController.text = id.toString();
      });
    }
    else{
      _showDialog('Номер не удовлетворяет требуемому формату (0000 AA-1)', 'Ошибка');
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
        title: Text('Управление маршрутками'),
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
                controller: _brandController,
                decoration: InputDecoration(
                  labelText: 'Модель маршрутки',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\d')),
                  LengthLimitingTextInputFormatter(35)
                ],
              ),
            ),


            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                inputFormatters: [
                  LengthLimitingTextInputFormatter(9)
                ],
                controller: _numberController,
                decoration: InputDecoration(
                  labelText: 'Номер маршрутки (0000 AA-1)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: _placesController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2)
                ],
                decoration: InputDecoration(
                  labelText: 'Кол-во мест',
                  border: OutlineInputBorder(),
                ),
              ),
            ),


            if(_brandController.text != '' && _numberController.text != '' && _placesController.text != '')
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                        addBus();
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
                controller: _numberUpdateController,
                decoration: InputDecoration(
                  labelText: 'Номер изменяемой маршрутки',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(9)
                ],

              ),
            ),

            if(_numberUpdateController.text != "")
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _searchBusId();
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
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'ID маршрутки',
                        border: OutlineInputBorder(),
                      ),

                    ),
                  ),
                ],
              ),


            if(_idUpdateController.text != '' && _idUpdateController.text != '0')
              Padding(
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  controller: _placesUpdateController,
                  decoration: InputDecoration(
                    labelText: 'Новое кол-во мест',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(2)
                  ],
                ),
              ),

            if(_placesUpdateController.text != '' && _placesUpdateController.text[0] != "0")
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () {
                    _updateBus();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Изменить',
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
                controller: _numberDeleteController,
                decoration: InputDecoration(
                  labelText: 'Номер изменяемой маршрутки',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(9)
                ],
              ),
            ),

            if(_numberDeleteController.text != "")
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _searchBusIdDelete();
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
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'ID маршрутки',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),




            if(_idDeleteController.text != '' && _idDeleteController.text != '0')
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _deleteBus();
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
