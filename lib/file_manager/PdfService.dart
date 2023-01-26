import 'dart:io';
import 'dart:typed_data';
import 'package:open_document/open_document.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../constants.dart';
import '../models/flight.dart';
import '../models/stair.dart';

pw.TextStyle title = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);
List<String> alphabet = List.generate(26, (index) => String.fromCharCode(index + 65));

class PdfService {
  // static Future<Uint8List> createFile() {
  //   final pdf = pw.Document();
  //
  //   pdf.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Text("Hello World"))));
  //
  //   return pdf.save();
  // }

  static Future<void> createFile(String filePath, Stair escalera) async {
    final pdf = pw.Document();

    for (Flight flt in escalera.flights) {
      pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
            pw.Text('Flight : ${flt.id}', style: title),
          ]),
          pw.SizedBox(height: 15.0),
          pw.Row(children: [
            pw.Container(
              width: 80.0,
              child: pw.Text('Riser :'),
            ),
            pw.Text(flt.riser),
          ]),
          pw.Row(children: [
            pw.Container(
              width: 80.0,
              child: pw.Text('Bevel :'),
            ),
            pw.Text(flt.bevel),
          ]),
          pw.Row(children: [
            pw.Container(
              width: 80.0,
              child: pw.Text('Last Nose :'),
            ),
            pw.Text(flt.lastNoseDistance),
          ]),
          pw.SizedBox(height: 15.0),
          // Bottom Crotch
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Container(
              width: 100.0,
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text("Bottom Crotch"),
                flt.bottomCrotch ? pw.Text("Yes") : pw.Text('No'),
              ]),
            ),
            pw.Container(
              width: 100.0,
              child: pw.Column(children: [
                pw.Text("Distance"),
                flt.bottomCrotch ? pw.Text(flt.bottomCrotchDistance) : pw.Text('None'),
              ]),
            ),
            pw.Container(
              child: pw.Column(children: [
                pw.Text("Post"),
                flt.bottomCrotchPost ? pw.Text('Yes') : pw.Text('No'),
              ]),
            ),
            pw.Container(
              width: 100.0,
              child: pw.Column(children: [
                pw.Text("Emb. Type"),
                flt.bottomCrotch ? pw.Text(flt.bottomCrotchEmbeddedType) : pw.Text('None'),
              ]),
            ),
          ]),

          pw.SizedBox(height: 15.0),
          // Top Crotch
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Container(
              width: 100.0,
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text("Top Crotch"),
                flt.topCrotch ? pw.Text("Yes") : pw.Text('No'),
              ]),
            ),
            pw.Container(
              width: 100.0,
              child: pw.Column(children: [
                pw.Text("Distance"),
                flt.topCrotch ? pw.Text(flt.topCrotchDistance) : pw.Text('None'),
              ]),
            ),
            pw.Container(
              child: pw.Column(children: [
                pw.Text("Post"),
                flt.topCrotchPost ? pw.Text('Yes') : pw.Text('No'),
              ]),
            ),
            pw.Container(
              width: 100.0,
              child: pw.Column(children: [
                pw.Text("Emb. Type"),
                flt.topCrotch ? pw.Text(flt.topCrotchEmbeddedType) : pw.Text('None'),
              ]),
            ),
          ]),

          pw.SizedBox(height: 15.0),

          // Lower Post
          if (flt.lowerFlatPost.isNotEmpty) ...{
            pw.Text("Lower Flat Post", style: title),
            pw.SizedBox(height: 5.0),
            pw.Row(children: [
              pw.Container(
                width: 50.0,
                child: pw.Text('Id'),
              ),
              pw.Container(
                width: 80.0,
                child: pw.Text('Distance'),
              ),
              pw.Container(
                width: 100.0,
                child: pw.Text("Emb. Type"),
              ),
            ]),
            pw.SizedBox(height: 5.0),
            pw.ListView.builder(
                itemCount: flt.lowerFlatPost.length,
                itemBuilder: (pw.Context context, index) {
                  return pw.Row(children: [
                    pw.Container(
                      width: 50.0,
                      child: pw.Text('B${index + 1}'),
                    ),
                    pw.Container(
                      width: 80.0,
                      child: pw.Text(flt.lowerFlatPost[index].distance),
                    ),
                    pw.Container(
                      width: 100.0,
                      child: pw.Text(flt.lowerFlatPost[index].embeddedType),
                    ),
                  ]);
                }),
          },

          // Baluster Post
          if (flt.balusters.isNotEmpty) ...{
            pw.SizedBox(height: 15.0),
            pw.Text("Balusters", style: title),
            pw.SizedBox(height: 5.0),
            pw.Row(children: [
              pw.Container(
                width: 50.0,
                child: pw.Text('Id'),
              ),
              pw.Container(
                width: 80.0,
                child: pw.Text('Distance'),
              ),
              pw.Container(
                width: 80.0,
                child: pw.Text('Baluster'),
              ),
              pw.Container(
                width: 100.0,
                child: pw.Text("Emb. Type"),
              ),
            ]),
            pw.SizedBox(height: 5.0),
            pw.ListView.builder(
                itemCount: flt.balusters.length,
                itemBuilder: (pw.Context context, index) {
                  return pw.Row(children: [
                    pw.Container(
                      width: 50.0,
                      child: pw.Text('${alphabet[index]}'),
                    ),
                    pw.Container(
                      width: 80.0,
                      child: pw.Text(flt.balusters[index].nosingDistance),
                    ),
                    pw.Container(
                      width: 80.0,
                      child: pw.Text(flt.balusters[index].balusterDistance),
                    ),
                    pw.Container(
                      width: 100.0,
                      child: pw.Text(flt.balusters[index].embeddedType),
                    ),
                  ]);
                }),
          },

          // Upper Post
          if (flt.upperFlatPost.isNotEmpty) ...{
            pw.SizedBox(height: 15.0),
            pw.Text("Upper Flat Post", style: title),
            pw.SizedBox(height: 5.0),
            pw.Row(children: [
              pw.Container(
                width: 50.0,
                child: pw.Text('Id'),
              ),
              pw.Container(
                width: 80.0,
                child: pw.Text('Distance'),
              ),
              pw.Container(
                width: 100.0,
                child: pw.Text("Emb. Type"),
              ),
            ]),
            pw.SizedBox(height: 5.0),
            pw.ListView.builder(
                itemCount: flt.upperFlatPost.length,
                itemBuilder: (pw.Context context, index) {
                  return pw.Row(children: [
                    pw.Container(
                      width: 50.0,
                      child: pw.Text('U$index'),
                    ),
                    pw.Container(
                      width: 80.0,
                      child: pw.Text(flt.upperFlatPost[index].distance),
                    ),
                    pw.Container(
                      width: 100.0,
                      child: pw.Text(flt.upperFlatPost[index].embeddedType),
                    ),
                  ]);
                }),
          }
        ]),
      ));
    }
    //await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    final savedFile = await pdf.save();
    savePdfFile(filePath, savedFile);
  }

  static Future<void> savePdfFile(String filePath, Uint8List bytesList) async {
    final file = File(filePath);
    await file.writeAsBytes(bytesList);

    //await OpenDocument.openDocument(filePath: filePath);
  }
}
