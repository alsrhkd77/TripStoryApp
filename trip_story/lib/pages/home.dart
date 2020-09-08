import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tripstory/modules/UtilityModule.dart';
import 'package:tripstory/modules/GoogleSignIn.dart';
import 'package:tripstory/modules/custom_float.dart';
import 'package:tripstory/pages/makePost.dart';
import 'package:tripstory/pages/maps.dart';
import 'package:tripstory/pages/newsFeed.dart';
import 'package:tripstory/modules/UserInfo.dart';
import 'package:tripstory/modules/blank_appbar.dart';
import 'package:tripstory/pages/tagSelect.dart';
import 'package:tripstory/pages/userPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController tabCtr;
  Size deviceSize;

  @override
  void initState() {
    super.initState();
    tabCtr = new TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    tabCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: BlankAppbar(),
        body: new TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            NewsFeed(),
            TempPage(),
            TempPage(),
            MapSample(),
            UserPage()
          ],
          controller: tabCtr,
        ),
        floatingActionButton: CustomFloat(
          builder: true
              ? Text(
                  "",
                  style: TextStyle(color: Colors.white, fontSize: 10.0),
                )
              : null,
          icon: Icons.add,
          qrCallback: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TagSelect()));
          },
        ),
        floatingActionButtonLocation: true
            ? FloatingActionButtonLocation.centerDocked
            : FloatingActionButtonLocation.endFloat,
        /*FloatingActionButton(onPressed: () async {
        //GoogleSignInState google = new GoogleSignInState();
        //google.doPost(UserInfo().getUserName());
        //ControlFile f_ctr = new ControlFile();
        //await f_ctr.loadImageList();
        //var f = await f_ctr.getImage();
        //f_ctr.UploadFile(f);
        UserInfo().clearExit();
      }, child: Icon(Icons.add), backgroundColor: Colors.lightBlue,), */
        bottomNavigationBar: new BottomAppBar(
            clipBehavior: Clip.antiAlias,
            shape: CircularNotchedRectangle(),
            child: Ink(
              height: 50.0,
              decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [Colors.blueAccent, Colors.indigoAccent])),
              child: TabBar(
                tabs: <Widget>[
                  Tab(
                    icon: new Icon(Icons.home),
                  ),
                  Tab(
                    icon: new Icon(Icons.favorite),
                  ),
                  SizedBox(
                    width: deviceSize.width / 5,
                  ),
                  Tab(
                    icon: new Icon(Icons.people),
                  ),
                  Tab(
                    icon: new Icon(Icons.account_box),
                  ),
                ],
                controller: tabCtr,
              ),
            )));
  }
}

//아래 필요없음 지울 것

class TempPage extends StatefulWidget {
  @override
  _TempPageState createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Text(UserInfo().getUserName()),
    );
  }
}
