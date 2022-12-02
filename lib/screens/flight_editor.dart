import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/models/project.dart';
import 'package:provider/provider.dart';
import '../models/Projects.dart';
import '/Utils/flight_data_input.dart';
import '/models/flight.dart';

import '../Utils/cuadro.dart';
import '../Utils/cuadro_on_dev.dart';
import '../Utils/flight_data_input_on_dev.dart';
import '../Utils/stair_painter.dart';
import '../models/flight_map.dart';

class FlightEditor extends StatelessWidget {
  FlightEditor(
      {Key? key,
      required this.pIndex,
      required this.sIndex,
      required this.fIndex,
      this.cloud = false})
      : super(key: key);

  int pIndex;
  int sIndex;
  int fIndex;
  bool cloud;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Text(''),
        title: ListTile(
          title:  Text(
            'Flight : ${Provider.of<Projects>(context).projects[pIndex].stairs[sIndex].flights[fIndex].id}',
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: cloud
              ? const Text('Cloud > Project > Stair > FLight',
              style: TextStyle(color: Colors.white))
              : const Text('Local > Projects > Stair > FLight',
              style: TextStyle(color: Colors.white)),
        ),
        centerTitle: true,
      ),
      body: Row(children: [
        const Expanded(
          //flex: 2,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Cuadro(),
          ),
        ),
        SizedBox(
          width: 400.0,
          child: FlightDataInput(
            pIndex: pIndex,
            sIndex: sIndex,
            fIndex: fIndex,
            cloud: cloud,
          ),
        ),
      ]),
    );
    // );
  }
}
