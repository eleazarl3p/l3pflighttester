import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract class OurDataStorage {
  static Future<String> get documentsDirectoryPath async {
    return (await getApplicationDocumentsDirectory()).path;
  }

  static Future<String> get temporaryDirectoryPath async {
    return (await getTemporaryDirectory()).path;
  }

  static Future writeDocument(String document, Map<String, dynamic> data) async {
    await File("${await documentsDirectoryPath}/$document.json").writeAsString(jsonEncode(data));
  }

  static Future writeTemporary(String document, Map<String, dynamic> data) async {
    await File("${await temporaryDirectoryPath}/$document.json").writeAsString(jsonEncode(data));
  }

  static Future<Map<String, dynamic>> readDocument(String document) async {
    return jsonDecode(await File("${await documentsDirectoryPath}/$document.json").readAsString());
  }

  static Future<Map<String, dynamic>> readTemporary(String document) async {
    return jsonDecode(await File("${await temporaryDirectoryPath}/$document.json").readAsString());
  }

  static Future updateDocument(String document, Map<String, dynamic> data) async {
    final fileData = await readDocument(document);
    data.forEach((key, value) => fileData[key] = value);
    await writeDocument(document, fileData);
  }

  static Future updateTemporary(String document, Map<String, dynamic> data) async {
    final fileData = await readTemporary(document);
    data.forEach((key, value) => fileData[key] = value);
    await writeTemporary(document, fileData);
  }

  static Future deleteDocument(String document) async {
    await File("${await documentsDirectoryPath}/$document.json").delete();
  }

  static Future deleteTemporary(String document) async {
    await File("${await temporaryDirectoryPath}/$document.json").delete();
  }

  static Future clearDocuments() async {
    final directory = await getApplicationDocumentsDirectory();
    await directory.delete(recursive: true);
    await directory.create();
  }

  static Future clearTemporary() async {
    final directory = await getTemporaryDirectory();
    await directory.delete(recursive: true);
    await directory.create();
  }
}
