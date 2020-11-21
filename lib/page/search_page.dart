import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/blank_appbar.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/common/paged_image_view.dart';
import 'package:trip_story/models/friend.dart';
import 'package:trip_story/models/post.dart';

import 'package:http/http.dart' as http;
import 'package:trip_story/page/user_page.dart';
import 'package:trip_story/page/view_post_page.dart';
import 'package:trip_story/page/view_trip_page.dart';

class SearchPage extends StatefulWidget {
  final type;
  final keyWord;

  const SearchPage({Key key, this.type, this.keyWord}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController _textEditingController = new TextEditingController();
  String _type = 'sub';
  List<Friend> friendWithName = new List();
  List<Friend> friendWithNickName = new List();
  List<Map> feedList = new List();

  @override
  bool wantKeepAlive = false;

  @override
  void initState() {
    super.initState();
    _type = this.widget.type;
    if (_type == 'main') {
      wantKeepAlive = true;
    }
    if (this.widget.keyWord != null) {
      _textEditingController.text = this.widget.keyWord;
      getFeedWithTag(this.widget.keyWord);
      getFriendWithNickName(this.widget.keyWord);
      getFriendWithName(this.widget.keyWord);
    }
  }

  Future<void> getFriendWithName(String value) async {
    http.Response _response =
        await http.get(AddressBook.searchFriendWithName + value);
    if (_response.statusCode == 200) {
      var resData = jsonDecode(_response.body);
      if (resData['result'] == 'success') {
        List<Friend> _list = new List();
        for (var data in resData['members']) {
          if (data['nickName'] != Owner().nickName) {
            Friend _friend = new Friend.init(
                data['name'], data['nickName'], data['profileImagePath']);

            _list.add(_friend);
          }
        }
        setState(() {
          friendWithName = _list;
        });
      } else if (resData['errors'] != null) {
        throw Exception(
            'Failed to search friend with name value\n${resData['errors']}');
      } else {
        throw Exception('Failed to search friend with name value');
      }
    }
  }

  Future<void> getFriendWithNickName(String value) async {
    http.Response _response =
        await http.get(AddressBook.searchFriendWithNickName + value);
    if (_response.statusCode == 200) {
      var resData = jsonDecode(_response.body);
      if (resData['result'] == 'success') {
        List<Friend> _list = new List();
        for (var data in resData['members']) {
          if (data['nickName'] != Owner().nickName) {
            Friend _friend = new Friend.init(
                data['name'], data['nickName'], data['profileImagePath']);

            _list.add(_friend);
          }
        }
        setState(() {
          friendWithNickName = _list;
        });
      } else if (resData['errors'] != null) {
        throw Exception(
            'Failed to search friend with nick name value\n${resData['errors']}');
      } else {
        throw Exception('Failed to search friend with nick name value');
      }
    }
  }

  Future<void> getFeedWithTag(String value) async {
    http.Response _response =
        await http.get(AddressBook.searchFeedWithTag + value);
    print(_response.body);
    if (_response.statusCode == 200) {
      var resData = jsonDecode(_response.body);
      if (resData['result'] == 'success') {
        List<Map> _list = new List();
        for (var data in resData['posts']) {
          Post temp = new Post();
          Map _map = new Map();
          temp.fromJson(data);
          _map['item'] = temp;
          _map['type'] = data['type'];
          _list.add(_map);
        }
        setState(() {
          feedList = _list;
        });
      } else if (resData['errors'] != null) {
        throw Exception(
            'Failed to search feed with tag value\n${resData['errors']}');
      } else {
        throw Exception('Failed to search feed with tag value');
      }
    }
  }

  Widget friendTile(Friend friend) {
    //TODO: 본인 팔로잉에서만 수정버튼 보이기
    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(18.0, 8.0, 8.0, 0.0),
          leading: CircleAvatar(
            radius: MediaQuery.of(context).size.width / 15,
            backgroundColor: Colors.blueAccent,
            child: CircleAvatar(
              radius: (MediaQuery.of(context).size.width / 15) - 1,
              backgroundImage: NetworkImage(friend.profile),
            ),
          ),
          title: Text(friend.nickName),
          subtitle: Text(friend.name),
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => UserPage(
                      nickName: friend.nickName,
                      type: 'other',
                    )));
      },
    );
  }

  Widget buildFriendViewWithName() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: friendWithName.length,
          itemBuilder: (context, index) {
            return friendTile(friendWithName[index]);
          }),
    );
  }

  Widget buildFriendViewWithNickName() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: friendWithNickName.length,
          itemBuilder: (context, index) {
            return friendTile(friendWithNickName[index]);
          }),
    );
  }

  Widget buildFeedView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: feedList.length,
          itemBuilder: (context, index) {
            return feedTemplate(feedList[index]);
          }),
    );
  }

  Widget feedTemplate(Map item) {
    Post _post = item['item'];
    return Container(
      //width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      child: InkWell(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: EdgeInsets.all(8.0),
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 3.0,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                color: Colors.black,
                child: Stack(
                  children: [
                    PagedImageView(
                      list: _post.imageList,
                      fit: BoxFit.cover,
                      zoomAble: false,
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 19 / 20,
                        color: Color.fromRGBO(0, 0, 0, 150),
                        child:

                            ///좋아요, 댓글, 작성일자
                            ListTile(
                          title: Row(
                            children: [
                              IconButton(
                                icon: _post.liked
                                    ? Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      )
                                    : Icon(
                                        Icons.favorite_border,
                                        color: Colors.white38,
                                      ),
                                onPressed: () {},
                              ),
                              Text(
                                _post.likes.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white38,
                                ),
                              ),
                              SizedBox(
                                width: 25.0,
                              ),
                              Icon(
                                Icons.mode_comment_outlined,
                                color: Colors.white38,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                _post.comments.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            DateFormat('yy. MM. dd HH:mm')
                                .format(_post.writeDate),
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white38,
                                fontSize: 12.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// 본문
              _post.content != ''
                  ? Container(
                      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      child: Text(
                        _post.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),

              ///태그
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  children: buildTagChip(_post.tagList).toList(),
                ),
              ),
              SizedBox(
                height: 5.0,
              )
            ],
          ),
        ),
        onTap: (){
          print(item['type']);
          if (item['type'] == 'NORMAL') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => ViewPostPage(
                      feedId: _post.id,
                      type: 'post',
                    )));
          }
          if (item['type'] == 'TRAVEL') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => ViewTripPage(
                      feedId: _post.id,
                      type: 'trip',
                    )));
          }
        },
      ),
    );
  }

  List<Widget> buildTagChip(List tagList) {
    List<Widget> _tags = new List();
    for (String i in tagList) {
      Container _chip = new Container(
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        child: Chip(
          elevation: 5.0,
          shape: StadiumBorder(side: BorderSide(color: Colors.transparent)),
          backgroundColor: Colors.transparent,
          label: Text(
            '# ' + i,
            style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline),
          ),
        ),
      );
      _tags.add(_chip);
    }
    return _tags;
  }

  Widget buildResultView() {
    if (friendWithName.isEmpty &&
        friendWithNickName.isEmpty &&
        feedList.isEmpty) {
      return Center(
        child: Text('검색 결과가 없습니다.'),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(
              '닉네임',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          friendWithNickName.isNotEmpty
              ? buildFriendViewWithNickName()
              : Center(
                  child: Text('검색 결과가 없습니다.'),
                ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(
              '이름',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          friendWithName.isNotEmpty
              ? buildFriendViewWithName()
              : Center(
                  child: Text('검색 결과가 없습니다.'),
                ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(
              '게시물',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          feedList.isNotEmpty
              ? buildFeedView()
              : Center(
                  child: Text('검색 결과가 없습니다.'),
                ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _type == 'main'
          ? BlankAppbar()
          : AppBar(
              title: Text('검색'),
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ///검색 위젯
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(15.0),
              child: TextFormField(
                controller: _textEditingController,
                maxLength: 20,
                onChanged: (value) {
                  if (value.replaceAll(' ', '') != '') {
                    getFriendWithNickName(value);
                    getFriendWithName(value);
                    getFeedWithTag(value);
                  }
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search), hintText: 'Search'),
              ),
            ),
            buildResultView(),
          ],
        ),
      ),
    );
  }
}
