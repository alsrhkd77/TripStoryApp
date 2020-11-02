// This example shows a [Scaffold] with an [AppBar], a [BottomAppBar] and a
// [FloatingActionButton]. The [body] is a [Text] placed in a [Center] in order
// to center the text within the [Scaffold]. The [FloatingActionButton] is
// centered and docked within the [BottomAppBar] using
// [FloatingActionButtonLocation.centerDocked]. The [FloatingActionButton] is
// connected to a callback that increments a counter.
//
// ![](https://flutter.github.io/assets-for-api-docs/assets/material/scaffold_bottom_app_bar.png)

import 'package:flutter/material.dart';
import 'package:trip_story/page/blank_page.dart';
import 'package:trip_story/page/login_page.dart';
import 'package:trip_story/page/make_post_page.dart';
import 'package:trip_story/page/make_trip_page.dart';
import 'package:trip_story/page/map_sample.dart';
import 'package:trip_story/page/newsFeed_page.dart';
import 'package:trip_story/page/sign_up_page.dart';
import 'package:trip_story/page/user_page.dart';
import 'package:trip_story/utils/blank_appbar.dart';

void main() => runApp(MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Trip Story';

  @override
  Widget build(BuildContext context) {
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

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlankAppbar(),
      body: TabBarView(
        controller: tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          NewsFeedPage(),
          TempPage(),
          BlankPage(),
          TempPage(),
          UserPage(),
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
              SizedBox(width: MediaQuery.of(context).size.width / 5,),
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
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => MakePostPage()));
        }),
        tooltip: '새 게시글 작성',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

//임시 페이지
class TempPage extends StatefulWidget {
  @override
  _TempPageState createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Hello World!'),
    );
  }
}
