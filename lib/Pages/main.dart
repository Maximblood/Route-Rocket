
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kursovoy/Database/ClientHandler.dart';
import 'package:kursovoy/Database/UserSharedHandler.dart';
import 'package:kursovoy/Pages/auth_page.dart';
import 'package:kursovoy/Pages/main_page.dart';
import 'package:kursovoy/Pages/trips_page.dart';
import 'package:kursovoy/Providers/AuthProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../Database/DatabaseNotifier.dart';



void main() async{
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color.fromRGBO(130, 130, 130, 0.5),
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<DatabaseNotifier>(
        create: (context) => DatabaseNotifier(),
      ),
      ChangeNotifierProvider<AuthProvider>(
        create: (context) => AuthProvider(),
      ),

    ],
    child: MyApp(),
  ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<DatabaseNotifier>(context, listen: false).initializeDatabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка инициализации базы данных: ${snapshot.error}'));
        } else {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
              useMaterial3: true,
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ru', 'RU'),
            ],
            home: const MyHomePage(title: 'Flutter Demo Home Page'),
          );
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  String formattedDate = '';
  final UserSharedHandler _userSharedHandler = UserSharedHandler("user_data");
  bool _showProfile = false;


  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _updateShowProfile(BuildContext context) async {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    int userId = await _userSharedHandler.loadUser();
    if(userId != 0){
      setState((){
        _showProfile = true;
        authProvider.setAuthorized(true);
      });
    }
    else{
      setState(() {
        _showProfile = false;
        authProvider.setAuthorized(false);
      });
    }

  }




  @override
  Widget build(BuildContext context) {
    final databaseNotifier = Provider.of<DatabaseNotifier>(context);

    final List<Widget> _children = [
      MainPage(databaseNotifier: databaseNotifier),
      TripsPage(databaseNotifier: databaseNotifier),
      AuthPage(databaseNotifier: databaseNotifier),
    ];

    DateTime now = DateTime.now();
    formattedDate = DateFormat('dd MMMM yyyy (EEEE)').format(now);
    List<String> parameters = ["Откуда", "Куда", "$formattedDate"];

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 58;

    _updateShowProfile(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items:  [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: 'Билеты',
          ),
          BottomNavigationBarItem(
            icon: _showProfile ? const Icon(Icons.person) : const Icon(Icons.login),
            label: _showProfile ? 'Профиль' : 'Войти',
          ),
        ],
      ),
    );
  }
}
