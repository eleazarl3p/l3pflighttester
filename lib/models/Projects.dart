import 'package:flutter/cupertino.dart';
//import 'package:json_annotation/json_annotation.dart';
import '/models/project.dart';

//import 'package:json_annotation/json_annotation.dart';




class Projects extends ChangeNotifier {
  List<Project> _projects = [];
  Projects();

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  void removeProject(Project project) {
    _projects.remove(project);
    notifyListeners();
  }

  void resetProject() {
    _projects.clear();
    //notifyListeners();
  }

  void massiveUpdate(Project project){
    _projects.add(project);
  }

  get projects {
    return [..._projects];
  }


  Map<String, dynamic> toJson() {
    List myProjects = _projects.map((e) => e.toJson()).toList();

    return {"projects": myProjects};
  }

  factory Projects.fromJson(dynamic json) {


    Projects pjs = Projects();

    json['projects'].map((pj) => pjs.massiveUpdate(pj));
    return pjs;
  }

}
