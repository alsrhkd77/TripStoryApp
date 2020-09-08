import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tripstory/modules/FeedValue.dart';
import 'package:tripstory/modules/URLBook.dart';
import 'package:tripstory/modules/UserInfo.dart';
import 'package:tripstory/modules/UtilityModule.dart';
import 'package:tripstory/modules/blank_appbar.dart';
import 'package:tripstory/pages/feedInfo.dart';
import 'package:tripstory/pages/login.dart';
import 'package:tripstory/pages/viewPost.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Size deviceSize;
  String view = "grid";
  int postCount = 0;
  UtilityModule connector = new UtilityModule();

  Widget profileHeader() => Container(
        width: deviceSize.width / 5,
        child: Padding(
          padding: const EdgeInsets.all(1),
          //const EdgeInsets.symmetric(horizontal: 30),
          child: FittedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(110.0),
                      border: Border.all(width: 2.0, color: Colors.lightBlue)),
                  child: CircleAvatar(
                    radius: 100.0,
                    backgroundImage: NetworkImage(
                        URLBook.default_profile),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
                Text(
                  UserInfo().getUserName(),
                  style: TextStyle(fontSize: 50.0),
                ),
                //Text(UserInfo().getUserEmail(),)
              ],
            ),
          ),
        ),
      );

  Widget profileContents() => Container(
        width: deviceSize.width * 3 / 5,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '?',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                    ),
                    Text(
                      "팔로잉",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "?",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                    ),
                    Text(
                      "팔로워",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      postCount.toString(),
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                    ),
                    Text(
                      "게시물",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ]),
        ),
      );

  Widget profile() => Container(
        height: deviceSize.height / 3.5,
        width: double.infinity,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Card(
                clipBehavior: Clip.antiAlias,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    profileHeader(),
                    profileContents(),
                  ],
                ))),
      );

  Row buildImageViewButtonBar() {
    Color isActiveButtonColor(String viewName) {
      if (view == viewName) {
        return Colors.blueAccent;
      } else {
        return Colors.black26;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.apps, color: isActiveButtonColor("grid")),
          onPressed: () {
            changeView("grid");
          },
        ),
        IconButton(
          icon: Icon(Icons.assistant_photo, color: isActiveButtonColor("feed")),
          onPressed: () {
            changeView("feed");
          },
        ),
      ],
    );
  }

  changeView(String viewName) {
    setState(() {
      view = viewName;
    });
  }

  Widget bodyData() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OutlineButton(
              child: Text("로그아웃"),
              onPressed: () {
                UserInfo().clearLogout();
                Navigator.pushAndRemoveUntil(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage()),
                    (route) => false);
              },
            ),
            profile(),
            SizedBox(
              width: double.infinity,
              child: buildImageViewButtonBar(),
            ),
            new Padding(padding: EdgeInsets.all(5)),
            buildUserPosts(),
            //followColumn(deviceSize),
            //imagesCard(),
            //postCard(),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: new BlankAppbar(),
      body: bodyData(),
    );
  }

  Future<List<FeedValue>> getPosts() async {
    List<FeedValue> posts = [];
    UtilityModule utilityModule = new UtilityModule();
    posts = await utilityModule.getMyPost();
    setState(() {
      postCount = posts.length;
    });
    return posts;
  }

  Container buildUserPosts() {
    return Container(
        child: FutureBuilder<List<FeedValue>>(
      future: getPosts(),
      builder: (context, snapshot) {
        if (postCount == 0)
          return Container(
              alignment: FractionalOffset.center,
              padding: const EdgeInsets.only(top: 10.0),
              child: CircularProgressIndicator());
        else if (view == "grid") {
          // build the grid
          return GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
//                    padding: const EdgeInsets.all(0.5),
              mainAxisSpacing: 1.5,
              crossAxisSpacing: 1.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: snapshot.data.map((FeedValue feedValue) {
                return GridTile(child: ImageTile(feedValue));
              }).toList());
        } else if (view == "feed") {
          return Text("asdasd");
        }
      },
    ));
  }
}

class ImageTile extends StatelessWidget {
  final FeedValue feedValue;

  ImageTile(this.feedValue);

  clickedImage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<bool>(
        builder: (BuildContext context) => ViewPost(
              feedValue: feedValue,
            )));
  }

  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => clickedImage(context),
        child: Image.network(feedValue.img_path[0], fit: BoxFit.cover));
        //child: Image.network(feedValue.img_path[0], fit: BoxFit.fitWidth));
  }
}
