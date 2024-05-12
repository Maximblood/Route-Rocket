import 'dart:convert';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kursovoy/Database/BusHandler.dart';
import 'package:kursovoy/Database/BusStopHandler.dart';
import 'package:kursovoy/Database/CityHandler.dart';
import 'package:kursovoy/Database/ClientHandler.dart';
import 'package:kursovoy/Database/DatabaseNotifier.dart';
import 'package:kursovoy/Database/RoleHandler.dart';
import 'package:kursovoy/Database/RouteHandler.dart';
import 'package:kursovoy/Database/TripHandler.dart';
import 'package:kursovoy/Database/UserSharedHandler.dart';
import 'package:kursovoy/Models/Bus.dart';
import 'package:kursovoy/Models/BusStop.dart';
import 'package:kursovoy/Models/City.dart';
import 'package:kursovoy/Models/Client.dart';
import 'package:kursovoy/Models/Role.dart';
import 'package:kursovoy/Models/Trip.dart';
import 'package:kursovoy/Pages/bus_admin_page.dart';
import 'package:kursovoy/Pages/city_admin_page.dart';
import 'package:kursovoy/Pages/driver_page.dart';
import 'package:kursovoy/Pages/route_admin_page.dart';
import 'package:kursovoy/Pages/ticket_admin_page.dart';
import 'package:kursovoy/Pages/user_admin_page.dart';
import 'package:kursovoy/Providers/AuthProvider.dart';
import 'package:provider/provider.dart';
import 'package:kursovoy/Models/Route.dart'  as Rroute;


class AuthPage extends StatefulWidget {
  final DatabaseNotifier databaseNotifier;

  AuthPage({required this.databaseNotifier});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late DatabaseNotifier _databaseNotifier;
  late Future<List<Map<String, dynamic>>>? _tripsFuture;
  String _showResult = '';
  final UserSharedHandler _userSharedHandler = UserSharedHandler("user_data");
  final TextEditingController _phoneNumberAuthController = TextEditingController();
  final TextEditingController _passwordAuthController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordAcceptController = TextEditingController();
  final TextEditingController _nameProfileController = TextEditingController();
  final TextEditingController _surnameProfileController = TextEditingController();
  final TextEditingController _emailProfileController = TextEditingController();
  final TextEditingController _phoneNumberProfileController = TextEditingController();
  final TextEditingController _newPasswordAcceptController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();



  late Future<void> _profileInfoFuture;
  String userName = '';
  String userSurname = '';
  String userTelephone = '';
  String userEmail = '';
  String userPassword = '';
  String role = '';


  bool _isEditing = false;
  bool _showPasswordResetFields = false;


  final _formKey = GlobalKey<FormState>();
  final _formKeyAuth = GlobalKey<FormState>();
  final _formKeyProfile = GlobalKey<FormState>();


  Future _loginUser(Client client) async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    ClientHandler clientHandler = ClientHandler(dbHelper.db);
    List<Client> clients = await clientHandler.getAllClients();
    int count = 0;
    for (Client listClient in clients) {
      if(client.telephone == listClient.telephone && verifyPassword(client.password, listClient.password)){
        await _userSharedHandler.saveUser(listClient.id);
        _profileInfoFuture = _profileInfoUser();
        _checkRole();
        setState(() async{
          authProvider.setAuthorized(true);
          _showResult = 'profile';
          _phoneNumberController.text = "";
          _passwordController.text = "";
        });
      }
      else{
        count++;
      }
      if(count == clients.length){
        _showDialog('Такого пользователя не существует');
        return;
      }
    }
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

