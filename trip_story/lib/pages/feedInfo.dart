import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tripstory/modules/FeedValue.dart';
import 'package:tripstory/modules/UserInfo.dart';
import 'package:http/http.dart' as http;

class FeedInfo extends StatefulWidget {
  final FeedValue feedValue;

  FeedInfo({Key key, @required this.feedValue}) : super(key: key);

  @override
  _FeedInfoState createState() => _FeedInfoState();
}

class _FeedInfoState extends State<FeedInfo> {
  Size deviceSize;
  TextEditingController _textController;
  bool _like = false;
  List<Widget> imgs = new List<Widget>();
  int _index = 0;

  void getImgs() {
    List<Widget> result = [];
    for (String i in widget.feedValue.img_path) {
      Image temp = new Image(
        width: deviceSize.width,
        fit: BoxFit.fitWidth,
        image: new NetworkImage(i),
      );
      result.add(temp);
    }
    imgs.addAll(result);
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    getImgs();
    return Scaffold(
        appBar: AppBar(
          title: const Text("게시물"),
        ),
        resizeToAvoidBottomPadding: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      /*new Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(
                              "https://pbs.twimg.com/profile_images/916384996092448768/PF1TSFOE_400x400.jpg")),
                    ),
                  ),*/
                      new SizedBox(
                        width: 10.0,
                      ),
                      new Text(
                        widget.feedValue.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  new IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: null,
                  )
                ],
              ),
            ),
            Container(
              height: deviceSize.height / 3,
              child: Center(
                child: PageView.builder(
                  itemCount: imgs.length,
                  controller: PageController(viewportFraction: 0.7),
                  onPageChanged: (int index) => setState(() => _index = index),
                  itemBuilder: (_, i) {
                    return Transform.scale(
                      scale: i == _index ? 1 : 0.9,
                      child: imgs[i],
                    );
                  },
                ),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new IconButton(
                          icon: (_like)
                              ? Icon(
                                  Icons.favorite,
                                )
                              : Icon(
                                  Icons.favorite_border,
                                ),
                          onPressed: () {
                            //TODO: 서버에 바뀌었다고 알리기

                            setState(() {
                              _like = !_like;
                            });
                          }),
                      new SizedBox(
                        width: 16.0,
                      ),
                      new Icon(
                        Icons.chat_bubble_outline,
                      ),
                      /*new SizedBox(
                      width: 16.0,
                    ),
                    new Icon(Icons.send),*/
                    ],
                  ),
                  new Icon(Icons.bookmark_border)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: <Widget>[
                  Container(
                    child: Image.network(
                        'https://purepng.com/public/uploads/medium/heart-icon-s4k.png'),
                    width: 15,
                    height: 15,
                    margin: EdgeInsets.symmetric(horizontal: 6.0),
                  ),
                  Text(
                    widget.feedValue.likes.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(widget.feedValue.upload_date,
                  style: TextStyle(color: Colors.grey)),
            ),
            Padding(
              padding: EdgeInsets.all(5),
            ),
            Divider(
              color: Colors.black,
              indent: 20,
              endIndent: 20,
            ),
            //TODO: 가라 댓글(댓글 표시로 대체하기)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new SizedBox(
                    width: 10.0,
                  ),
                  new Text("Shim"),
                  new SizedBox(
                    width: 10.0,
                  ),
                  new Text("정말 멋진 풍경이네요!")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new SizedBox(
                    width: 10.0,
                  ),
                  new Text("Dongdong"),
                  new SizedBox(
                    width: 10.0,
                  ),
                  new Text("ㅋㅋㄹㅋㅋ")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new SizedBox(
                    width: 10.0,
                  ),
                  new Text("kim"),
                  new SizedBox(
                    width: 10.0,
                  ),
                  new Text("어머나 정말 이쁘네요")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new SizedBox(
                    width: 10.0,
                  ),
                  new Text("Song"),
                  new SizedBox(
                    width: 10.0,
                  ),
                  new Text("ㅎㅎ")
                ],
              ),
            ),
            //TODO:가라댓글
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  /*new Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(
                            "https://pbs.twimg.com/profile_images/916384996092448768/PF1TSFOE_400x400.jpg")),
                  ),
                ),*/
                  new SizedBox(
                    width: 10.0,
                  ),
                  Container(
                    width: deviceSize.width * 3 / 5,
                    child: CupertinoTextField(
                      controller: _textController,
                      placeholder: '댓글 작성하기',
                    ),
                  ),
                  new SizedBox(
                    width: deviceSize.width / 13,
                  ),
                  new Container(
                    child: new RaisedButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0)),
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: new Text(
                        '작성',
                        style: new TextStyle(fontSize: 20.0),
                      ),
                      onPressed: () async {
                        //TODO: print 지우기
                        print(_textController.text);

                        Map<String, dynamic> value = {
                          'id': UserInfo().getUserId(),
                          'feed_id': widget.feedValue.feed_id,
                          'content': _textController.text
                        };

                        http.Response response =
                        await http.post("tripstory.ga/",
                            headers: <String, String>{
                              'Content-Type':
                              'application/json; charset=UTF-8',
                            },
                            body: jsonEncode(value));

                        //resData = jsonDecode(response.body);

                        if (response.body == "success") {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoAlertDialog(
                                    title: new Text("댓글 작성"),
                                    content: new Text("댓글을 성공적으로 작성하였습니다."),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        isDefaultAction: true,
                                        child: Text("확인"),
                                        onPressed: () {
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ));
                          setState(() {});
                        } else if (response.body == "failed") {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoAlertDialog(
                                    title: new Text("작성 실패"),
                                    content: new Text("댓글 작성을 실패하였습니다."),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        isDefaultAction: true,
                                        child: Text("확인"),
                                        onPressed: () {
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ));
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoAlertDialog(
                                    title: new Text("작성 실패"),
                                    content: new Text("댓글 작성을 실패하였습니다."),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        isDefaultAction: true,
                                        child: Text("확인"),
                                        onPressed: () {
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ));
                          setState(() {});
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        );
  }
}
