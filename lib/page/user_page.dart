import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/blank_appbar.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/models/post.dart';
import 'package:trip_story/models/trip.dart';
import 'package:trip_story/page/edit_trip_page.dart';
import 'package:trip_story/page/friends_page.dart';
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

class _UserPageState extends State<UserPage> {
  String view = 'post';
  String _nickName = '';
  List _postList = new List<Post>();
  List _tripList = new List<Trip>();

  @override
  void initState() {
    super.initState();
    if (this.widget.type == 'owner') {
      _nickName = Owner().nickName;
    } else {
      _nickName = this.widget.nickName;
    }
    getMyPost();
    getMyTrip();
  }

  Future<void> getMyTrip() async {
    List _result = new List<Trip>();
    http.Response _response =
        await http.get(AddressBook.getTripList + Owner().id);
    var resData = jsonDecode(_response.body);
    var state = resData['result'];
    if (state == 'success') {
      for (var value in resData['postThumbnails']) {
        //var value = jsonDecode(thumbnails);
        print(value['thumbnailPath']);
        Trip _temp = new Trip.init(
            id: value['postId'],
            content: value['content'],
            writeDate: DateTime.parse(value['createTime']),
            imageList: [value['thumbnailPath'] as String]);
        _result.add(_temp);
      }
      setState(() {
        _tripList = _result;
      });
    }
  }

  Future<void> getMyPost() async {
    List _result = new List<Post>();
    http.Response _response =
        await http.get(AddressBook.getPostList + Owner().id);
    var resData = jsonDecode(_response.body);
    var state = resData['result'];
    if (state == 'success') {
      for (var value in resData['postThumbnails']) {
        //var value = jsonDecode(thumbnails);
        Post _temp = new Post.init(
            id: value['postId'],
            content: value['content'],
            writeDate: DateTime.parse(value['createTime']),
            imageList: [value['thumbnailPath'] as String]);
        _result.add(_temp);
      }
      setState(() {
        _postList = _result;
      });
    }
  }

  Widget buildFollowButton() {}

  Widget buildTrip() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: List.generate(_tripList.length, (index) {
        return Container(
          color: Colors.black,
          width: MediaQuery.of(context).size.width / 3,
          height: MediaQuery.of(context).size.width / 3,
          child: InkWell(
            child: Image.network(
              _tripList[index].imageList[0],
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ViewTripPage()));
            },
          ),
        );
      }),
    );
  }

  Widget buildPost() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: List.generate(_postList.length, (index) {
        return Container(
          color: Colors.black,
          width: MediaQuery.of(context).size.width / 3,
          height: MediaQuery.of(context).size.width / 3,
          child: InkWell(
            child: Image.network(
              _postList[index].imageList[0],
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ViewPostPage()));
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlankAppbar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 4 / 5,
              child: Card(
                elevation: 8.0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            _nickName,
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
                                      builder: (BuildContext context) =>
                                          SettingsPage()));
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: MediaQuery.of(context).size.width / 9,
                              backgroundColor: Colors.blueAccent,
                              child: CircleAvatar(
                                radius:
                                    (MediaQuery.of(context).size.width / 9) -
                                        2.5,
                                backgroundImage: NetworkImage(Owner().profile),
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(Owner().name)
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '0',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('게시물')
                          ],
                        ),
                        InkWell(
                          child: Column(
                            children: [
                              Text(
                                '456',
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
                                '159',
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
                    SizedBox(
                      height: 15.0,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 4 / 5,
                      child: OutlineButton(
                        borderSide: BorderSide(color: Colors.blueAccent),
                        child: Text('팔로우 취소'),
                        onPressed: () {},
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ),
            ),
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
            view == 'post' ? buildPost() : buildTrip()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'makeTrip',
        label: Text('여행 작성'),
        icon: Icon(Icons.airport_shuttle),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => EditTripPage()));
        },
      ),
    );
  }
}
