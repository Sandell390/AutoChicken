import 'dart:developer';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 237, 212, 103),
      appBar: _buildAppbar(context),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            alignment: Alignment.center,
            child: Text(
              'INFO',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 36,
              ),
            ),
          ),
          Container(
            height: 100,
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/WaterIcon.png'),
            ),
          ),
          Container(
            height: 100,
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/HumidityIcon.png'),
            ),
          ),
          Container(
            height: 100,
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/ThermometorIcon.png'),
            ),
          ),
        ],
        ),
        
    );
  }
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
          Text('',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,),
          ),
          Expanded(child: Container()),
          Row(
        children: [
          Text('Menu',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 20,
            fontWeight: FontWeight.bold,),
          ),
          Container(
            height: 20,
            width: 20,
              child: Icon(Icons.menu),
          ),
        ],
      ),
        ],
      ),
      actions: [
      ],
    );
  }
}

  