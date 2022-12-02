import 'dart:math';
//import 'dart:ui';
import 'package:flutter/material.dart';

// import provider
import 'package:provider/provider.dart';
import '../models/flight_map.dart';


class Cuadro extends StatelessWidget {
  const Cuadro({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<FlightMap>().textFormFields;

    String urlI =
        "https://upload.wikimedia.org/wikipedia/en/1/13/PinkFloydWallCoverOriginalNoText.jpg";

    return Container(
      width: double.infinity,
      height: double.infinity,

      // color: Colors.cyan[50],
      decoration: BoxDecoration(
        border: Border.all(width: 2.0, color: Colors.black87),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        color: Colors.white,
      ),
      child: InteractiveViewer(
        child: CustomPaint(
          painter: _Dibujo(data: data),
        ),
      ),
    );
  }
}

class _Dibujo extends CustomPainter {
  Map data;

  _Dibujo({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    int stairsCount = int.parse(data['stairsCount']);

    // ------------------------------ Colors -------------------------------
    Color stepColor = Colors.red.shade200;
    // ---------------------------------------------------------------------
    // ----------------------------- Pens ----------------------------------
    final stairPenFill = Paint();
    stairPenFill.color = Colors.blueGrey.shade100;
    stairPenFill.style = PaintingStyle.fill;
    stairPenFill.strokeWidth = 2.0;

    final stairPenStk = Paint();
    stairPenStk.color = Colors.black87;
    stairPenStk.style = PaintingStyle.stroke;
    stairPenStk.strokeWidth = 1.5;
    stairPenStk.isAntiAlias = true;

    final Paint whitePen = Paint();
    whitePen.color = Colors.white;
    whitePen.style = PaintingStyle.stroke;
    whitePen.strokeWidth = 1.5;
    whitePen.isAntiAlias = true;

    final crotchPen = Paint();
    crotchPen.color = Colors.blueGrey; // Colors.blue.shade400;
    crotchPen.style = PaintingStyle.fill;
    crotchPen.strokeWidth = 1.0;

    final platePen = Paint();
    platePen.color = Colors.brown.shade500;
    platePen.style = PaintingStyle.fill;
    platePen.strokeWidth = 2.0;

    final postPen = Paint();
    postPen.color = Colors.amber.shade300;
    postPen.style = PaintingStyle.stroke;
    postPen.strokeWidth = 2.0;
    postPen.strokeCap = StrokeCap.square;

    final tupePen = Paint();
    tupePen.color = Colors.black54;
    tupePen.style = PaintingStyle.fill;
    tupePen.strokeWidth = 4.0;
    tupePen.strokeCap = StrokeCap.square;

    final nosingPen = Paint();
    nosingPen.color = stepColor;
    nosingPen.style = PaintingStyle.stroke;
    nosingPen.strokeWidth = 2.0;
    nosingPen.strokeCap = StrokeCap.square;

    final labelCircle = Paint();
    labelCircle.color = Colors.blueGrey;
    labelCircle.style = PaintingStyle.fill;

    final externCircle = Paint();
    externCircle.color = Colors.red.shade200;
    externCircle.style = PaintingStyle.stroke;
    externCircle.strokeWidth = 2.0;

    final dimensionLabelPen = Paint();
    dimensionLabelPen.color = Colors.black54;
    dimensionLabelPen.style = PaintingStyle.stroke;
    dimensionLabelPen.strokeWidth = 2.0;
    dimensionLabelPen.strokeCap = StrokeCap.round;
    // ---------------------------------------------------------------------
    // ----------------------------- Variables -----------------------------
    double escalonLength = 12.0;
    double sumStairsLength = escalonLength * stairsCount;

    //double bevel = double.parse(data['bevel']);

    double bottomCrotchExtension = 0.0;
    double topCrotchExtension = 0.0;

    List lowerFlatPost = data['lowerFlatPost'];
    List rampPost = data['rampPost'];
    List upperFlatPost = data['upperFlatPost'];

    List nosingStepsList = [];

    double topFlatLength = 16.0;
    double bottomFlatLength = 16.0;

    if (data['bottomCrotch']) {
      bottomFlatLength = double.parse(data['bottomCrotchLength']) + 10;
    }

    if (data['topCrotch']) {
      topFlatLength = double.parse(data['topCrotchLength']) + 10;
    }

    if (upperFlatPost.isNotEmpty) {
      for (var element in upperFlatPost) {
        topCrotchExtension += element.distance;
      }
      topCrotchExtension += 5;
    }

    if (lowerFlatPost.isNotEmpty) {
      for (var element in lowerFlatPost) {
        bottomCrotchExtension += element.distance;
      }
      bottomCrotchExtension += 5;
    }

    double firstEscalonX = size.width / 6.0;

    double factor = (size.width - 2 * firstEscalonX) / sumStairsLength;

    firstEscalonX += 12 * factor;
    // double factor = size.width /
    //     (sumStairsLength +
    //         [16, bottomCrotchExtension, bottomFlatLength].reduce((value, element) => value > element ? value : element) +
    //         [16, topCrotchExtension, topFlatLength].reduce((value, element) => value > element ? value : element));

    //double firstEscalonX = [32, bottomCrotchExtension, bottomFlatLength].reduce((value, element) => value > element ? value : element) * factor;

    double riser = (double.parse(data['riser']) * 6.6875 / 6.75) * factor;
    double bevel = 7.3125 * factor;

    bool hasTopCrotch = data['topCrotch'];
    double topCrotchLength = double.parse(data["topCrotchLength"]) * factor;
    //double topCrotchHeight =  8.0* factor; //double.parse(data["topCrotchHeight"])

    bool hasBottomCrotch = data['bottomCrotch'];
    double bottomCrotchLength =
        double.parse(data["bottomCrotchLength"]) * factor;

    //print(double.parse(data["bottomCrotchLength"]));
    double x = 0.0;
    double y = 0.0;

    double landingHeight = 8.0 * factor;
    double baluster = 6 * factor; //5.9375

    late double lastX;
    late double lastY;

    late List firstNose;

    // Define height for all post
    double postHeight = min(70 * factor, 400);

    double labelHeigth = size.height - 20 * factor;

    double tubePlateY = size.height - landingHeight + factor;

    List postStair = [];
    List postFlatLower = []; // Posts attach to bottom flat part of stair
    List postFlatUpper = []; // Posts attach to top flat part of stair
    List<int> stairs = [];

    // Filter post where step equal to zero
    for (RampPost rp in rampPost) {
      if (rp.step != 0) {
        if (int.parse(rp.step.toString()) <= stairsCount) {
          stairs.add(int.parse(rp.step.toString()));
        }
      }
    }

    double xp = 0.0;
    double px = 0.0;

    List<String> alphabet =
    List.generate(26, (index) => String.fromCharCode(index + 65));

    // ---------------------------------------------------------------------
    // ----------------------------- Functions -----------------------------
    void addLabel(
        {double x = 0.0,
          double y = 0.0,
          String label = '',
          Color couleur = Colors.white,
          Color bgc = Colors.blueGrey,
          double fontS = 8,
          bool nose = true,
          bool dimension = false}) {
      labelCircle.color = bgc;

      late TextStyle textStyle;

      if (nose) {
        textStyle = TextStyle(
          color: Colors.red.shade400,
          fontSize: 15,
        );
      } else {
        textStyle = TextStyle(
          background: Paint()
            ..strokeWidth = 16
            ..color = Colors.blueGrey
            ..strokeJoin = StrokeJoin.round
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
          color: Colors.white,
          fontSize: 10,
        );
      }

      TextSpan textSpan = TextSpan(
        text: label,
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );

      late Offset offset;
      offset = Offset(x, y);

      textPainter.paint(canvas, offset);
    }

    void addTubePlate(double x, double y, String tubePlate) {
      if (tubePlate == "plate") {
        Path plate = Path();
        plate.moveTo(x, y);
        plate.lineTo(x + 2 * factor, y);
        plate.lineTo(x + 2 * factor, y + 4 * factor);
        plate.lineTo(x - 2 * factor, y + 4 * factor);
        plate.lineTo(x - 2 * factor, y);
        plate.close();

        canvas.drawPath(plate, platePen);
      } else if (tubePlate == 'sleeve') {
        Path tube = Path();

        tube.moveTo(x, y - factor);
        tube.lineTo(x + 1 * factor, y - factor);
        tube.lineTo(x + 1 * factor, y + 4 * factor);
        tube.lineTo(x - 1 * factor, y + 4 * factor);
        tube.lineTo(x - 1 * factor, y - factor);
        tube.close();

        canvas.drawPath(tube, tupePen);
      } else {
        Path nonePath = Path();

        nonePath.moveTo(x - 2 * factor, y - factor);
        nonePath.lineTo(x + 2 * factor, y + 2 * factor);

        nonePath.moveTo(x + 2 * factor, y - factor);
        nonePath.lineTo(x - 2 * factor, y + 2 * factor);

        canvas.drawPath(nonePath, externCircle);
      }
    }

    xp = 0.0;
    px = 0.0;

    void addFlatLowerPost(double value, String tubePlate, String label) {
      xp += value;
      px = firstEscalonX - factor - xp;

      labelHeigth = size.height - postHeight - riser + 2 * factor;

      if (value != 0) {
        if (!hasBottomCrotch) {
          Path aPost = Path();
          aPost.moveTo(px, tubePlateY);
          aPost.lineTo(px, size.height - postHeight);

          canvas.drawPath(aPost, postPen);

          addLabel(
              x: px - 6,
              y: labelHeigth + 10 * factor,
              label: label,
              nose: false);
          addTubePlate(px, tubePlateY, tubePlate);

          postFlatLower.add([px, size.height - postHeight]);
        } else {
          if (firstEscalonX - bottomCrotchLength - factor < px) {
            Path aPost = Path();
            aPost.moveTo(px, tubePlateY);
            aPost.lineTo(px, size.height - postHeight);

            canvas.drawPath(aPost, postPen);
            addLabel(
                x: px - 6,
                y: labelHeigth + 10 * factor,
                label: label,
                nose: false);
            addTubePlate(px, tubePlateY, tubePlate);
            // addLabel(x: px + value / 2 - factor, y: labelHeigth, label: alphabet.removeAt(0));
            postFlatLower.add([px, size.height - postHeight]);
          } else {
            //print('nop');
          }
        }
      }
    }

    double xpUp = 0.0;
    void addFlatUpperPost(double value, double lastX, double lastY,
        String tublePlate, String label) {
      xpUp += (value * factor);
      px = lastX + xpUp;

      labelHeigth = size.height - postHeight - lastY + 2 * factor;
      if (value != 0) {
        if (!hasTopCrotch) {
          Path aPost = Path();
          aPost.moveTo(px, size.height - lastY + factor);
          aPost.lineTo(px, size.height - postHeight - lastY + landingHeight);

          canvas.drawPath(aPost, postPen);

          // addLabel(x: px - 6, y: labelHeigth + 10 * factor + landingHeight, label: label, nose: false);
          addLabel(
              x: px - 6,
              y: labelHeigth + 10 * factor,
              label: label,
              nose: false);
          addTubePlate(px, size.height - lastY + factor, tublePlate);

          postFlatUpper
              .add([px, size.height - postHeight - lastY + landingHeight]);
        } else {
          if (xpUp - topCrotchLength < 0) {
            Path aPost = Path();
            aPost.moveTo(px, size.height - lastY);
            aPost.lineTo(px, size.height - postHeight - lastY + landingHeight);
            canvas.drawPath(aPost, postPen);
            // addLabel(x: px - (value * factor) / 2 - factor, y: size.height - lastY - postHeight / 2, label: alphabet.removeAt(0));
            addLabel(
                x: px - 6,
                y: labelHeigth + 10 * factor,
                label: label,
                nose: false);
            addTubePlate(px, size.height - lastY + factor, tublePlate);
            postFlatUpper
                .add([px, size.height - postHeight - lastY + landingHeight]);
          } else {
            //print('nop');
          }
        }
      }
    }

    Path escalera = Path();
    escalera.moveTo(0, size.height);
    escalera.lineTo(0, size.height - landingHeight);
    escalera.lineTo(firstEscalonX, size.height - landingHeight);
    escalera.lineTo(
        firstEscalonX - factor, size.height - (landingHeight + (riser)));

    lastX = firstEscalonX - factor;
    lastY = landingHeight + riser;
    //lastY = size.height; //- (landingHeight);

    firstNose = [
      firstEscalonX - factor,
      size.height - (landingHeight + (riser))
    ];

    if (stairs.contains(1)) {
      postStair.add([lastX, landingHeight + riser]);
    }

    nosingStepsList.add([
      lastX + baluster / 2,
      size.height - landingHeight - riser + baluster / 2
    ]);

    for (int i = 1; i < stairsCount; i++) {
      x = firstEscalonX -
          factor +
          i * (escalonLength * factor) +
          (i - 1) * (-factor);
      y = landingHeight + i * (riser);
      escalera.lineTo(x, size.height - y);

      x = firstEscalonX -
          factor +
          i * (escalonLength * factor) +
          (i) * (-factor);
      y = landingHeight + (i + 1) * (riser);
      escalera.lineTo(x, size.height - y);
      //print(x / factor);

      lastX = x;
      lastY = y;

      nosingStepsList
          .add([lastX + baluster / 2, size.height - lastY + baluster / 2]);

      if (stairs.contains(i + 1)) {
        postStair.add([x, y]);
      }
    }

    // flat up
    y = landingHeight + stairsCount * (riser);
    // double lastxx = firstEscalonX - factor + escalonLength * factor * (stairsCount - 1) - (stairsCount - 1) * factor;
    // print('lastY $lastY | y $y | $lastxx - $lastX  | ${size.width} $factor');
    escalera.lineTo(size.width, size.height - y);
    escalera.lineTo(size.width, size.height - y + landingHeight);
    escalera.lineTo(lastX + baluster, size.height - y + landingHeight);
    escalera.lineTo(firstEscalonX - baluster, size.height);
    escalera.close();

    canvas.drawPath(escalera, stairPenFill);
    canvas.drawPath(escalera, stairPenStk);

    // Top Crotch
    if (hasTopCrotch) {
      Path topCrotch = Path();
      topCrotch.moveTo(lastX + topCrotchLength, size.height - y);
      topCrotch.lineTo(
          lastX + topCrotchLength, size.height - y + landingHeight);
      topCrotch.lineTo(size.width, size.height - y + landingHeight);
      topCrotch.lineTo(size.width, size.height - y);
      topCrotch.close();

      canvas.drawPath(topCrotch, crotchPen);
      canvas.drawPath(topCrotch, stairPenStk);

      // White line Top Crotch
      if (topCrotchLength <= 0) {
        Path lineTC = Path();
        lineTC.moveTo(lastX, size.height - lastY);
        lineTC.lineTo(lastX + factor, size.height - lastY + riser);
        lineTC.lineTo(lastX + max(topCrotchLength, -11.0 * factor),
            size.height - lastY + riser);
        canvas.drawPath(lineTC, whitePen);
      }
    }

    // Bottom Crotch
    if (hasBottomCrotch) {
      Path bottomCrotch = Path();
      bottomCrotch.moveTo(0, size.height);
      bottomCrotch.lineTo(
          firstEscalonX - factor - bottomCrotchLength, size.height);
      bottomCrotch.lineTo(firstEscalonX - factor - bottomCrotchLength,
          size.height - landingHeight);
      bottomCrotch.lineTo(0, size.height - landingHeight);
      bottomCrotch.close();

      canvas.drawPath(bottomCrotch, crotchPen);
      canvas.drawPath(bottomCrotch, stairPenStk);

      // Bottom Crotch Post
      if (data['hasBottomCrotchPost']) {
        Path cP = Path();
        cP.moveTo(firstEscalonX - factor - bottomCrotchLength,
            size.height - landingHeight);
        cP.lineTo(firstEscalonX - factor - bottomCrotchLength,
            size.height - postHeight);

        canvas.drawPath(cP, postPen);
        addLabel(
            x: firstEscalonX - factor - bottomCrotchLength - 6,
            y: size.height - postHeight + 2 * factor + 20,
            nose: false,
            label: 'B${lowerFlatPost.length + 1}');
        //addFlatLowerPost(firstEscalonX - factor - bottomCrotchLength, "sleeve", "B");
      }
      // White line Bottom Crotch
      if (bottomCrotchLength <= baluster - factor) {
        double deltaX = lastX + baluster - (firstEscalonX - factor - baluster);
        double deltaY = lastY - landingHeight;
        double x_ = baluster - bottomCrotchLength - factor;
        double y_ = x_ * deltaY / deltaX;

        Path lineBC = Path();
        lineBC.moveTo(firstEscalonX - baluster, size.height);
        lineBC.lineTo(
            firstEscalonX - factor - bottomCrotchLength, size.height - y_);

        canvas.drawPath(lineBC, whitePen);
      }
    }

    // lower Flat Post
    if (lowerFlatPost.isNotEmpty) {
      for (Post post in lowerFlatPost) {
        addFlatLowerPost(post.distance * factor, post.embeddedType,
            "B${lowerFlatPost.indexOf(post) + 1}");
      }
    }

    // ramp post
    if (postStair.isNotEmpty) {
      int i = 10;

      for (var pt in postStair) {
        canvas.drawLine(
            Offset(pt[0] + baluster, size.height - pt[1] + factor),
            Offset(pt[0] + 6 * factor,
                size.height - pt[1] - postHeight + landingHeight),
            postPen);

        labelHeigth =
            size.height - pt[1] - postHeight + 2 * factor + landingHeight;

        RampPost rpt = rampPost.firstWhere((element) =>
        element.step == stairs[postStair.indexOf(pt)]); // stairs

        addTubePlate(
            pt[0] + baluster, size.height - pt[1] + factor, rpt.embeddedType);

        // Add Label Majuscul letter , Post identifier;
        addLabel(
            x: pt[0] + 5 * factor,
            y: labelHeigth + 20,
            label: alphabet.removeAt(0),
            nose: false);

        Path dimension = Path();
        dimension.moveTo(firstNose[0], firstNose[1]);
        dimension.lineTo(
            firstNose[0] - i * (bevel / 11), firstNose[1] - i * bevel / 6);
        dimension.lineTo(
            pt[0] - i * (bevel / 11), size.height - pt[1] - i * bevel / 6);
        dimension.lineTo(pt[0], size.height - pt[1]);

        canvas.drawPath(dimension, nosingPen);

        i += 6;

        Path dimentionLabelPath = Path();
        dimentionLabelPath.moveTo(pt[0], size.height - pt[1]);
        dimentionLabelPath.lineTo(
            (pt[0] + 12 * (bevel / 11)), size.height - pt[1] + 12 * bevel / 6);
        dimentionLabelPath.lineTo((pt[0] + 12 * (bevel / 11)) + 45,
            size.height - pt[1] + 12 * bevel / 6);

        //canvas.drawPath(dimentionLabelPath, dimensionLabelPen);

        // baluster dimension label

        dimensionLabelBaluster(
            value: rpt.balusterDistance.toString(),
            size: size,
            canvas: canvas,
            offset: Offset(pt[0] + factor, size.height - pt[1] - 4 * factor),
            fontSise: 10,
            color: Colors.black54);

        double dx2 = pt[0] - i * (bevel / 11);
        double dy2 = 10 + size.height - pt[1] - i * bevel / 6;

        double dx1 = firstNose[0] - i * (bevel / 11);
        double dy1 = 10 + firstNose[1] - i * bevel / 6;

        dimensionLabel(
            value: rpt.nosingDistance.toString(),
            size: size,
            offset: const Offset(0, 0),
            dx: dx1 + ((dx1 - dx2).abs() / 2),
            dy: dy1 - ((dy1 - dy2).abs() / 2),
            canvas: canvas,
            angle: 30,
            pen: postPen);
      }
    }
    // Add label Nosing

    if (nosingStepsList.isNotEmpty) {
      for (List step in nosingStepsList) {
        //if (stairStepsList.indexOf(step).isEven) {

        addLabel(
            x: step[0] - min(8 * factor, 40),
            y: step[1] - min(10 * factor, 40),
            label: "${nosingStepsList.indexOf(step) + 1}",
            fontS: 15,
            couleur: Colors.white);
      }
    }
    // upper Flat Post
    if (upperFlatPost.isNotEmpty) {
      for (Post pt in upperFlatPost) {
        if (pt.distance > 0) {
          addFlatUpperPost(pt.distance, lastX, lastY, pt.embeddedType,
              "U${upperFlatPost.indexOf(pt) + 1}");
        }
      }
    }

    // lower Flat Post
    if (postFlatLower.isNotEmpty) {
      if (data['hasBottomCrotchPost']) {
        canvas.drawLine(
            Offset(firstEscalonX - factor - bottomCrotchLength,
                postFlatLower.first[1]),
            Offset(postFlatLower.first[0], postFlatLower.first[1]),
            postPen);
      } else {
        canvas.drawLine(Offset(postFlatLower.first[0], postFlatLower.first[1]),
            Offset(postFlatLower.last[0], postFlatLower.last[1]), postPen);
      }
    }

    if (postFlatUpper.isNotEmpty) {
      canvas.drawLine(Offset(postFlatUpper.first[0], postFlatUpper.first[1]),
          Offset(postFlatUpper.last[0], postFlatUpper.last[1]), postPen);
    }

    if (postFlatLower.isNotEmpty && postFlatUpper.isNotEmpty) {
      Path fullPath = Path();
      fullPath.moveTo(postFlatLower.last[0], postFlatLower.last[1]);
      fullPath.lineTo(firstEscalonX - baluster, postFlatLower.first[1]);
      fullPath.lineTo(
          lastX + baluster, size.height - lastY - postHeight + landingHeight);
      fullPath.lineTo(postFlatUpper.first[0], postFlatUpper.first[1]);
      canvas.drawPath(fullPath, postPen);
    } else {
      if (postStair.isNotEmpty) {
        canvas.drawLine(
            Offset(postStair.first[0] + baluster,
                size.height - postStair.first[1] - postHeight + landingHeight),
            Offset(postStair.last[0] + baluster,
                size.height - postStair.last[1] - postHeight + landingHeight),
            postPen);
      }
      //Join bottom flat post rail to thread rail
      if (postFlatLower.isNotEmpty && postStair.isNotEmpty) {
        Path frPath = Path();
        frPath.moveTo(postFlatLower.last[0], postFlatLower.last[1]);
        frPath.lineTo(firstEscalonX - baluster, postFlatLower.first[1]);
        frPath.lineTo(postStair.first[0] + baluster,
            size.height - postStair.first[1] - postHeight + landingHeight);

        canvas.drawPath(frPath, postPen);
      }

      // Join top flat post rail to thread rail
      if (postFlatUpper.isNotEmpty && postStair.isNotEmpty) {
        Path rfPath = Path();
        rfPath.moveTo(postStair.last[0] + baluster,
            size.height - postStair.last[1] - postHeight + landingHeight);
        rfPath.lineTo(
            lastX + baluster, size.height - lastY - postHeight + landingHeight);
        rfPath.lineTo(postFlatUpper.first[0], postFlatUpper.first[1]);
        canvas.drawPath(rfPath, postPen);
      }
    }
  }

  void dimensionLabel(
      {required String value,
        required Size size,
        required Canvas canvas,
        required Offset offset,
        double fontSise = 15.0,
        Color color = Colors.red,
        double angle = 0,
        double bevel = 7.3125,
        required double dx,
        required double dy,
        required Paint pen}) {
    canvas.save();
    canvas.translate(dx, dy + 7.5);

    angle = atan(bevel / 12);

    canvas.rotate(-angle);

    TextStyle textStyle = TextStyle(
        color: Colors.red[400], fontSize: 15, backgroundColor: Colors.white);
    TextSpan textSpan = TextSpan(
      text: "  $value\u{00A0}\u{00A0}",
      style: textStyle,
    );

    TextPainter(text: textSpan, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: size.width)
      ..paint(canvas, offset);

    canvas.restore();
  }

  void dimensionLabelBaluster(
      {required String value,
        required Size size,
        required Canvas canvas,
        required Offset offset,
        double fontSise = 15.0,
        Color color = Colors.red}) {
    TextStyle textStyle = TextStyle(
        color: color, fontSize: fontSise, backgroundColor: Colors.white);
    final textSpan = TextSpan(text: value, style: textStyle);
    TextPainter(text: textSpan, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: size.width)
      ..paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
