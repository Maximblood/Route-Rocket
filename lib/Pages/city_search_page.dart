import 'package:flutter/material.dart';
import 'package:kursovoy/Database/DatabaseNotifier.dart';
import 'package:kursovoy/Models/City.dart';
import 'package:kursovoy/Database/CityHandler.dart';
import 'package:provider/provider.dart';

class CitySearchPage extends StatefulWidget {
  final String selectedCity;

  CitySearchPage({required this.selectedCity});

  @override
  _CitySearchPageState createState() => _CitySearchPageState();
}

class _CitySearchPageState extends State<CitySearchPage> {
  late String selectedCity;
  late TextEditingController _controller;
  late Future<List<City>> _citiesFuture;

  @override
  void initState() {
    super.initState();
    selectedCity = widget.selectedCity;
    _controller = TextEditingController();
    _controller.text = '';
    _citiesFuture = _searchCities('');
  }

  Future<List<City>> _searchCities(String searchText) async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    return await CityHandler(dbHelper.db).getAllCities(selectedCity,searchText);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 58;

    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: width,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Введите текст',
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (_controller.text != '') {
                            _controller.clear();
                          } else {
                            Navigator.pop(context, {'result': false});
                          }
                        },
                        icon: Icon(Icons.clear),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _citiesFuture = _searchCities(value);
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<City>>(
                  future: _citiesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      List<City> cities = snapshot.data ?? [];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: ListView.separated(
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(cities[index].cityName),
                              subtitle: Text(cities[index].location),
                              onTap: () {
                                Navigator.pop(context, {'result': true, 'cityName': cities[index].cityName, 'id': cities[index].id});
                              },
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                          const Divider(color: Colors.grey, height: 0.05,),
                          itemCount: cities.length,
                          shrinkWrap: true,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
