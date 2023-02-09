import 'package:flutter/material.dart';
import 'package:auto_chicken_app/Home/Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 142, 127, 62),
        title: Text(
          'Water',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Color.fromARGB(255, 237, 212, 103),
      //Connection to firebase, to update the app's data when the values update in the database.
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
                      : MediaQuery.of(context).size.height / 2.5,
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
                            child: Text(
                                style: TextStyle(
                                    color: Color.fromARGB(255, 52, 52, 52),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 2),
                                'Water reservoir')),
                      ),
                      //Info for the water reservoir.
                      //This section is to create each section of the info from the water reservoir.
                      _defaultTextWater(snapshot.data!.docs[2]
                                  ['WaterReservoirHeaterOn'] ==
                              true
                          ? 'The heater is: On'
                          : 'The heater is: Off'),
                      Expanded(child: Container()),
                      _defaultTextWater(snapshot.data!.docs[2]
                                  ['WaterReservoirMinimumLevel'] ==
                              false
                          ? 'Water level is: OK'
                          : 'Water level is: Needs to be filled'),
                      Expanded(child: Container()),
                      _defaultTextWater(
                          snapshot.data!.docs[2]['WaterReservoirPumpOn'] == true
                              ? 'The waterpump is: On'
                              : 'The waterpump is: Off'),
                      Expanded(child: Container()),
                      _defaultTextWater(
                          'Water temp: ${(snapshot.data!.docs[2]['WaterReservoirTempValue']).toString()}° C'),
                      Expanded(child: Container()),
                    ],
                    //End of the water reservoir.
                  )),
              Container(
                  //Changes the height to correspond with the mobile devices orientation. (Landscape/Portrait)
                  height: MediaQuery.of(context).orientation ==
                          Orientation.landscape
                      ? MediaQuery.of(context).size.height / 1.45
                      : MediaQuery.of(context).size.height / 2.5,
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
                            child: Text(
                                style: TextStyle(
                                    color: Color.fromARGB(255, 52, 52, 52),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 2),
                                'Water bowl')),
                      ),
                      //Info for the water bowl.
                      //This section is to create each section of the info from the water reservoir.
                      _defaultTextWater(
                          snapshot.data!.docs[1]['WaterBowlHeaterOn'] == true
                              ? 'The heater is: On'
                              : 'The heater is: Off'),
                      Expanded(child: Container()),
                      _defaultTextWater(
                          snapshot.data!.docs[1]['WaterBowlLevelValue'] > 10
                              ? 'The waterlevel is: OK'
                              : 'The waterlevel is: LOW'),
                      Expanded(child: Container()),
                      _defaultTextWater(
                          'Water temp: ${(snapshot.data!.docs[1]['WaterBowlTempValue']).toString()}° C'),
                      Expanded(child: Container()),
                    ],
                    //End of the water reservoir.
                  ))
            ],
          );
        }),
      ));
}

//Method to style sections of the water page.
Text _defaultTextWater(String text) {
  return Text(
      style: TextStyle(
        color: Color.fromARGB(255, 52, 52, 52),
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      text);
}
