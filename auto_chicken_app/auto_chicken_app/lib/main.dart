import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_chicken_app/Home/Home.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent)
      );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ScrumBoard',
      home: HomePage(),
    );
  }
}
