import 'package:flutter/material.dart';
import 'package:trip_story/page/login_page.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('설정'),),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          InkWell(
            child: ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('로그아웃'),
            ),
            onTap: (){
              Navigator.pushAndRemoveUntil(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => LoginPage()),
                      (route) => false);
            },
          )
        ],
      ),
    );
  }
}
