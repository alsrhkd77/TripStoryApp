import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripstory/pages/home.dart';
import 'package:tripstory/pages/loadingPage.dart';
import 'package:tripstory/pages/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trip Story',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage()
    );
  }
}

