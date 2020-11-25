// ![](https://flutter.github.io/assets-for-api-docs/assets/material/scaffold_bottom_app_bar.png)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission/permission.dart';
import 'package:trip_story/common/blank_appbar.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/page/blank_page.dart';
import 'package:trip_story/page/edit_post_page.dart';
import 'package:trip_story/page/login_page.dart';
import 'package:trip_story/page/peripheral_search_page.dart';
import 'package:trip_story/page/search_page.dart';
import 'package:trip_story/page/timeline_page.dart';
import 'package:trip_story/page/user_page.dart';

void main() => runApp(MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Trip Story';

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      title: _title,
      home: LoginPage(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MainStatefulWidget extends StatefulWidget {
  MainStatefulWidget({Key key}) : super(key: key);

  @override
  _MainStatefulWidgetState createState() => _MainStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MainStatefulWidgetState extends State<MainStatefulWidget>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  List<Permissions> _permissions;

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 5, vsync: this);
    _getPermission();
  }

  _getPermission() async {
    List<Permissions> temp = await Permission.requestPermissions([
      PermissionName.Internet,
      PermissionName.Storage,
      PermissionName.Location
    ]);
    setState(() {
      _permissions = temp;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: BlankAppbar(),
      body: TabBarView(
        controller: tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          TimeLinePage(),
          SearchPage(
            type: 'main',
          ),
          BlankPage(),
          PeripheralSearchPage(),
          UserPage(
            type: 'main',
            nickName: Owner().nickName,
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
          child: TabBar(
            physics: NeverScrollableScrollPhysics(),
            controller: tabController,
            tabs: [
              Tab(
                icon: new Icon(
                  Icons.home,
                  color: Colors.black26,
                ),
              ),
              Tab(
                icon: new Icon(
                  Icons.search,
                  color: Colors.black26,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 5,
              ),
              Tab(
                icon: new Icon(
                  Icons.where_to_vote_outlined,
                  color: Colors.black26,
                ),
              ),
              Tab(
                icon: new Icon(
                  Icons.account_box,
                  color: Colors.black26,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'makePost',
        onPressed: () => setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => EditPostPage()));
        }),
        tooltip: '새 게시글 작성',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
