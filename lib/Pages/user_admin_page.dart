import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kursovoy/Database/CityHandler.dart';
import 'package:kursovoy/Database/ClientHandler.dart';
import 'package:kursovoy/Database/DatabaseNotifier.dart';
import 'package:kursovoy/Database/RoleHandler.dart';
import 'package:kursovoy/Database/TicketHandler.dart';
import 'package:kursovoy/Models/City.dart';
import 'package:kursovoy/Models/Client.dart';
import 'package:kursovoy/Models/Role.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


class UserAdminPage extends StatefulWidget {
  final DatabaseNotifier databaseNotifier;

  UserAdminPage({required this.databaseNotifier});

  @override
  _UserAdminPageState createState() => _UserAdminPageState();
}

class _UserAdminPageState extends State<UserAdminPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _clientList = [];
  List<Map<String, dynamic>> _filteredClientList = [];
  List<Role> roleList = [];
  List<String> roleListAdmin = ['admin'];

  @override
  void initState() {
    super.initState();
    _getClients();
    _getRoles();
  }

  Future<void> _getClients() async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    String searchQuery = _searchController.text.trim();
    List<Map<String, dynamic>> result = await ClientHandler(dbHelper.db).getClientAdmin(searchQuery);
    setState(() {
      _clientList = result;
      if(result.length > 50){
        _filteredClientList = result.sublist(0, 50);
      }
      else{
        _filteredClientList = result;
      }
    });
  }

  Future<void> _getRoles() async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    List<Role> result = await RoleHandler(dbHelper.db).getAllRolesWithoutAdmin();
    setState(() {
      roleList = result;
    });
  }

  void _updateUser(String newRole, int clientId) async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    String role = await ClientHandler(dbHelper.db).getUserRole(clientId);
    if(role != newRole){
     if(role == 'driver'){
       int count = await ClientHandler(dbHelper.db).getDriverCountTrips(clientId);
       if(count == 0){
          int newRoleId = await RoleHandler(dbHelper.db).getRoleId(newRole);
          await ClientHandler(dbHelper.db).updateRoleId(clientId, newRoleId);
          _showDialog('Водитель успешно удален', 'Успех');
          _getClients();
       }
       else{
         _showDialog('Невозможно поменять роль. Данный водитель прикреплен к рейсу', 'Ошибка');
       }
     }
     else{
       int newRoleId = await RoleHandler(dbHelper.db).getRoleId(newRole);
       await ClientHandler(dbHelper.db).updateRoleId(clientId, newRoleId);
       _showDialog('Водитель успешно добавлен', 'Успех');
       _getClients();
     }
    }
    else{

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
        title: Text('Управление пользователями'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Введите текст',
                  ),
                  onChanged: (value) {
                    _getClients();
                  },
                ),
            ),

            ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredClientList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${_filteredClientList[index]['USERNAME']} ${_filteredClientList[index]['USERNAME']}'),
                  subtitle: Text(_filteredClientList[index]['TELEPHONE']),
                  trailing: (_filteredClientList[index]['ROLENAME'] != 'admin') ? DropdownButton<String>(
                    value: _filteredClientList[index]['ROLENAME'],
                    onChanged: (String? newValue) {
                      if(newValue != null){
                        setState(() {
                          _updateUser(newValue, _filteredClientList[index]['USERID']);
                        });
                      }

                    },
                    items: roleList.map<DropdownMenuItem<String>>((Role value) {
                      return DropdownMenuItem<String>(
                        value: value.roleName,
                        child: Text(value.roleName),
                      );
                    }).toList(),
                  ) : DropdownButton<String>(
                    value: _filteredClientList[index]['ROLENAME'],
                    onChanged: (String? newValue) {
                      if(newValue != null){
                        setState(() {
                          _updateUser(newValue, _filteredClientList[index]['CLIENTID']);
                        });
                      }
                    },
                    items: roleListAdmin.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
