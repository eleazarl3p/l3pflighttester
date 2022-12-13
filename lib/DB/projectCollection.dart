// import 'package:cloud_firestore/cloud_firestore.dart';
// //import 'package:flutter_application_1/providers/projets.dart';
// class  FBDB {
//
//   static FirebaseFirestore conn = FirebaseFirestore.instance;
//
//   // static Future create(
//   //     String collection, String document, Map<String, dynamic> data) async {
//   //   await conn.collection(collection).doc(document).set(data);
//   // }
//
//   static Future create(
//       String collection, String document, dynamic data) async {
//     await conn.collection(collection).doc(document).set(data);
//   }
//
//   static Future<Map<String, dynamic>?> read(
//       String collection, String document) async {
//     final snapshot = await conn.collection(collection).doc(document).get();
//     return snapshot.data() ;
//   }
//
//   static Future update({
//       required String collection, required String document, required Map<String, dynamic> data}) async {
//     await conn.collection(collection).doc(document).update(data);
//   }
//
//   static Future replace(
//       String collection, String document, Map<String, dynamic> data) async {
//     await conn.collection(collection).doc(document).set(data);
//   }
//
//   static Future delete(String collection, String document) async {
//     await conn.collection(collection).doc(document).delete();
//   }
//
//   static Future  readCollection (String collection) async {
//     final snapshot = await conn.collection(collection).get();
//
//     List projectList = snapshot.docs.toList();
//
//     return projectList;
//   }
//
//
//
// }
//
//
// // List proj = [];
// // FirebaseFirestore.instance
// //     .collection('projects')
// // .get()
// //     .then((QuerySnapshot querySnapshot) {
// // querySnapshot.docs.forEach((doc) {
// // print(doc);
// // proj.add(doc.fromJson)
// // });
// // });
