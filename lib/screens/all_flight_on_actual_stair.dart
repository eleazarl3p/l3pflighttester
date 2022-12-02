import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/flight_map.dart';
import '/screens/flight_editor.dart';

import '../models/Projects.dart';
import '../models/flight.dart';

class FlightOnActualStair extends StatefulWidget {
  FlightOnActualStair(
      {Key? key,
      required this.pIndex,
      required this.sIndex,
      this.cloud = false})
      : super(key: key);
  int pIndex;
  int sIndex;
  List<bool> selected = [];
  final bool cloud;

  @override
  State<FlightOnActualStair> createState() => _FlightOnActualStairState();
}

class _FlightOnActualStairState extends State<FlightOnActualStair> {
  @override
  Widget build(BuildContext context) {
    final currentStair =
        context.watch<Projects>().projects[widget.pIndex].stairs[widget.sIndex];

    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text(
            'Stair : ${currentStair.id}',
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: widget.cloud
              ? const Text('Cloud > Project > Stair',
                  style: TextStyle(color: Colors.white))
              : const Text('Local > Projects > Stair',
                  style: TextStyle(color: Colors.white)),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
              backgroundBlendMode: BlendMode.colorBurn, color: Colors.white12),
          child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(
                  thickness: 3.0,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(width: 2.0, color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              // const Center(
                              //   child: Text("Project > Stairs > Flights"),
                              // ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(10.0),
                                  itemCount: currentStair.flights.length,
                                  itemBuilder: ((context, index) {
                                    return Card(
                                      //color: Colors.brown.shade100,

                                      child: ListTile(
                                        leading: SizedBox(
                                          width: 200,
                                          child: TextField(
                                            autofocus: true,
                                            decoration: const InputDecoration(
                                              labelText: "Flight Id",
                                              isDense: true,
                                              contentPadding: EdgeInsets.all(8),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 1.0,
                                                    color: Colors.blueGrey),
                                              ),
                                            ),
                                            controller: TextEditingController(
                                                text: currentStair
                                                    .flights[index].id),
                                            onChanged: (value) {
                                              currentStair.flights[index].id =
                                                  value;
                                            },
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () {
                                                Flight flt =
                                                    currentStair.flights[index];
                                                setState(() {
                                                  currentStair.addFlight(
                                                    Flight.copy(flt),
                                                  );
                                                });
                                              },
                                              icon: const Icon(Icons.copy),
                                              label: const Text('Copy'),
                                            ),
                                            TextButton.icon(
                                                onPressed: () {
                                                  FlightMap fmap =
                                                      Provider.of<FlightMap>(
                                                          context,
                                                          listen: false);
                                                  fmap.updateMap(currentStair
                                                      .flights[index]);
                                                  //print(fmap.textFormFields);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          FlightEditor(
                                                        pIndex: widget.pIndex,
                                                        sIndex: widget.sIndex,
                                                        fIndex: index,
                                                        cloud: widget.cloud,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.edit),
                                                label: const Text('Edit')),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            TextButton.icon(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.red),
                                                foregroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.white),
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          "Are you sure you want to delete this flight?"),
                                                      content: Text(
                                                          'Flight id: ${currentStair.flights[index].id}'),
                                                      actions: [
                                                        TextButton.icon(
                                                          onPressed: () {
                                                            setState(
                                                              () {
                                                                currentStair.removeFlight(
                                                                    currentStair
                                                                            .flights[
                                                                        index]);
                                                              },
                                                            );

                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          icon: const Icon(
                                                              Icons.check),
                                                          label:
                                                              const Text("Yes"),
                                                        ),
                                                        TextButton.icon(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          icon: const Icon(
                                                              Icons.cancel),
                                                          label:
                                                              const Text("No"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );


                                              },
                                              icon: const Icon(Icons.delete),
                                              label: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      currentStair.addFlight(Flight());
                                    });
                                  },
                                  icon: const Icon(Icons.stairs_outlined),
                                  label: const Text("Add Flight"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
