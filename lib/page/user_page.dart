import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:trip_story/blocs/user_bloc.dart';
import 'package:trip_story/common/blank_appbar.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/models/friend.dart';
import 'package:trip_story/page/edit_trip_page.dart';
import 'package:trip_story/page/friends_page.dart';
import 'package:trip_story/page/network_image_view_page.dart';
import 'package:trip_story/page/settings_page.dart';
import 'package:trip_story/page/view_post_page.dart';
import 'package:trip_story/page/view_trip_page.dart';

class UserPage extends StatefulWidget {
  final String nickName;
  final String type;

  const UserPage({Key key, this.nickName, this.type}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with AutomaticKeepAliveClientMixin {
  final UserBloc _bloc = new UserBloc();
  String view = 'post';
  String _nickName = '';

  /*
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => throw UnimplementedError();
   */

  @override
  bool wantKeepAlive = false;

  @override
  void initState() {
    super.initState();
    if (this.widget.type == 'owner') {
      _nickName = Owner().nickName;
      wantKeepAlive = true;
    } else {
      _nickName = this.widget.nickName;
      wantKeepAlive = false;
    }
    _bloc.fetchAll(_nickName);
  }

  Widget buildTrip() {
    return StreamBuilder(
        stream: _bloc.tripStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  children: List.generate(snapshot.data.length, (index) {
                    return Container(
                      color: Colors.black,
                      width: MediaQuery.of(context).size.width / 3,
                      height: MediaQuery.of(context).size.width / 3,
                      child: InkWell(
                        child: Image.network(
                          snapshot.data[index].imageList[0],
                          fit: BoxFit.cover,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ViewTripPage(
                                        feedId: snapshot.data[index].id,
                                        type: 'trip',
                                      )));
                        },
                      ),
                    );
                  }),
                )
              : Center(
                  heightFactor: 2,
                  child: LoadingBouncingGrid.square(
                    inverted: true,
                    backgroundColor: Colors.blueAccent,
                    size: 80.0,
                  ),
                );
        });
  }

  Widget buildPost() {
    return StreamBuilder(
        stream: _bloc.postStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  children: List.generate(snapshot.data.length, (index) {
                    return Container(
                      color: Colors.black,
                      width: MediaQuery.of(context).size.width / 3,
                      height: MediaQuery.of(context).size.width / 3,
                      child: InkWell(
                        child: Image.network(
                          snapshot.data[index].imageList[0],
                          fit: BoxFit.cover,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ViewPostPage(
                                        feedId: snapshot.data[index].id,
                                        type: 'post',
                                      )));
                        },
                      ),
                    );
                  }),
                )
              : Center(
                  heightFactor: 2,
                  child: LoadingBouncingGrid.square(
                    inverted: true,
                    backgroundColor: Colors.blueAccent,
                    size: 80.0,
                  ),
                );
        });
  }

  Widget buildFollowButton(Friend _friend) {
    if (this.widget.type == 'owner') {
      return SizedBox(
        height: 35.0,
      );
    } else {
      return Column(
        children: [
          SizedBox(
            height: 15.0,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 4 / 5,
            child: _friend.followed
                ? OutlineButton(
                    borderSide: BorderSide(color: Colors.blueAccent),
                    child: Text('Unfollow'),
                    onPressed: () => _bloc.unfollow(_friend.nickName),
                  )
                : RaisedButton(
                    elevation: 5.0,
                    color: Colors.blue,
                    child: Text(
                      'Follow',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => _bloc.follow(_friend.nickName),
                  ),
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
      );
    }
  }

  Widget buildProfileTop() {
    if (this.widget.type == 'owner') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(12.0),
            child: Text(
              Owner().nickName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: EdgeInsets.all(12.0),
            child: InkWell(
              child: Icon(Icons.settings),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => SettingsPage()));
              },
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        height: 0.0,
      );
    }
  }

  Widget buildProfileCard() {
    return StreamBuilder(
        stream: _bloc.profileStream,
        builder: (context, snapshot) {
          return Container(
            width: MediaQuery.of(context).size.width * 4 / 5,
            child: Card(
              elevation: 8.0,
              child: Column(
                children: [
                  buildProfileTop(),
                  SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          InkWell(
                            child: CircleAvatar(
                              radius: MediaQuery.of(context).size.width / 9,
                              backgroundColor: Colors.blueAccent,
                              child: CircleAvatar(
                                radius:
                                    (MediaQuery.of(context).size.width / 9) -
                                        2.5,
                                backgroundImage:
                                    NetworkImage(snapshot.data.profile),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          NetworkImageViewPage(
                                            url: snapshot.data.profile,
                                          )));
                            },
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(snapshot.data.name),
                        ],
                      ),
                      StreamBuilder(
                        stream: _bloc.feedCountStream,
                          builder: (context, snapshot) {
                        return Column(
                          children: [
                            Text(
                              '${snapshot.data}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('게시물')
                          ],
                        );
                      }),
                      InkWell(
                        child: Column(
                          children: [
                            Text(
                              snapshot.data.follower.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('팔로워')
                          ],
                        ),
                        onTap: () {
                          //TODO: 주소랑 현재창 유저id 넘겨서 판단
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      FriendsPage(_nickName, 'follower')));
                        },
                      ),
                      InkWell(
                        child: Column(
                          children: [
                            Text(
                              snapshot.data.following.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('팔로잉')
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      FriendsPage(_nickName, 'following')));
                        },
                      )
                    ],
                  ),
                  buildFollowButton(snapshot.data),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: this.widget.type == 'owner'
          ? BlankAppbar()
          : AppBar(
              title: Text(_nickName),
            ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildProfileCard(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.apps),
                  color: view == 'post' ? Colors.blueAccent : Colors.black12,
                  onPressed: () {
                    setState(() {
                      view = 'post';
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.assistant_navigation),
                  color: view == 'trip' ? Colors.blueAccent : Colors.black12,
                  onPressed: () {
                    setState(() {
                      view = 'trip';
                    });
                  },
                ),
              ],
            ),
            view == 'post' ? buildPost() : buildTrip(),
          ],
        ),
      ),
      floatingActionButton: this.widget.type == 'owner'
          ? FloatingActionButton.extended(
              heroTag: 'makeTrip',
              label: Text('여행 작성'),
              icon: Icon(Icons.dynamic_feed),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => EditTripPage()));
              },
            )
          : null,
    );
  }
}
