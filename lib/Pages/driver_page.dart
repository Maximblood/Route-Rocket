import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kursovoy/Database/DatabaseNotifier.dart';
import 'package:kursovoy/Database/TicketHandler.dart';
import 'package:kursovoy/Database/TripHandler.dart';
import 'package:provider/provider.dart';

class DriverPage extends StatefulWidget {
  final DatabaseNotifier databaseNotifier;
  int selectedTripId;

  DriverPage({required this.selectedTripId, required this.databaseNotifier});

  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  late int selectedTripId;
  late Future<List<Map<String, dynamic>>> _passengerFuture;
  double sumCost = 0;
  late Map<int, Color> _colorMap;
  late Map<int, bool> _buttonPressed;

  @override
  void initState() {
    super.initState();
    selectedTripId = widget.selectedTripId;
    _searchTicketInfo();
    _colorMap = {};
    _buttonPressed = {};
  }

  Future _searchTicketInfo() async {
    final dbHelper =
        Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    _passengerFuture =
        TripHandler(dbHelper.db).getAllPassengersForDriver(selectedTripId);
  }

  Future _updateEndedTrip(int index) async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    TripHandler tripHandler = TripHandler(dbHelper.db);
    tripHandler.updateTripStatus(index, 'ENDED');
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 58;
    return Scaffold(
        appBar: AppBar(
          title: Text("Контроль за пассажирами"),
          automaticallyImplyLeading: false
        ),
        body: _buildPassengerPage());
  }
  Widget _buildPassengerPage() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _passengerFuture,
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
            List<Map<String, dynamic>> passengers = snapshot.data ?? [];
            if (passengers.isEmpty) {
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
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          title: Container(
                            decoration: BoxDecoration(
                              color: _colorMap[index] ?? Color.fromRGBO(226, 216, 246, 1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${passengers[index]["ClientName"]} ${passengers[index]["ClientLastName"]}",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "${passengers[index]["ClientTelephone"]}",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "Кол-во мест: ${passengers[index]["COUNT_PLACES"]} (${passengers[index]["COST"]} руб.)",
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            "Место посадки: ${passengers[index]["LandingFromCityName"]}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            "Место выхода: ${passengers[index]["LandingToCityName"]}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                          visible: _buttonPressed[index] != true,
                                          child: Column(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _colorMap[index] = Colors.green;
                                                    sumCost += passengers[index]["COST"];
                                                    _buttonPressed[index] = true;
                                                  });
                                                },
                                                child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.green,
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _colorMap[index] = Colors.red;
                                                    _buttonPressed[index] = true;
                                                  });
                                                },
                                                child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.red,
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                    ),

                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      )

                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: passengers.length,
                      shrinkWrap: true,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey, width: 1,)
                        )
                      ),
                      height: 150,
                      width: double.infinity,

                        child: Padding(
                          padding: EdgeInsets.fromLTRB(5, 15, 5, 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Конечная цена: ${sumCost} руб.', style: TextStyle(fontSize: 20),),
                              SizedBox(height: 20),
                              TextButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Подтверждение"),
                                        content: Text("Вы уверены, что хотите продолжить? Если вы нажмете 'Да', то данный маршрут перейдет в состояние 'Завершенный'"),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () async{
                                              await _updateEndedTrip(selectedTripId);
                                              Navigator.of(context).pop(false);
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
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                  overlayColor: MaterialStateProperty.all(Colors.grey.shade300),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      side: BorderSide(color: Colors.grey, width: 2.0),

                                    ),
                                  ),
                                ),
                                child: const SizedBox(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      "Завершить посадку",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )

                      ),
                    ),
                ],
              );
            }
          }
        },
      ),
    );
  }


}
