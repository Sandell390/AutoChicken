import 'package:flutter/material.dart';
import 'package:auto_chicken_app/Home/Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//List of the sensors as named in Firebase Database.
List<String> dbWarningsList = [
  "WaterBowlHeater",
  "WaterBowlTempSensor",
  "WaterMinimumSwitch",
  "WaterPumpOrLevel",
  "WaterReservoirHeater",
  "WaterReservoirTempSensor"
];

class WarningsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 142, 127, 62),
        title: Text(
          'Warnings',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Color.fromARGB(255, 237, 212, 103),
      //Connection to firebase, to update the app's warnings when the values update in the database.
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('/AutoChicken').snapshots(),
        builder: ((context, snapshot) {
          if (!snapshot.hasData) return const Text('Loading');
          return ListView(
            padding: EdgeInsets.all(8),
            children: <Widget>[
              Container(
                  //Changes the height to correspond with the mobile devices orientation. (Landscape/Portrait)
                  height: MediaQuery.of(context).orientation ==
                          Orientation.landscape
                      ? MediaQuery.of(context).size.height / 1.45
                      : MediaQuery.of(context).size.height / 1.2,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black87,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 5, bottom: 20),
                        child: Center(
                            //This container is the headline in the Warnings section.
                            child: Text(
                                style: TextStyle(
                                    color: Color.fromARGB(255, 52, 52, 52),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 2),
                                'Active warnings')),
                      ),
                      //The building of the sensor sections on the warnings page.
                      _defaultWarningsSection(
                          'Waterbowl heater: \n',
                          snapshot.data!.docs[0][dbWarningsList[0]],
                          0,
                          context),
                      Expanded(child: Container()),
                      _defaultWarningsSection(
                          'Waterbowl temperature \nsensor: \n',
                          snapshot.data!.docs[0][dbWarningsList[1]],
                          1,
                          context),
                      Expanded(child: Container()),
                      _defaultWarningsSection(
                          'Waterbowl minimum \nswitch: \n',
                          snapshot.data!.docs[0][dbWarningsList[2]],
                          2,
                          context),
                      Expanded(child: Container()),
                      _defaultWarningsSection(
                          'Waterbowl pump \nor level sensor: \n',
                          snapshot.data!.docs[0][dbWarningsList[3]],
                          3,
                          context),
                      Expanded(child: Container()),
                      _defaultWarningsSection(
                          'Waterreservoir heater: \n',
                          snapshot.data!.docs[0][dbWarningsList[4]],
                          4,
                          context),
                      Expanded(child: Container()),
                      _defaultWarningsSection(
                          'Waterreservoir \ntemperature sensor: \n',
                          snapshot.data!.docs[0][dbWarningsList[5]],
                          5,
                          context),
                      Expanded(child: Container()),
                    ],
                  )),
            ],
          );
        }),
      ));
}

//Method to build each warning section, this tells if the sensor is funtioning or not, if not the section goes red, says "ERROR" and a button apears to reset the warning.
//This is ment for after a replacement of the defective sensor.
//If the warning is not active, the text is black and no button will apear.
Row _defaultWarningsSection(String text, bool activeStatus,
    int dbWarningsNumber, BuildContext context) {
  return Row(
    children: [
      Text(
          style: TextStyle(
            color: activeStatus == false
                ? Color.fromARGB(255, 52, 52, 52)
                : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          text + (activeStatus == false ? 'OK' : 'ERROR')),
      Expanded(child: Container()),
      activeStatus == false
          ? Container()
          : TextButton(
              style: TextButton.styleFrom(
                  padding: EdgeInsets.all(10),
                  textStyle: TextStyle(fontSize: 16),
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 142, 127, 62)),
              onPressed: () => PostDialog(context, dbWarningsNumber),
              child: Text('Reset Error'))
    ],
  );
}

//Method for reseting the warning in the firestore database corresponding the the pushed button.
Future WarningReset(int warningToReset) async {
  final warningsReset =
      FirebaseFirestore.instance.collection('/AutoChicken').doc('Warnings');
  final json = {
    '${dbWarningsList[warningToReset]}': false,
  };
  await warningsReset.update(json);
}

//Method for a post dialog that pops up when "Reset ERROR" is pushed, to ensure the that something actively have been done to fix the error and
PostDialog(BuildContext context, int warningToReset) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: ((context) => AlertDialog(
          backgroundColor: Color.fromARGB(255, 25, 27, 43),
          elevation: 20,
          title: const Text(
              "You are about to reset an error.\nHave the error been fixed?",
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                WarningReset(warningToReset);
                const snackBar = SnackBar(
                  content: Text('Error has been reset.'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
              child: const Text(
                "Yes",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                print("nej");
                Navigator.of(context).pop();
              },
              child: const Text(
                "No",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        )),
  );
}
