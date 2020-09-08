import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tripstory/modules/URLBook.dart';
import 'package:tripstory/modules/Comment.dart';
import 'package:tripstory/modules/FeedValue.dart';
import 'package:http/http.dart' as http;
import 'package:tripstory/modules/UserInfo.dart';
import 'package:tripstory/modules/UtilityModule.dart';

class ViewPost extends StatefulWidget {
  final FeedValue feedValue;

  ViewPost({this.feedValue});

  @override
  _ViewPostState createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
  int _index = 0;
  bool _liked = false;
  String content = "";
  List<Comment> comments = [];
  final formKey = new GlobalKey<FormState>();
  final TextEditingController _textController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    if(widget.feedValue.likes == null){
      widget.feedValue.likes = 0;
    }
    getLikeState();
    getComments();
  }

  Future<void> getComments() async {
    List<Comment> _comments = [];
    Map<String, dynamic> value = {'feed_id': widget.feedValue.feed_id};

    http.Response response = await http.post(URLBook.get_comment,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(value));
    var resData = jsonDecode(response.body);
    for(var data in resData){
      Comment temp = new Comment(data['number'], data['user_id'],
          data['user_name'], data['comment']);
      _comments.add(temp);
    }
    setState(() {
      comments = _comments;
    });
  }

  Future<void> getLikeState() async {
    Map<String, dynamic> value = {'feed_id': widget.feedValue.feed_id, 'user_id' : UserInfo().getUserId()};

    http.Response response = await http.post(URLBook.get_like,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(value));
    print(response.body);
    if(response.body == "true"){
      setState(() {
        _liked = true;
      });
    }
  }

  Widget _buildComment(int index) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: ListTile(
        leading: Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 2),
                blurRadius: 6.0,
              ),
            ],
          ),
          child: CircleAvatar(
            child: ClipOval(
              child: Image(
                height: 50.0,
                width: 50.0,
                //TODO: 댓글 작성자 프로필 사진
                image: NetworkImage(
                    URLBook.default_profile),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        title: Text(
          comments[index].name, //TODO: 댓글 작성자 이름
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(comments[index].contents), //TODO: 댓글 내용
        trailing: IconButton(
          icon: Icon(
            //TODO: 사용자와 comment 소유자가 같을때만 close로 아니면 다른거 표시하기
            Icons.close,
          ),
          color: (UserInfo().getUserId() == comments[index].id) ? Colors.grey : Colors.white,
          onPressed: () {
            print('remove comment');
            delComment(comments[index].number);
          },
        ),
      ),
    );
  }

  List<Widget> comment() {
    List<Widget> result = List<Widget>();
    for (int i = comments.length - 1; i >= 0; i--) {
      result.add(_buildComment(i));
    }
    return result;
  }

  void submitComment(){
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      sendComment(content);
    } else {
      print('form failed');
    }
    FocusScopeNode currentFocus = FocusScope.of(context);
    if(!currentFocus.hasPrimaryFocus){
      currentFocus.unfocus();
    }
    _textController.clear();
  }

  Future<void> sendComment(String text) async {
    UtilityModule ctr = new UtilityModule();
    print(text);
    var result = await ctr.addComment(widget.feedValue.feed_id, text);
    if(result == "success"){
      (context as Element).reassemble();
      getComments();
    }
    else{
      print("upload failed");
    }
  }

  Future<void> delComment(int commentNum) async {
    UtilityModule ctr = new UtilityModule();
    var result = await ctr.delComment(widget.feedValue.feed_id, commentNum);
    if(result == "success"){
      (context as Element).reassemble();
      getComments();
    }
    else{
      print("delete failed");
    }
  }

  void sendAddLike(){
    addLike();
  }

  void sendDelLike(){
    delLike();
  }

  Future<void> addLike() async {
    Map<String, dynamic> value = {'feed_id': widget.feedValue.feed_id, 'user_id' : UserInfo().getUserId()};

    http.Response response = await http.post(URLBook.add_like,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(value));
    print(response.body);
    if(response.body == "success"){
      setState(() {
        widget.feedValue.likes++;
        _liked = !_liked;
      });
    }
  }

  Future<void> delLike() async {
    Map<String, dynamic> value = {'feed_id': widget.feedValue.feed_id, 'user_id' : UserInfo().getUserId()};

    http.Response response = await http.post(URLBook.del_like,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(value));
    print(response.body);
    if(response.body == "success"){
      setState(() {
        widget.feedValue.likes--;
        _liked = !_liked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScopeNode currentFocus = FocusScope.of(context);
        if(!currentFocus.hasPrimaryFocus){
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xFFEDF0F6),
        body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 40.0),
                width: double.infinity,
                height: 600.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.arrow_back),
                                iconSize: 30.0,
                                color: Colors.black,
                                onPressed: () => Navigator.pop(context),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: ListTile(
                                  leading: Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black45,
                                          offset: Offset(0, 2),
                                          blurRadius: 6.0,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      child: ClipOval(
                                        child: Image(
                                          height: 50.0,
                                          width: 50.0,
                                          image: NetworkImage(
                                              URLBook.default_profile),
                                          //TODO: 게시글 작성자 프로필 사진
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    widget.feedValue.name, //TODO: 게시글 작성자 이름
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(widget.feedValue.tag_name),
                                  trailing: IconButton(
                                    icon: Icon(Icons.more_horiz),
                                    color: Colors.black,
                                    onPressed: () => print('More'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onDoubleTap: () => print('Like post'),
                            child: Container(
                              margin: EdgeInsets.all(10.0),
                              //width: double.infinity,
                              height: 400.0,
                              child: PageView.builder(
                                  itemCount: widget.feedValue.img_path.length,
                                  controller:
                                  PageController(viewportFraction: 1.0),
                                  onPageChanged: (int index) =>
                                      setState(() => _index = index),
                                  itemBuilder: (_, i) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25.0),
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              widget.feedValue.img_path[i]),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        IconButton(
                                          icon: (_liked) ? Icon(Icons.favorite, color: Colors.red,) : Icon(Icons.favorite_border),
                                          iconSize: 30.0,
                                          onPressed: () {
                                            print('Like post');
                                            if(_liked){
                                              sendDelLike();
                                            }
                                            else{
                                              sendAddLike();
                                            }
                                          },
                                        ),
                                        Text(
                                          widget.feedValue.likes.toString(),
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 20.0),
                                    Row(
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.chat_bubble_outline),
                                          iconSize: 30.0,
                                          onPressed: () {
                                            print('Chat');
                                          },
                                        ),
                                        Text(
                                          comments.length.toString(),
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  widget.feedValue.upload_date,
                                  textAlign: TextAlign.right,
                                ),
                                /*
                              IconButton(
                                icon: Icon(Icons.bookmark_border),
                                iconSize: 30.0,
                                onPressed: () => print('Save post'),
                              ),
                               */
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                width: double.infinity,
                //height: 600.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Column(
                  children: comment(),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: Transform.translate(
            offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
            child: Form(
              key: formKey,
              child: Container(
                height: 100.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, -2),
                      blurRadius: 6.0,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: _textController,
                    validator: (value){
                      if (value.isEmpty) {
                        return '댓글을 입력하세요!';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) => content = value,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      contentPadding: EdgeInsets.all(20.0),
                      hintText: 'Add a comment',
                      prefixIcon: Container(
                        margin: EdgeInsets.all(4.0),
                        width: 48.0,
                        height: 48.0,
                        /*
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    child: ClipOval(
                      child: Image(
                        height: 48.0,
                        width: 48.0,
                        image: NetworkImage(
                            "https://avatars0.githubusercontent.com/u/12619420?s=460&v=4"),
                        //TODO: 게시글 작성자 사진
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  */
                      ),
                      suffixIcon: Container(
                        margin: EdgeInsets.only(right: 4.0),
                        width: 70.0,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          color: Color(0xFF23B66F),
                          onPressed: submitComment,
                          child: Icon(
                            Icons.send,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
        ),
      ),
    );
  }
}
