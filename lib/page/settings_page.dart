import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_story/page/login_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('auto', false);
              prefs.setString('type', '');
              prefs.setString('id', '');
              prefs.setString('pw', '');
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
