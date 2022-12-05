import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import '/screens/all_projects.dart';
import '/screens/all_stair_from_actual_project.dart';
import 'package:provider/provider.dart';
import '/screens/Home.dart';

import 'models/Projects.dart';
import 'models/flight_map.dart';
import 'models/project.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(

  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => Projects()),
      ChangeNotifierProvider(create: (context) => Project()),
      ChangeNotifierProvider(create: (context) => FlightMap())
    ],
    child:  const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),

      home: const Home(),
    );
  }
}

