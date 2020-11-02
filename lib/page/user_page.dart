import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trip_story/page/friends_page.dart';
import 'package:trip_story/page/make_trip_page.dart';
import 'package:trip_story/page/settings_page.dart';
import 'package:trip_story/page/view_post_page.dart';
import 'package:trip_story/page/view_trip_page.dart';
import 'package:trip_story/utils/address_book.dart';
import 'package:trip_story/utils/blank_appbar.dart';
import 'package:trip_story/utils/user.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String view = 'post';

  Widget buildTrip(){
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: List.generate(100, (index) {
        return Container(
          color: Colors.black,
          width: MediaQuery.of(context).size.width / 3,
          height: MediaQuery.of(context).size.width / 3,
          child: InkWell(
            child: Image.network(AddressBook.getSampleImg(), fit: BoxFit.contain,),
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) => ViewTripPage()));
            },
          ),
        );
      }),
    );
  }

  Widget buildPost(){
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: List.generate(100, (index) {
        return Container(
          color: Colors.black,
          width: MediaQuery.of(context).size.width / 3,
          height: MediaQuery.of(context).size.width / 3,
          child: InkWell(
            child: Image.network(AddressBook.getSampleImg(), fit: BoxFit.contain,),
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) => ViewPostPage()));
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
                            'NickName',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(12.0),
                          child: InkWell(
                            child: Icon(Icons.settings),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (BuildContext context) => SettingsPage()));
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
                                    (MediaQuery.of(context).size.width / 9) - 2.5,
                                backgroundImage: NetworkImage(User().profile),
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(User().name)
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
                          onTap: (){
                            //TODO: 주소랑 현재창 유저id 넘겨서 판단
                            Navigator.push(context,
                                MaterialPageRoute(builder: (BuildContext context) => FriendsPage()));
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
                          onTap: (){
                            Navigator.push(context,
                                MaterialPageRoute(builder: (BuildContext context) => FriendsPage()));
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
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => MakeTripPage()));
        },
      ),
    );
  }
}
