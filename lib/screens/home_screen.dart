import 'package:application_map_todolist/wiggets/task_widget.dart';
import 'package:application_map_todolist/screens/calender_screen.dart';
import 'package:application_map_todolist/screens/map_screen.dart';
import 'package:application_map_todolist/screens/setting_screen.dart';
import 'package:application_map_todolist/screens/todolist_screen.dart';
import 'package:application_map_todolist/units/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final int onNavigate;
  final String markerId;
  const HomeScreen({super.key, this.onNavigate = 0, this.markerId = ''});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int navigate = 0;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeOpen();
    if(widget.onNavigate == 2){
      navigate = 2;
    }
  }

  Future<void> _checkFirstTimeOpen() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  if (isFirstTime) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DialogHelper.showHowToUseAppDialog(context);
    });
    await prefs.setBool('isFirstTime', false);
  }
}

  List<Widget> get _pages => [
        MyMap(onNavigate: navigate, markerId: widget.markerId),
        ListEvents(),
        Placeholder(),
        CalendarApp(),
        Settings(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if(navigate == 1 || navigate == 2){
        navigate = 0 ;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(builder: (context) => _pages[_selectedIndex]);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: _selectedIndex == 0
                      ? Icon(Icons.map)
                      : Icon(Icons.map_outlined),
                  label: 'แผนที่',
                ),
                BottomNavigationBarItem(
                  icon: _selectedIndex == 1
                      ? Icon(Icons.list_alt)
                      : Icon(Icons.list_alt_outlined),
                  label: 'กิจกรรม',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(width: 10),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: _selectedIndex == 3
                      ? Icon(Icons.calendar_month)
                      : Icon(Icons.calendar_month_outlined),
                  label: 'ปฏิทิน',
                ),
                BottomNavigationBarItem(
                  icon: _selectedIndex == 4
                      ? Icon(Icons.settings)
                      : Icon(Icons.settings_outlined),
                  label: 'ตั้งค่า',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              selectedItemColor: Color.fromARGB(255, 98, 197, 162),
              backgroundColor: Colors.white,
            ),
          ),
          Positioned(
            right: MediaQuery.of(context).size.width * 0.4,
            left: MediaQuery.of(context).size.width * 0.4,
            bottom: MediaQuery.of(context).size.height * _selectedIndex != 0 ? 7 : 0.001,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if(_selectedIndex != 0) {
                    _selectedIndex = 0;
                    navigate = 1;
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        insetPadding: EdgeInsets.only(top: 230),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // กำหนดขอบมนเป็น 0
                        ),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          height: MediaQuery.of(context).size.height * 0.5, // ความสูงเต็มหน้าจอ
                          width: MediaQuery.of(context).size.width * 0.92, // ความกว้างเต็มหน้าจอ
                          child: TasksWidget(taskToday: true),
                        ),
                      ),
                    );
                  }
                });
              },
              child: _selectedIndex != 0
                ? Container(
                width: 75,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 98, 197, 162), // สีปุ่ม
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                      child: Icon(
                    Icons.add,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    size: 30,
                  ))
              )
              : Container(
                width: 75,
                child: Image.asset(
                  height: 58,
                  width: 70,
                  'assets/board.gif'
                ),
              )
            ),
          ),
        ],
      ),
    );
  }
}
