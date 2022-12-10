import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import '/screens/all_projects.dart';
import '/screens/all_stair_from_actual_project.dart';
import 'package:provider/provider.dart';
import '/screens/Home.dart';

import 'file_storage_manager/secretaria.dart';
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

    final tempProjects = Projects();

    OurDataStorage.readDocument('MyProjects').then((value) {
      tempProjects.resetProject();
      //print(value['projects']);
      value['projects'].forEach((element) => tempProjects.massiveUpdate(Project.fromJson(element)));
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.blueGrey.shade50,

      ),

      //home: const Home(),
      routes: {
        '/' : (context) => ProjectsPage(tempProjects: tempProjects)
      },
    );
  }
}

