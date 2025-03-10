
import 'package:application_map_todolist/hive_adapters/event_adapter.dart';
import 'package:application_map_todolist/hive_adapters/type_adapter.dart';
import 'package:application_map_todolist/hive_adapters/marker_adapter.dart';
import 'package:application_map_todolist/screens/home_screen.dart';
import 'package:application_map_todolist/screens/pin_screens/pinlogin_screen.dart';
import 'package:application_map_todolist/services/data_storage.dart';
import 'package:application_map_todolist/services/event_notification_service.dart';
import 'package:application_map_todolist/providers/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // เริ่มต้น Hive
  // ลงทะเบียน Adapter
  Hive.registerAdapter(EventAdapter());
  Hive.registerAdapter(TypeEventAdapter());
  Hive.registerAdapter(MarkerEventAdapter());
  await notificationService.init();
  runApp(
    ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String?> loadPin() async {
    return await EventStorage().loadPin();
  }

  Future<bool?> loadSetting() async {
    return await EventStorage().loadSettingPin();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('th', 'TH'), // ตั้งค่าเป็นภาษาไทย
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('th', 'TH'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      home: FutureBuilder<List<dynamic>>(
        future: Future.wait([loadPin(), loadSetting()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          } else {
            final pin = snapshot.data?[0];
            final setting = snapshot.data?[1];
            return setting == true && pin != null
              ? PinLoginScreen(openAppFirstTime: true)
              : HomeScreen();
          }
        },
      ),
    );
  }
}