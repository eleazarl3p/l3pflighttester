import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../file_storage_manager/secretaria.dart';
import '/models/flight_map.dart';
import '/screens/flight_editor.dart';
import '../widget/CustomActionButton.dart';
import '../models/Projects.dart';
import '../models/flight.dart';

class FlightOnActualStair extends StatefulWidget {
  FlightOnActualStair({Key? key, required this.pIndex, required this.sIndex, this.cloud = false}) : super(key: key);
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
    final currentStair = context
        .watch<Projects>()
        .projects[widget.pIndex].stairs[widget.sIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FLIGHTS'),
        //centerTitle: true,
        actions: [
          CustomActionButton(
            txt: 'Add Flight',
            onPressed: () {
              setState(() {
                currentStair.addFlight(Flight());
              });
            },
          ),
          CustomActionButton(
              txt: "Save",
              onPressed: () async {
                await OurDataStorage.writeDocument(
                    "MyProjects", Provider.of<Projects>(context, listen: false).toJson()).then((value) =>
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(milliseconds: 1000),
                        content: const Text('Saved!'),
                        backgroundColor: Colors.blueGrey.shade400,
                      ),
                    ));
              }),
          const SizedBox(
            width: 25.0,
          )
        ],
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          height: 50.0,
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Project : ',
                    style: kLabel600,
                  ),
                  Text(
                    '${Provider
                        .of<Projects>(context, listen: false)
                        .projects[widget.pIndex].id} >',
                    style: kLabelStyle,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'Stair : ',
                    style: kLabel600,
                  ),
                  Text(
                    '${Provider
                        .of<Projects>(context, listen: false)
                        .projects[widget.pIndex].stairs[widget.sIndex].id}',
                    style: kLabelStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 13.0),
          child: const Divider(),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(15),

            //padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              //color: Colors.grey[200],
              border: Border.all(width: 2.0, color: Colors.blueGrey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
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
                                  borderSide: BorderSide(width: 1.0, color: Colors.blueGrey),
                                ),
                              ),
                              controller: currentStair.flights[index].controller,
                              onChanged: (value) {
                                currentStair.flights[index].id = value;
                              },
                              onTap: () =>
                              currentStair.flights[index].controller.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: currentStair.flights[index].controller.value.text.length),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Flight flt = currentStair.flights[index];
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
                                    // FlightMap fmap = Provider.of<FlightMap>(context, listen: false);
                                    // fmap.updateMap(currentStair.flights[index]);
                                    // print(fmap.te.runtimeType);

                                    Map<String, dynamic> template = Provider
                                        .of<Projects>(context, listen: false)
                                        .projects[widget.pIndex]
                                        .stairs[widget.sIndex]
                                        .flights[index]
                                        .template();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FlightEditor(
                                              pIndex: widget.pIndex,
                                              sIndex: widget.sIndex,
                                              fIndex: index,
                                              template: template,
                                            ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Open')),
                              const SizedBox(
                                width: 10,
                              ),
                              TextButton.icon(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.red),
                                  foregroundColor: MaterialStateProperty.all(Colors.white),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Are you sure you want to delete this flight?"),
                                        content: Text('Flight id: ${currentStair.flights[index].id}'),
                                        actions: [
                                          TextButton.icon(
                                            onPressed: () {
                                              setState(
                                                    () {
                                                  currentStair.removeFlight(currentStair.flights[index]);
                                                },
                                              );

                                              Navigator.pop(context);
                                            },
                                            icon: const Icon(Icons.check),
                                            label: const Text("Yes"),
                                          ),
                                          TextButton.icon(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            icon: const Icon(Icons.cancel),
                                            label: const Text("No"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.delete),
                                label: Container(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: const Text(
                                      'Delete',
                                    )),
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
      ]),
    );
  }
}
