//import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import '/screens/all_projects.dart';
import '/screens/all_stair_from_actual_project.dart';
import 'package:provider/provider.dart';
import '/screens/Home.dart';

import 'file_storage_manager/secretaria.dart';
import 'models/Projects.dart';
import 'models/flight_map.dart';
import 'models/project.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  Projects savedProjects = Projects();
  // try {
  //   await  OurDataStorage.readDocument('MyProjects');
  //
  // } catch(error) {
  //   print(error);
  // }
  await OurDataStorage.readDocument('MyProjects').then((value) {
    //print(value['projects']);
    value['projects'].forEach((element) => savedProjects.massiveUpdate(Project.fromJson(element)));
  }).catchError((e) {});

  print('saved: ${savedProjects.projects[0].id} 00');

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => Projects()),
      ChangeNotifierProvider(create: (context) => Project()),
      ChangeNotifierProvider(create: (context) => FlightMap())
    ],
    child: MyApp(
      ldP: savedProjects,
    ),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.ldP});

  bool load = true;
  Projects ldP;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // final tempProjects = Projects();
    final pjsProvider = context.read<Projects>();
    print('object');
    if (load) {
      ldP.projects.forEach((element) => pjsProvider.massiveUpdate(element));

      load = false;
    }

    // OurDataStorage.readDocument('MyProjects').then((value) {
    //   pjsProvider.resetProject();
    //   //print(value['projects']);
    //   value['projects'].forEach((element) => pjsProvider.massiveUpdate(Project.fromJson(element)));
    // }).catchError((e) {
    //   print(e);
    // });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.blueGrey.shade50,
      ),

      //home: const Home(),
      routes: {'/': (context) => ProjectsPage()},
    );
  }
}

class HomeSt extends StatelessWidget {
  const HomeSt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
