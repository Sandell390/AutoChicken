import 'dart:developer';
import 'package:auto_chicken_app/screens/Warnings.dart';
import 'package:auto_chicken_app/screens/Water.dart';
import 'package:flutter/material.dart';
import 'package:auto_chicken_app/details/dropdown_menu_item.dart';
import 'package:auto_chicken_app/models/dropdown_menu_items.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  //List of the sensors as named in Firebase Database.
  List<String> dbSensorWarningsArray = [
    "WaterBowlHeater",
    "WaterBowlTempSensor",
    "WaterMinimumSwitch",
    "WaterPumpOrLevel",
    "WaterReservoirHeater",
    "WaterReservoirTempSensor"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 237, 212, 103),
      appBar: _buildAppbar(context),
      body: Column(
        children: [
          //this Container is just the headline of the homepage.
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            alignment: Alignment.center,
            child: Text(
              'INFO',
              style: TextStyle(
                color: Color.fromARGB(255, 52, 52, 52),
                fontWeight: FontWeight.bold,
                fontSize: 36,
              ),
            ),
          ),
          //Connection to firebase, to update the app's data when the values update in the database.
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('/AutoChicken')
                .snapshots(),
            builder: ((context, snapshot) {
              if (!snapshot.hasData) return const Text('Loading');
              return Expanded(
                child: Column(
                  children: [
                    //The main info section at the homepage.
                    _defaultwarningsHomepage(
                        'assets/images/WarningIcon.png',
                        'Warnings: ${CountActivewarnings(snapshot).toString()}',
                        CountActivewarnings(snapshot)),
                    Expanded(child: Container()),
                    _defaultSectionHomepage('assets/images/WaterIcon.png',
                        'Water temp: ${(snapshot.data!.docs[2]['WaterReservoirTempValue']).toString()}° C'),
                    Expanded(child: Container()),
                    _defaultSectionHomepage(
                        'assets/images/HumidityIcon.png', 'Humidity: 60%'),
                    Expanded(child: Container()),
                    _defaultSectionHomepage(
                        'assets/images/ThermometorIcon.png', 'Air Temp: 20° C'),
                    Expanded(child: Container()),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  //Method to count the warnings that are active at the moment.
  int CountActivewarnings(AsyncSnapshot snapshot) {
    int warningTypesCount =
        (snapshot.data!.docs[0].data() as Map<String, dynamic>)
            .keys
            .toList()
            .length;
    int activeCount = 0;

    for (var i = 0; i < warningTypesCount; i++) {
      if (snapshot.data!.docs[0][dbSensorWarningsArray[i]] == true) {
        activeCount++;
      }
    }
    return activeCount;
  }

  //Method to create each standard section of info at the homepage.
  Container _defaultSectionHomepage(String iconPath, String text) {
    return Container(
      child: Row(children: [
        Container(
          height: 100,
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child:
                Image.asset(iconPath, color: Color.fromARGB(255, 52, 52, 52)),
          ),
        ),
        Text(
            style: TextStyle(
              color: Color.fromARGB(255, 52, 52, 52),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            text)
      ]),
    );
  }

  //Method to create the warnings section on the homepage, this section is black when zero warnings are active and red if there are one og more warnings active.
  Container _defaultwarningsHomepage(
      String iconPath, String text, int activeWarnings) {
    return Container(
      child: Row(children: [
        Container(
          height: 100,
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(iconPath,
                color: activeWarnings > 0
                    ? Colors.red
                    : Color.fromARGB(255, 52, 52, 52)),
          ),
        ),
        Text(
            style: TextStyle(
              color: activeWarnings > 0
                  ? Colors.red
                  : Color.fromARGB(255, 52, 52, 52),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            text)
      ]),
    );
  }

  //Method to build the navbar, with the logo to the left and the dropdown menu to the right.
  AppBar _buildAppbar(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromARGB(255, 142, 127, 62),
      elevation: 0,
      title: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/Logo.png'),
            ),
          ),
          SizedBox(width: 10),
          Text(
            '',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(child: Container()),
          Row(
            children: [
              Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        //Building the dropdown menu with the different menu options.
        PopupMenuButton<HGDropdownMenuItem>(
          color: Colors.white,
          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          itemBuilder: (context) => [
            ...DropdownMenuItems.itemsWater.map(buildItem).toList(),
            ...DropdownMenuItems.itemsFood.map(buildItem).toList(),
            ...DropdownMenuItems.itemsLight.map(buildItem).toList(),
            ...DropdownMenuItems.itemsTemperature.map(buildItem).toList(),
            ...DropdownMenuItems.itemsChecklist.map(buildItem).toList(),
            ...DropdownMenuItems.itemsWarnings.map(buildItem).toList(),
          ],
          onSelected: (item) => onClicked(context, item),
        ),
      ],
    );
  }
}

//The styling of each option in the dropdown menu,
PopupMenuItem<HGDropdownMenuItem> buildItem(HGDropdownMenuItem item) =>
    PopupMenuItem<HGDropdownMenuItem>(
      value: item,
      child: Container(
        child: Row(
          children: [
            item.icon,
            const SizedBox(width: 10),
            Text(
              item.text,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
//Method for the push of each menu option, this method routes to a different page corresponding to the pushed item.
void onClicked(BuildContext context, HGDropdownMenuItem item) {
  switch (item) {
    case DropdownMenuItems.itemWater:
      log('Settings Pushed');
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => WaterPage()),
      );
      break;
    case DropdownMenuItems.itemWarnings:
      log('Settings Pushed');
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => WarningsPage()),
      );
      break;
    default:
  }
}
