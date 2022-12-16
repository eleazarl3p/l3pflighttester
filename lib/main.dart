import '/screens/all_projects.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'file_manager/secretary.dart';
import 'models/Projects.dart';

import 'models/project.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => Projects()),
    ChangeNotifierProvider(create: (context) => Project()),
    //ChangeNotifierProvider(create: (context) => FlightMap())
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool load = true;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (load) {
      Projects pjs = context.read<Projects>();

      OurDataStorage.readDocument('allProjects').then((value) {
        value['projects'].forEach((element) => pjs.addProject(Project.fromJson(element)));
      }).catchError((e) {
        //OurDataStorage.writeDocument('allProjects', pjs.toJson());
      });
      load = false;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.blueGrey.shade50,
      ),

      //home: const Home(),
      routes: {'/': (context) => const ProjectsPage()},
    );
  }
}