  Future _profileInfoUser() async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    ClientHandler clientHandler = ClientHandler(dbHelper.db);
    int id = await _userSharedHandler.loadUser();
    print(id);
    Client? client = await clientHandler.getClient(id);
    if(client != null){
      setState(() {
        userName = client.userName;
        _nameProfileController.text = userName;
        userSurname = client.userLastName;
        _surnameProfileController.text = userSurname;
        userEmail = client.email;
        _emailProfileController.text = userEmail;
        userTelephone = client.telephone;
        _phoneNumberProfileController.text = userTelephone;
        userPassword = client.password;
      });
    }

  }


  Future _updateStartedTrip(int index) async{
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    TripHandler tripHandler = TripHandler(dbHelper.db);
    tripHandler.updateTripStatus(index, 'STARTED');
  }
  
  
  
  String encryptPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool verifyPassword(String inputPassword, String encryptedPassword) {
    return encryptPassword(inputPassword) == encryptedPassword;
  }

  void _togglePasswordResetFields() {
    setState(() {
      _showPasswordResetFields = !_showPasswordResetFields;
    });
  }


  void _cancelPasswordReset() {
    setState(() {
      _showPasswordResetFields = false;
    });
  }

  Future _registerUser(Client client) async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    ClientHandler clientHandler = ClientHandler(dbHelper.db);
    List<Client> clients = await clientHandler.getAllClients();
    int count = 0;
    for (Client listClient in clients) {
      if (client.telephone == listClient.telephone) {
        count++;
      }
    }
    if(count > 0){
      _showDialog("Пользователь с этим номером телефона уже существует");
      return;
    }
    else{
      List<Client> clientsUnregistered = await clientHandler.getAllClientsUnregistered();
      int countUnregistered = 0;
      int userId = 0;
      for (Client listClient in clientsUnregistered) {
        if (client.telephone == listClient.telephone) {
          countUnregistered++;
          userId = listClient.id;
        }
      }
      if(countUnregistered > 0){
        await clientHandler.update(client, userId);
        setState(() {
          _phoneNumberAuthController.text = '+375${_phoneNumberController.text}';
          _phoneNumberController.text = "";
          _passwordAuthController.text = _passwordController.text;
          _passwordController.text = "";
          _nameController.text = "";
          _surnameController.text = '';
          _emailController.text = "";
          _passwordAcceptController.text = "";
          _showResult = 'login';
        });
      }
      else{
        await clientHandler.insert(client);
        setState(() {
          _phoneNumberAuthController.text = '+375${_phoneNumberController.text}';
          _phoneNumberController.text = "";
          _passwordAuthController.text = _passwordController.text;
          _passwordController.text = "";
          _nameController.text = "";
          _surnameController.text = '';
          _emailController.text = "";
          _passwordAcceptController.text = "";
          _showResult = 'login';
        });
      }

    }

  }

  Future _changePasswordUser() async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    ClientHandler clientHandler = ClientHandler(dbHelper.db);
    int id = await _userSharedHandler.loadUser();
    Client? client = await clientHandler.getClient(id);
    if(client != null){
      client.password = encryptPassword(_newPasswordController.text);
      await clientHandler.update(client, id);
      setState(() {
        _newPasswordController.text = "";
        _newPasswordAcceptController.text = "";
        _userSharedHandler.deleteUser();
        _showPasswordResetFields = false;
        _showDialog('Перезайдите в аккаунт');
        _showResult = 'login';
      });
    }
  }



  Future _changeDataUser() async {
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    ClientHandler clientHandler = ClientHandler(dbHelper.db);
    int id = await _userSharedHandler.loadUser();
    Client? client = await clientHandler.getClient(id);
    if(client != null){
      client.userName = _nameProfileController.text;
      client.userLastName = _surnameProfileController.text;
      client.email = _emailProfileController.text;
      await clientHandler.update(client, id);
      setState(() {
        userName = client.userName;
        userSurname = client.userLastName;
        userEmail = client.email;
      });

    }
  }




  Future _logoutUser() async{
    showDialog(
      context: context,
      builder: (BuildContext context) {
        AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
        return AlertDialog(
          title: Text('Подтверждение'),
          content: Text('Вы действительно хотите выйти?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async{
                Navigator.of(context).pop(true);
                await _userSharedHandler.deleteUser();
                setState(() {
                  authProvider.setAuthorized(false);
                  _showResult = 'login';
                });
              },
              child: Text('Да'),
            ),
            TextButton(
              onPressed: () {

                Navigator.of(context).pop(false);
              },
              child: Text('Нет'),
            ),
          ],
        );
      },
    );

  }

  @override
  void initState(){
    super.initState();
    _databaseNotifier = widget.databaseNotifier;
    _initializeState();
    _tripsFuture = null;
  }

  void _initializeState() async {
    int userId = await _userSharedHandler.loadUser();
    if (userId != 0) {
      setState(() {
        _showResult = 'profile';
        _profileInfoFuture = _profileInfoUser();
      });
      await _checkRole();
    } else {
      setState(() {
        _showResult = 'login';
      });
    }
  }

  Future _checkRole() async{
    int userId = await _userSharedHandler.loadUser();
    final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
    String temp = await ClientHandler(dbHelper.db).getUserRole(userId);
    setState(() {
      role = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dbHelper = _databaseNotifier.databaseHelper;
    double height = MediaQuery
        .of(context)
        .size
        .height - 58;
    double width = MediaQuery
        .of(context)
        .size
        .width;

    Widget _widgetToShow;

    if (_showResult == "login") {
      _widgetToShow =  _buildLoginPage(height, width);
    } else if (_showResult == "registration") {
      _widgetToShow = _buildRegistrationPage(height, width);
    } else if (_showResult == "profile"){
      _widgetToShow = _buildProfilePage(height, width);
    }
    else if(_showResult == 'adminPage'){
      _widgetToShow = _buildAdminPage(height, width);
    }
    else if(_showResult == 'driverPage'){
      _widgetToShow = _buildDriverPage(height, width);
    }
    else{
      _widgetToShow = _buildLoginPage(height, width);
    }

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _widgetToShow
        ),
      ),
    );
  }

  Widget _buildLoginPage(double height, double width) {
    return Center(
      child: Container(
        color: Color.fromRGBO(246, 246, 246, 1.0),
        height: height,
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 140, 15, 0),
            child: Form(
              key: _formKeyAuth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Добро пожаловать!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),

                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),

                  TextFormField(
                    controller: _phoneNumberAuthController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Номер телефона',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите номер телефона';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  TextFormField(
                    controller: _passwordAuthController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Пароль',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите пароль';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      setState(() {});
                      if (_formKeyAuth.currentState != null) {
                        if (_formKeyAuth.currentState!.validate()) {
                          await _loginUser(Client(
                            '',
                            _passwordAuthController.text,
                            '',
                            '',
                            _phoneNumberAuthController.text,
                            1,
                            '',
                          ));
                        }
                      }

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const Text(
                        'Войти',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showResult = 'registration';
                      });
                    },
                    child: const Text('Еще нет аккаунта? Зарегистрируйтесь здесь.'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }





  Widget _buildRegistrationPage(double height, double width) {
    return Center(
      child: Container(
        color: Color.fromRGBO(246, 246, 246, 1.0),
        height: height,
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Регистрация',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Номер телефона',
                      prefixIcon: Icon(Icons.phone),
                      prefixText: '+375',
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[^\d]')),
                      LengthLimitingTextInputFormatter(9),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите номер телефона';
                      }
                      else if(value.length < 9){
                        return 'Введите верный номер телефона';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Имя',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите ваше имя';
                      }
                      final lettersPattern = RegExp(r'^[a-zA-Zа-яА-Я]+$');
                      if (!lettersPattern.hasMatch(value)) {
                        return 'Введите верное значение';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-Я]')),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _surnameController,
                    decoration: const InputDecoration(
                      labelText: 'Фамилия',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите вашу фамилию';
                      }
                      final lettersPattern = RegExp(r'^[a-zA-Zа-яА-Я]+$');
                      if (!lettersPattern.hasMatch(value)) {
                        return 'Введите верное значение';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-Я]')),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail),
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите ваш Email';
                      }
                      final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailPattern.hasMatch(value)) {
                        return 'Введите действительный Email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Пароль',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите пароль';
                      }
                      else if (value.length < 6) {
                        return 'Пароль должен содержать минимум 6 символов';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordAcceptController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Повторите пароль',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Повторите пароль';
                      }
                      if (value != _passwordController.text) {
                        return 'Пароли не совпадают';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState != null) {
                        if (_formKey.currentState!.validate()) {
                          Client client = Client(
                            _emailController.text,
                            encryptPassword(_passwordController.text),
                            _nameController.text,
                            _surnameController.text,
                            '+375${_phoneNumberController.text}',
                            2,
                            "REGISTERED",
                          );
                          _registerUser(client);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const Text(
                        'Зарегистрироваться',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showResult = "login";
                      });
                    },
                    child: Text(
                      'Уже есть аккаунт? Войти',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildProfilePage(double height, double width) {
    return FutureBuilder<void>(
      future: _profileInfoFuture,
      builder: (context, snapshot) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Form(
              key: _formKeyProfile,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Здравствуйте, $userSurname $userName',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneNumberProfileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Номер телефона',
                      labelStyle: TextStyle(color: Color.fromRGBO(110, 110, 110, 1)),
                      border: OutlineInputBorder(),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromRGBO(110, 110, 110, 1)),
                      ),
                    ),
                    style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
                    readOnly: true,
                    enabled: false,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _nameProfileController,
                    decoration: InputDecoration(
                      labelText: 'Имя',
                      labelStyle: TextStyle(color: _isEditing ? Colors.black : Color.fromRGBO(110, 110, 110, 1)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromRGBO(110, 110, 110, 1)),
                      ),
                    ),
                    style: _isEditing ? TextStyle(color: Colors.black) : TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
                    enabled: _isEditing,
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Введите имя';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-Я]')),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _surnameProfileController,
                    decoration: InputDecoration(
                      labelText: 'Фамилия',
                      labelStyle: TextStyle(color: _isEditing ? Colors.black : Color.fromRGBO(110, 110, 110, 1)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide( color:  _isEditing ? Colors.blue : Colors.black),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromRGBO(110, 110, 110, 1)),
                      ),
                    ),
                    style: _isEditing ? TextStyle(color: Colors.black) : TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
                    enabled: _isEditing,
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Введите фамилию';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-Я]')),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _emailProfileController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: _isEditing ? Colors.black : Color.fromRGBO(110, 110, 110, 1)),
                      border: OutlineInputBorder(),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromRGBO(110, 110, 110, 1)),
                      ),
                    ),
                    style: _isEditing ? TextStyle(color: Colors.black) : TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
                    enabled: _isEditing,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Введите Email';
                      }
                      final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (value != null && !emailPattern.hasMatch(value)) {
                        return 'Введите действительный Email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  _showPasswordResetFields ? Column(
                    children: [
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Новый пароль',
                          border: OutlineInputBorder(),
                        ),
                          validator: (value) {
                            if (_showPasswordResetFields && (value == null || value.isEmpty)) {
                              return 'Введите новый пароль';
                            }
                            else if (value != null && value.length < 6) {
                              return 'Пароль должен содержать минимум 6 символов';
                            }
                            return null;
                          }
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                          controller: _newPasswordAcceptController,
                          obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Подтвердите пароль',
                          border: OutlineInputBorder(),
                        ),
                          validator: (value) {
                            if (_showPasswordResetFields && (value == null || value.isEmpty)) {
                              return 'Введите подтверждение пароля';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Пароли не совпадают';
                            }
                            return null;
                          }
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () async {
                              if (_formKeyProfile.currentState != null && _formKeyProfile.currentState!.validate()) {
                                setState(() {
                                  _changePasswordUser();
                                });
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.green),
                              overlayColor: MaterialStateProperty.all(Colors.green.shade300),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(color: Colors.green, width: 2.0),
                                ),
                              ),
                            ),
                            child: const SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(45, 10,45,10),
                                child: Text(
                                  "Подтвердить",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                _cancelPasswordReset();
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.red),
                              overlayColor: MaterialStateProperty.all(Colors.red.shade300),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(color: Colors.red, width: 2.0),

                                ),
                              ),
                            ),
                            child: const SizedBox(

                              child: Padding(
                                padding: EdgeInsets.fromLTRB(35, 10, 35, 10),
                                child: Text(
                                  "Отмена",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ) :
                  TextButton(
                    onPressed: () async {
                      _togglePasswordResetFields();
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
                          "Сменить пароль",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16),
                        ),
                      ),
                    ),
                  ),




                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: _isEditing
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () async {
                              if (_formKeyProfile.currentState != null && _formKeyProfile.currentState!.validate()) {
                                setState(() {
                                  _changeDataUser();
                                  _isEditing = !_isEditing;
                                });
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.green),
                              overlayColor: MaterialStateProperty.all(Colors.green.shade300),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(color: Colors.green, width: 2.0),
                                ),
                              ),
                            ),
                            child: const SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(45, 10,45,10),
                                child: Text(
                                  "Подтвердить",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                _isEditing = !_isEditing;
                                _formKeyProfile.currentState?.reset();
                                _nameProfileController.text = userName;
                                _surnameProfileController.text = userSurname;
                                _emailProfileController.text = userEmail;

                              });
                              },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.red),
                              overlayColor: MaterialStateProperty.all(Colors.red.shade300),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(color: Colors.red, width: 2.0),

                                ),
                              ),
                            ),
                            child: const SizedBox(

                              child: Padding(
                                padding: EdgeInsets.fromLTRB(35, 10, 35, 10),
                                child: Text(
                                  "Отмена",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                          : TextButton(
                        onPressed: () async {
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.orange),
                          overlayColor: MaterialStateProperty.all(Colors.orange.shade300),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(color: Colors.orange, width: 2.0),
                            ),
                          ),
                        ),
                        child: const SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "Редактировать информацию",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                  ),

                  if (role == 'admin' || role == 'driver')
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: TextButton(
                        onPressed: () async {
                          final dbHelper =
                              Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
                          int userId = await _userSharedHandler.loadUser();
                          if(role == 'admin'){
                            _showResult = 'adminPage';
                          }
                          else{
                            _showResult = 'driverPage';
                            setState(() {
                              _tripsFuture = TripHandler(dbHelper.db).getInfoAboutTripForDriver(userId);
                            });
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.green),
                          overlayColor: MaterialStateProperty.all(Colors.green.shade200),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              role == 'admin' ? 'Функции администратора' : (role == 'driver' ? 'Функции водителя' : ''),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      await _logoutUser();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      overlayColor: MaterialStateProperty.all(Colors.red.shade200),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    child: const SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Выйти из аккаунта",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildAdminPage(double height, double width) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Панель администратора'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _showResult = 'profile';
          },
        ),
      ),
      body: Center(
        child: Container(
          color: Color.fromRGBO(246, 246, 246, 1.0),
          height: height,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CityAdminPage(databaseNotifier: Provider.of<DatabaseNotifier>(
                              context,
                              listen: false))),
                        );
                      },
                      child: Container(
                        width: 190,
                        padding: EdgeInsets.fromLTRB(30,15,30,15),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.location_city, size: 40),
                            SizedBox(height: 10),
                            Text('Города', style: TextStyle(fontSize: 17),),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RouteAdminPage(databaseNotifier: Provider.of<DatabaseNotifier>(
                              context,
                              listen: false))),
                        );

                      },
                      child: Container(
                        width: 190,
                        padding: EdgeInsets.fromLTRB(30,15,30,15),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.map, size: 40),
                            SizedBox(height: 10),
                            Text('Маршруты', style: TextStyle(fontSize: 17)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {


                      },
                      child: Container(
                        width: 190,
                        padding: EdgeInsets.fromLTRB(30,15,30,15),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.confirmation_number, size: 40),
                            SizedBox(height: 10),
                            Text('Рейсы', style: TextStyle(fontSize: 17),),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TicketAdminPage(databaseNotifier: Provider.of<DatabaseNotifier>(
                              context,
                              listen: false))),
                        );

                      },
                      child: Container(
                        width: 190,
                        padding: EdgeInsets.fromLTRB(30,15,30,15),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.receipt, size: 40),
                            SizedBox(height: 10),
                            Text('Билеты', style: TextStyle(fontSize: 17)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BusAdminPage(databaseNotifier: Provider.of<DatabaseNotifier>(
                              context,
                              listen: false))),
                        );

                      },
                      child: Container(
                        width: 190,
                        padding: EdgeInsets.fromLTRB(30,15,30,15),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.directions_bus, size: 40),
                            SizedBox(height: 10),
                            Text('Маршрутки', style: TextStyle(fontSize: 17),),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserAdminPage(databaseNotifier: Provider.of<DatabaseNotifier>(
                              context,
                              listen: false))),
                        );
                      },
                      child: Container(
                        width: 190,
                        padding: EdgeInsets.fromLTRB(30,15,30,15),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.person, size: 40),
                            SizedBox(height: 10),
                            Text('Пользователи', style: TextStyle(fontSize: 17)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildDriverPage(double height, double width) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Управление посадками'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _showResult = 'profile';
          },
        ),
      ),
      body: Center(
        child: Container(
          color: Color.fromRGBO(246, 246, 246, 1.0),
          height: height,
          width: double.infinity,
          padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _tripsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Ошибка: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          List<Map<String, dynamic>> trips = snapshot.data ?? [];
                          if (trips.isEmpty) {
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
                                  getDividerWidth(trips[index]['ROUTE_TIME']);
                                  return GestureDetector(
                                    onTap: () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Подтверждение"),
                                            content: Text("Вы уверены, что хотите продолжить? Если вы нажмете 'Да', то данный маршрут перейдет в состояние 'Начатый' и не будет отображаться при поиске клиентами"),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () async{
                                                  final dbHelper = Provider.of<DatabaseNotifier>(context, listen: false).databaseHelper;
                                                  await _updateStartedTrip(trips[index]['TRIPID']);
                                                  int userId = await _userSharedHandler.loadUser();
                                                  Navigator.of(context).pop(false);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => DriverPage(
                                                              selectedTripId: trips[index]
                                                              ['TRIPID'],
                                                              databaseNotifier:
                                                              Provider.of<DatabaseNotifier>(
                                                                  context,
                                                                  listen: false)))).then((value) {
                                                    if (value != null && value is bool) {
                                                      bool returnedToFirstScreen = value;
                                                      if (returnedToFirstScreen) {
                                                        setState(() {
                                                          _tripsFuture = TripHandler(dbHelper.db).getInfoAboutTripForDriver(userId);
                                                        });
                                                      } else {

                                                      }
                                                    }
                                                  });
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
                                                Text(
                                                    '${trips[index]["BUSBRAND"]} (${trips[index]["BUSNUMBER"]})',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    )
                                                ),
                                                SizedBox(height: 10,),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      trips[index]["DEPARTURE_DATE"],
                                                      style: const TextStyle(
                                                          fontWeight: FontWeight.w500),
                                                    ),
                                                    Text(
                                                      trips[index]["DESTINATION_DATE"],
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
                                                      trips[index]["DEPARTURE_TIME"],
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
                                                            trips[index]["ROUTE_TIME"]),
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
                                                      trips[index]["DESTINATION_TIME"],
                                                      style: const TextStyle(
                                                          fontSize: 30,
                                                          fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Кол-во человек: ${trips[index]["TicketCount"].toString()}',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                      )
                                                      ),
                                                    Text(
                                                      "Цена за билет: ${trips[index]["COST"].toString()} руб."
                                                      ,
                                                      style: TextStyle(
                                                           fontSize: 18,
                                                           ),
                                                      ),
                                                    Text(
                                                          "Предполагаемая сумма: ${trips[index]["TicketCost"].toString()} руб."
                                                           ,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                             ),
                                                    ),

                                                  ],
                                                ),
                                              ],
                                            ),
                                          )),
                                    ),
                                  );
                                },
                                itemCount: trips.length,
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
            )

        ),
      ),
    );
  }

}



